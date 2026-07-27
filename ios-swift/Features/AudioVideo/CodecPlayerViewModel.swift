import AVFoundation
import Combine
import Foundation
import UIKit

/// 硬解码播放页的"控制器对象"。
///
/// 跟 Android 那边 `CodecPlayerActivity` 的思路一一对应：
///
///   Android                                 iOS (这里)
///   ─────────                               ─────────
///   MediaExtractor                          AVAssetReader
///   MediaCodec (硬解)                       AVAssetReaderTrackOutput (iOS 内部自动用 VideoToolbox 走硬解)
///   SurfaceView + Surface                   AVSampleBufferDisplayLayer
///   AudioTrack.write(pcm)                   AVAudioEngine + AVAudioPlayerNode
///   MediaCodec.BufferInfo.presentationTimeUs  CMSampleBuffer.presentationTimeStamp
///   TextView.setText("...")                 @Published var
///
/// 教学意义：
///   这一层就能看到"读 mp4 → 解码 → 显示/播放"的完整链路。
///   如果后面想学更底层的 VideoToolbox，再把 `AVAssetReaderTrackOutput`
///   替换成 `VTDecompressionSession` 即可，整体框架不需要大改。
@MainActor
final class CodecPlayerViewModel: ObservableObject {
    nonisolated private static func log(_ message: String) {
        print("[CodecPlayer] \(message)")
    }

    // MARK: - 对外暴露给 SwiftUI 的状态

    /// 状态文案，驱动顶部 statusText。
    @Published var statusText: String = "等待打开"

    /// 视频总时长（秒），从 AVAsset 读出来。
    @Published var durationSeconds: Double = 0

    /// 当前播放到第几秒（驱动进度条）。
    @Published var currentSeconds: Double = 0

    /// 是否循环播放。
    @Published var isLooping: Bool = false

    /// 是否正在播放（区分"播放中"和"已停止"）。
    @Published var isPlaying: Bool = false

    /// 视频源 URL（沙盒里的 .mov 文件）。
    let videoURL: URL

    // MARK: - 内部对象

    /// 视频显示层。和 Android 的 `SurfaceView + Surface` 对应。
    ///
    /// 特点：
    /// - 内部维护一个队列, 自动按 PTS 顺序把 CMSampleBuffer 画到屏幕上
    /// - 不需要我们手动 sleep / vsync
    /// - 这里先在 init 里创建, 然后给 View 层绑定
    let displayLayer = AVSampleBufferDisplayLayer()

    /// 音频引擎: 负责把 PCM 推给扬声器。
    private let audioEngine = AVAudioEngine()

    /// 音频播放节点: 类似 Android 的 AudioTrack。
    private let audioPlayer = AVAudioPlayerNode()

    /// 后台解码线程。和 Android 的 HandlerThread 思路一样:
    /// 解码/读取都是 CPU 密集, 不能在主线程跑。
    private let decodeQueue = DispatchQueue(label: "com.example.ios-swift.codec-decode", qos: .userInteractive)

    /// 用来在循环播放时重启解码。
    private var isDecodingCancelled = false

    /// 进度条刷新定时器 (主线程 0.1s 一次)。
    private var progressTimer: Timer?

    /// 用于判断"音频是否真的存在" (录的视频可能没音轨)。
    private var hasAudioTrack = false

    /// 视频轨的格式描述 (解码时需要)。
    private var videoFormatDescription: CMFormatDescription?

    /// 音频 PCM 格式 (用于配置 AVAudioEngine 的 format)。
    private var audioStreamDescription: AudioStreamBasicDescription?

    /// 真正喂给 AVAudioPlayerNode 的播放格式。
    ///
    /// 这里要特别注意“源数据格式”和“播放器当前输出格式”不是一回事：
    /// - 源音频轨可能是单声道 44.1k / 16-bit
    /// - mainMixer 的输出常常是双声道 float
    ///
    /// 如果直接拿 `audioPlayer.outputFormat(forBus: 0)` 来解释源 PCM，
    /// 很容易把单声道数据按双声道读，听起来就会像“放炮”“爆音”。
    ///
    /// 另外这里还有个 Core Audio 的坑：
    /// - `AVAudioEngine.mainMixerNode` 更偏好吃 Float32 PCM
    /// - 如果我们强行拿 Int16/non-interleaved 去 connect
    /// - 有些设备/系统组合会直接在 `connect(...format:)` 时报格式不支持
    ///
    /// 所以这里把“播放格式”统一定成 Float32，再把源 Int16 PCM 手动转成 Float。
    private var audioPlaybackFormat: AVAudioFormat?

    /// 标记 audioPlayer 是否已经 attach 到 audioEngine。
    private var didAttachAudioPlayer = false

    /// 主循环最近一次 enqueue 的视频帧 PTS (秒), 用于定时器做进度条平滑。
    private var lastEnqueuePTS: Double = 0

    /// 主循环最近一次 enqueue 视频帧时的 wall time (CFAbsoluteTime), 用于定时器做插值。
    private var lastEnqueueWallTime: CFAbsoluteTime = 0

    /// 调试统计：已经 enqueue 了多少个视频 sample。
    private var videoSampleCount: Int = 0

    /// 调试统计：已经 schedule 了多少个音频 sample。
    private var audioSampleCount: Int = 0

    // MARK: - 初始化

    init(videoURL: URL) {
        self.videoURL = videoURL
        Self.log("init, videoURL=\(videoURL.path)")
    }

    deinit {
        // 兜底: 即使页面异常销毁, 也要停掉音频引擎, 否则 audioSession 不释放
        Self.log("deinit")
        audioEngine.stop()
    }

    // MARK: - 生命周期入口

    /// 页面出现时调用。
    func onAppear() {
        Self.log("onAppear, fileExists=\(FileManager.default.fileExists(atPath: videoURL.path))")
        statusText = "正在打开视频…"
        prepareAudioEngineIfNeeded()
        startDecoding()
    }

    /// 页面消失时调用。
    func onDisappear() {
        Self.log("onDisappear")
        isDecodingCancelled = true
        stopProgressTimer()
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        // 把 displayLayer 的队列清空
        displayLayer.flushAndRemoveImage()
    }

    // MARK: - 音频引擎初始化

    /// 配置 AVAudioEngine。
    ///
    /// 为什么要先初始化 audioEngine?
    ///   因为我们要从 mp4 抽 audio 轨的 format, 再用这个 format 去配 audioPlayer
    ///   但 mp4 的音频格式在 `startDecoding` 里才能拿到。
    ///   所以这里只做"通用"配置, 真正接 player 等拿到 format 再补上。
    private func prepareAudioEngineIfNeeded() {
        if !didAttachAudioPlayer {
            Self.log("prepareAudioEngineIfNeeded attach audioPlayer")
            audioEngine.attach(audioPlayer)
            didAttachAudioPlayer = true
        }
    }

    /// 根据音轨格式，把 AVAudioPlayerNode 连接到 mixer。
    ///
    /// 这一层可以类比 Android 的 AudioTrack 初始化：
    /// - 你不能只知道“我要播音频”
    /// - 还必须知道 sampleRate / channelCount / sampleFormat
    /// - 配错了就会出现变速、爆音、杂音
    private func configureAudioPlaybackFormatIfNeeded() {
        guard let audioPlaybackFormat else {
            Self.log("configureAudioPlaybackFormatIfNeeded skipped: audioPlaybackFormat=nil")
            return
        }

        audioEngine.disconnectNodeOutput(audioPlayer)
        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: audioPlaybackFormat)
        Self.log(
            "configured audio playback format, sampleRate=\(audioPlaybackFormat.sampleRate), channels=\(audioPlaybackFormat.channelCount), interleaved=\(audioPlaybackFormat.isInterleaved)"
        )
    }

    // MARK: - 解码主循环 (后台线程)

    /// 启动一次完整的"读 → 解码 → 渲染"循环。
    ///
    /// 整体思路跟 Android 的 `decodeLoop` 一模一样:
    ///   while 没有结束:
    ///       从 AVAssetReader 拿一帧 video CMSampleBuffer
    ///       把它 enqueue 到 displayLayer (相当于 releaseOutputBuffer(idx, true))
    ///       从 AVAssetReader 拿一帧 audio CMSampleBuffer
    ///       把它 schedule 到 audioPlayer
    ///       更新进度条
    private func startDecoding() {
        let exists = FileManager.default.fileExists(atPath: videoURL.path)
        let fileSize: Int64 = (try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] as? Int64) ?? -1
        Self.log("startDecoding, url=\(videoURL.path), exists=\(exists), size=\(fileSize)")
        isDecodingCancelled = false
        videoSampleCount = 0
        audioSampleCount = 0
        decodeQueue.async { [weak self] in
            self?.runDecodingLoop()
        }
    }

    /// 解码循环本体。
    ///
    /// 这一段是整个文件最重要的逻辑, 详细拆解见行内注释。
    private func runDecodingLoop() {
        Self.log("runDecodingLoop begin")
        // 1) 创建 AVAsset (= mp4 文件的元数据)
        let asset = AVURLAsset(url: videoURL)

        // 2) 拿到视频总时长 (主线程更新 UI)
        let duration = asset.duration
        let totalSeconds = CMTimeGetSeconds(duration)
        Self.log("asset durationSeconds=\(totalSeconds)")
        Task { @MainActor in
            self.durationSeconds = totalSeconds.isFinite ? totalSeconds : 0
        }

        // 3) 读出所有轨道 (通常 1 视频 + 1 音频, 也可能只有视频)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            Self.log("runDecodingLoop failed: no video track")
            Task { @MainActor in
                self.statusText = "未找到视频轨道"
            }
            return
        }
        let audioTrack = asset.tracks(withMediaType: .audio).first
        hasAudioTrack = (audioTrack != nil)
        Self.log("tracks loaded, hasVideo=true, hasAudio=\(hasAudioTrack), naturalSize=\(videoTrack.naturalSize.width)x\(videoTrack.naturalSize.height)")

        guard let firstVideoFormat = videoTrack.formatDescriptions.first else {
            Self.log("runDecodingLoop failed: missing video format description")
            Task { @MainActor in
                self.statusText = "视频格式描述读取失败"
            }
            return
        }
        videoFormatDescription = firstVideoFormat as! CMFormatDescription
        if let audioTrack, let desc = audioTrack.formatDescriptions.first {
            audioStreamDescription = CMAudioFormatDescriptionGetStreamBasicDescription(desc as! CMAudioFormatDescription)?.pointee
            if let asbd = audioStreamDescription {
                Self.log("audio stream loaded, sampleRate=\(asbd.mSampleRate), channels=\(asbd.mChannelsPerFrame)")
                audioPlaybackFormat = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: asbd.mSampleRate,
                    channels: AVAudioChannelCount(asbd.mChannelsPerFrame),
                    interleaved: false
                )
                if let audioPlaybackFormat {
                    Self.log(
                        "prepared audio playback format, sampleRate=\(audioPlaybackFormat.sampleRate), channels=\(audioPlaybackFormat.channelCount), interleaved=\(audioPlaybackFormat.isInterleaved)"
                    )
                }
            }
        }

        // 4) 创建 AVAssetReader (≈ MediaExtractor)
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            Self.log("AVAssetReader init failed: \(error.localizedDescription)")
            Task { @MainActor in
                self.statusText = "无法打开视频: \(error.localizedDescription)"
            }
            return
        }

        // 5) 创建视频输出 (≈ MediaCodec.configure 时说的"我想解 H.264")
        //
        // 重要: 这里设 kCVPixelBufferPixelFormatTypeKey = kCVPixelFormatType_32BGRA
        //       iOS 内部会自动走 VideoToolbox 硬解, 把结果以 BGRA 像素格式给我们
        //       (Android 的 MediaCodec 走的是 YUV 路径, 之后才会转 RGB)
        let videoOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoOutputSettings)
        videoOutput.alwaysCopiesSampleData = false
        if reader.canAdd(videoOutput) {
            reader.add(videoOutput)
            Self.log("video output added")
        } else {
            Self.log("video output cannot be added")
        }

        // 6) 如果有音频, 创建音频输出
        //    输出的格式是 PCM 16-bit (跟 Android 的 PCM 16 一致)
        var audioOutput: AVAssetReaderTrackOutput?
        if audioTrack != nil {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVLinearPCMBitDepthKey: 16,
                AVLinearPCMIsFloatKey: false,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsNonInterleaved: false
            ]
            let out = AVAssetReaderTrackOutput(track: audioTrack!, outputSettings: audioSettings)
            out.alwaysCopiesSampleData = false
            if reader.canAdd(out) {
                reader.add(out)
                audioOutput = out
                Self.log("audio output added")
            } else {
                Self.log("audio output cannot be added")
            }
        }

        // 7) 启动 reader
        guard reader.startReading() else {
            let err = reader.error?.localizedDescription ?? "未知错误"
            Self.log("reader.startReading failed: \(err)")
            Task { @MainActor in
                self.statusText = "读取失败: \(err)"
            }
            return
        }

        // 8) 启动音频引擎 (必须在 player.scheduleBuffer 之前)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.hasAudioTrack, !self.audioEngine.isRunning {
                do {
                    self.configureAudioPlaybackFormatIfNeeded()
                    try self.audioEngine.start()
                    Self.log("audioEngine started")
                } catch {
                    Self.log("audioEngine start failed: \(error.localizedDescription)")
                    self.statusText = "音频引擎启动失败: \(error.localizedDescription)"
                }
            }
            self.isPlaying = true
            self.statusText = "正在硬解码播放…"
        }

        // 9) 启动进度条定时器
        DispatchQueue.main.async { [weak self] in
            self?.startProgressTimer()
        }

        // 10) 主循环: 反复读 video / audio sample buffer, 然后渲染
        var videoSampleBuffer: CMSampleBuffer?
        var audioSampleBuffer: CMSampleBuffer?
        var videoDone = false
        var audioDone = !hasAudioTrack  // 没音频直接视为完成
        var firstVideoPTS: Double?
        var playbackStartWallTime: CFAbsoluteTime?

        // 这段循环逻辑跟 Android 的 MediaCodec 5 阶段完全对应:
        //   阶段 A: 喂视频输入 (AVAssetReader 内部完成, 不用 dequeue)
        //   阶段 B: 喂音频输入 (同上)
        //   阶段 C: 拿视频输出 → enqueue 到 displayLayer
        //   阶段 D: 拿音频输出 → schedule 到 audioPlayer
        //   阶段 E: 检查是否全部完成
        while !isDecodingCancelled {
            // ---------- 阶段 C: 拿视频输出并显示 ----------
            if !videoDone, videoSampleBuffer == nil {
                videoSampleBuffer = videoOutput.copyNextSampleBuffer()
                if videoSampleBuffer == nil {
                    // reader 报 failure 或文件读完
                    videoDone = true
                    Self.log("video output drained, readerStatus=\(reader.status.rawValue), readerError=\(reader.error?.localizedDescription ?? "nil")")
                } else {
                    // 把这一帧丢给 displayLayer, 它会按 PTS 顺序渲染
                    // (相当于 Android 的 releaseOutputBuffer(idx, true))
                    if let buffer = videoSampleBuffer {
                        // 把这一帧的 PTS 发回主线程, 供进度条做平滑推算
                        let pts = CMSampleBufferGetPresentationTimeStamp(buffer).seconds
                        waitUntilDisplayTime(
                            pts: pts,
                            firstVideoPTS: &firstVideoPTS,
                            playbackStartWallTime: &playbackStartWallTime
                        )

                        displayLayer.enqueue(buffer)
                        videoSampleCount += 1
                        if videoSampleCount <= 3 || videoSampleCount % 30 == 0 {
                            Self.log("enqueue video sample #\(videoSampleCount), pts=\(pts)")
                        }
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            self.lastEnqueuePTS = pts
                            self.lastEnqueueWallTime = CFAbsoluteTimeGetCurrent()
                        }
                        videoSampleBuffer = nil
                    }
                }
            }

            // ---------- 阶段 D: 拿音频输出并播放 ----------
            if !audioDone, audioSampleBuffer == nil, let audioOutput {
                audioSampleBuffer = audioOutput.copyNextSampleBuffer()
                if audioSampleBuffer == nil {
                    audioDone = true
                    Self.log("audio output drained")
                } else if let buffer = audioSampleBuffer {
                    // 把 PCM 抽出来塞给 audioPlayer
                    scheduleAudioSample(buffer)
                    audioSampleBuffer = nil
                }
            }

            // ---------- 阶段 E: 检查是否完成 ----------
            if videoDone && audioDone {
                break
            }

            // 简单节流: 避免在没数据时空转占满 CPU
            // (Android 那边有 dequeueInputBuffer 10ms 超时, 这里手动等一下)
            Thread.sleep(forTimeInterval: 0.001)
        }

        // 11) 循环结束
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isPlaying = false
            self.statusText = "解码完成"
            self.stopProgressTimer()
            Self.log("decode loop finished, cancelled=\(self.isDecodingCancelled), readerStatus=\(reader.status.rawValue), videoSamples=\(self.videoSampleCount), audioSamples=\(self.audioSampleCount)")

            // 12) 循环播放: 200ms 后重启
            if self.isLooping {
                self.statusText = "循环中, 准备重新播放…"
                Self.log("looping enabled, scheduling restart")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.restartDecoding()
                }
            }
        }
    }

    // MARK: - 音频播放

    /// 按视频帧 PTS 控制 enqueue 节奏。
    ///
    /// 之前这里会出现“播放像两倍速”的原因：
    /// - `AVAssetReader.copyNextSampleBuffer()` 是按文件读取速度吐帧
    /// - CPU 读文件远快于真实播放速度
    /// - 如果读到一帧就立刻 enqueue，画面就会被快速推完
    ///
    /// Android MediaCodec 里常见写法是拿 `presentationTimeUs` 和系统时钟对齐，
    /// 到点再 `releaseOutputBuffer(index, true)`。
    /// 这里做的是同一件事：
    /// - 第一帧建立“视频 PTS”和“系统 wall time”的对应关系
    /// - 后续每帧根据 PTS 算出应该显示的时间
    /// - 如果当前时间还没到，就 sleep 等一下
    private func waitUntilDisplayTime(
        pts: Double,
        firstVideoPTS: inout Double?,
        playbackStartWallTime: inout CFAbsoluteTime?
    ) {
        guard pts.isFinite else { return }

        if firstVideoPTS == nil {
            firstVideoPTS = pts
            playbackStartWallTime = CFAbsoluteTimeGetCurrent()
            return
        }

        guard let firstVideoPTS, let playbackStartWallTime else { return }

        let targetElapsed = pts - firstVideoPTS
        guard targetElapsed > 0 else { return }

        let targetWallTime = playbackStartWallTime + targetElapsed
        let delay = targetWallTime - CFAbsoluteTimeGetCurrent()
        if delay > 0 {
            Thread.sleep(forTimeInterval: min(delay, 0.05))
        }
    }

    /// 把一帧音频 CMSampleBuffer 喂给 audioPlayer。
    ///
    /// 跟 Android 的 AudioTrack.write(chunk, 0, size) 思路一样,
    /// 只是 iOS 用 AVAudioPCMBuffer 包了一层。
    private func scheduleAudioSample(_ sampleBuffer: CMSampleBuffer) {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }

        // 把 CMBlockBuffer 转成 AVAudioPCMBuffer
        guard let pcmBuffer = makePCMBuffer(from: blockBuffer, sampleBuffer: sampleBuffer) else { return }

        // 调度到 player 队列, audioPlayer 内部按采样率节奏播放
        audioPlayer.scheduleBuffer(pcmBuffer, completionHandler: nil)
        audioSampleCount += 1
        if audioSampleCount <= 3 || audioSampleCount % 30 == 0 {
            let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
            Self.log("schedule audio sample #\(audioSampleCount), pts=\(pts), frameLength=\(pcmBuffer.frameLength)")
        }
        if !audioPlayer.isPlaying {
            audioPlayer.play()
            Self.log("audioPlayer.play()")
        }
    }

    /// 从 CMBlockBuffer 构造 AVAudioPCMBuffer。
    ///
    /// 这段代码比较偏底层, 不必完全看懂, 记住"它把 mp4 里的压缩音频
    /// 转成 AVAudioEngine 能直接播放的 PCM 格式"就行。
    private func makePCMBuffer(from blockBuffer: CMBlockBuffer, sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let format = audioPlaybackFormat else {
            Self.log("makePCMBuffer failed: audioPlaybackFormat=nil")
            return nil
        }
        let frameCount = AVAudioFrameCount(CMSampleBufferGetNumSamples(sampleBuffer))

        guard let pcm = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        pcm.frameLength = frameCount

        let length = CMBlockBufferGetDataLength(blockBuffer)
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { bytes -> OSStatus in
            guard let base = bytes.baseAddress else { return -1 }
            return CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: base)
        }
        guard status == kCMBlockBufferNoErr else { return nil }

        // 把“交错排列”的 Int16 PCM 数据拆成每个声道各自的平面 Float 数据。
        //
        // 举例：
        // - 如果源数据是双声道交错：L0 R0 L1 R1 L2 R2 ...
        // - AVAudioPCMBuffer(floatChannelData) 需要的是：
        //   ch0: L0 L1 L2 ...
        //   ch1: R0 R1 R2 ...
        //
        // 之前这里错误地参考了 `audioPlayer.outputFormat(forBus: 0)` 的声道数。
        // 如果源是单声道，但输出被系统协商成双声道，就会按错误步长读数据，
        // 听起来就会像爆音、放炮。
        data.withUnsafeBytes { rawBuffer in
            guard let src = rawBuffer.baseAddress?.assumingMemoryBound(to: Int16.self) else { return }
            if let dst = pcm.floatChannelData {
                let channelCount = Int(format.channelCount)
                let totalFrames = Int(frameCount)
                let totalSamples = rawBuffer.count / MemoryLayout<Int16>.size
                let expectedSamples = totalFrames * channelCount

                if totalSamples < expectedSamples {
                    Self.log(
                        "makePCMBuffer warning: totalSamples=\(totalSamples) < expectedSamples=\(expectedSamples), frameCount=\(totalFrames), channels=\(channelCount)"
                    )
                }

                for ch in 0..<channelCount {
                    for i in 0..<totalFrames {
                        let srcIndex = i * channelCount + ch
                        guard srcIndex < totalSamples else { break }
                        dst[ch][i] = Float(src[srcIndex]) / Float(Int16.max)
                    }
                }
            }
        }

        if audioSampleCount < 3 {
            Self.log(
                "makePCMBuffer success, frameCount=\(frameCount), sampleRate=\(format.sampleRate), channels=\(format.channelCount), interleaved=\(format.isInterleaved)"
            )
        }
        return pcm
    }

    // MARK: - 循环播放

    /// 重启解码 (用于循环播放)。
    private func restartDecoding() {
        Self.log("restartDecoding")
        displayLayer.flushAndRemoveImage()
        currentSeconds = 0
        startDecoding()
    }

    /// 用户切循环开关时调用。
    func toggleLooping(_ value: Bool) {
        isLooping = value
        Self.log("toggleLooping=\(value)")
    }

    // MARK: - 进度条

    /// 启动 0.1s 一次的进度刷新定时器。
    private func startProgressTimer() {
        stopProgressTimer()
        Self.log("startProgressTimer")
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { @MainActor [weak self] _ in
            guard let self else { return }
            // AVSampleBufferDisplayLayer 不暴露当前播放时间 (它只负责按 PTS 渲染).
            // 用"主循环最近一次 enqueue 的 PTS + 距今的 wall time"做平滑推算.
            guard self.lastEnqueuePTS > 0 else { return }
            let elapsed = CFAbsoluteTimeGetCurrent() - self.lastEnqueueWallTime
            let estimated = self.lastEnqueuePTS + elapsed
            if estimated.isFinite {
                self.currentSeconds = estimated
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        Self.log("stopProgressTimer")
    }

    // MARK: - 用户手动 seek

    /// 用户拖动进度条时调用。
    ///
    /// 注意: AVAssetReader **不支持随机 seek 到任意时间点**。
    /// 简化处理: 用户拖动后, 重新从 0 开始, 一直跑到目标时间就停。
    /// (真正的 seek 需要换成 AVPlayer, 这是 iOS 上的妥协)
    func seekTo(seconds: Double) {
        currentSeconds = seconds
        Self.log("seekTo seconds=\(seconds) (UI only, no actual seek)")
        // 简化: 这里仅更新 UI 显示, 实际不做跳转
        // 生产代码可以用 AVPlayer + AVPlayerItem.seek(to:)
    }
}
