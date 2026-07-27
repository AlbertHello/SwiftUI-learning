import AVFoundation
import AVKit
import Foundation

/// 负责管理“相机预览 + 音视频录制 + 麦克风电平 + 最新文件回放”的核心对象。
///
/// 如果你有 OC 背景，可以把它粗略理解成一个“带状态的控制器对象”：
/// - 维护 AVCaptureSession
/// - 配置输入输出
/// - 处理录制生命周期
/// - 把结果通过 `@Published` 暴露给 SwiftUI 页面
///
/// 虽然名字叫 ViewModel，但它不是纯 MVVM 教科书意义上的瘦模型。
/// 这里更偏“教学型聚合对象”，目的是把链路集中到一个文件里，便于阅读。
final class CameraRecorderViewModel: NSObject, ObservableObject {
    private static func log(_ message: String) {
        print("[CameraRecorder] \(message)")
    }

    // MARK: - 对外暴露给 SwiftUI 的状态

    /// 用来驱动预览层的采集会话。
    let session = AVCaptureSession()

    /// 页面顶部状态文案。
    @Published var statusText = "等待相机和麦克风权限"

    /// 当前是否已经拿到相机和麦克风权限。
    @Published var hasFullPermission = false

    /// 当前是否正在录制。
    @Published var isRecording = false

    /// 最近一次录制完成的视频文件地址。
    @Published var latestRecordingURL: URL?

    /// 麦克风电平，范围 0...1，用于驱动 ProgressView。
    @Published var audioLevel: Double = 0

    /// 播放器使用 AVQueuePlayer，是为了方便把最新录制文件设置成循环播放。
    @Published var player: AVQueuePlayer?

    // MARK: - 内部对象

    /// 相机会话和输入输出配置都放到这条串行队列，避免线程竞争。
    private let sessionQueue = DispatchQueue(label: "com.example.ios-swift.session")

    /// AudioDataOutput 的回调也放在同一条队列，便于统一处理采集链路状态。
    private let audioLevelQueue = DispatchQueue(label: "com.example.ios-swift.audio-level")

    /// 真正的视频录制输出对象。
    ///
    /// 这里没有直接上 AVAssetWriter / CMSampleBuffer 手写封装，
    /// 而是先用 AVCaptureMovieFileOutput 跑通“最小录制闭环”。
    private let movieOutput = AVCaptureMovieFileOutput()

    /// 额外加一个音频数据输出，只为了计算麦克风电平。
    ///
    /// 注意：
    /// - 录制文件本身的音频来自 movieOutput
    /// - audioDataOutput 这里只做“监听音量”，不负责写文件
    private let audioDataOutput = AVCaptureAudioDataOutput()

    /// 记住当前是否已经配置过 session，避免重复 addInput/addOutput。
    private var didConfigureSession = false

    /// 记录当前真正使用的视频输入，后面如果要做切前后摄、对焦控制，就从这里往下扩展。
    private var videoInput: AVCaptureDeviceInput?

    /// 记录当前音频输入。
    private var audioInput: AVCaptureDeviceInput?

    /// 用于让 AVQueuePlayer 无限循环播放最新录制文件。
    private var playerLooper: AVPlayerLooper?

    // MARK: - 生命周期入口

    /// 页面出现时调用。
    ///
    /// 逻辑顺序：
    /// 1. 先检查/申请权限
    /// 2. 权限齐了再配置 session
    /// 3. 最后启动 session，让预览真正跑起来
    func onAppear() {
        Self.log("onAppear")
        requestPermissionsAndStartIfPossible()
    }

    /// 页面消失时调用。
    ///
    /// 相机和录制属于重资源对象，页面离开就停掉，避免后台继续占相机麦克风。
    func onDisappear() {
        Self.log("onDisappear")
        stopRecordingIfNeeded()
        stopSession()
    }

    // MARK: - 权限

    /// 主动申请相机和麦克风权限。
    ///
    /// iOS 里权限是按资源类型分别管理的，
    /// 所以这里要分别检查 video 和 audio 两种媒体类型。
    func requestPermissionsAndStartIfPossible() {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        Self.log("requestPermissionsAndStartIfPossible, videoStatus=\(videoStatus.rawValue), audioStatus=\(audioStatus.rawValue)")

        if videoStatus == .authorized && audioStatus == .authorized {
            DispatchQueue.main.async {
                self.hasFullPermission = true
                self.statusText = "权限已授予，准备启动采集"
            }
            configureSessionIfNeededAndStart()
            return
        }

        requestAccess(for: .video) { [weak self] videoGranted in
            guard let self else { return }
            self.requestAccess(for: .audio) { [weak self] audioGranted in
                guard let self else { return }

                let granted = videoGranted && audioGranted
                DispatchQueue.main.async {
                    self.hasFullPermission = granted
                    self.statusText = granted
                        ? "权限已授予，准备启动采集"
                        : "缺少相机或麦克风权限，请到系统设置里打开"
                }

                if granted {
                    self.configureSessionIfNeededAndStart()
                }
            }
        }
    }

    /// 对 `AVCaptureDevice.requestAccess` 做一层统一封装。
    ///
    /// 这样写有两个好处：
    /// 1. 业务代码不需要反复写 switch
    /// 2. 对 `authorized` / `notDetermined` / `denied` 三种状态的处理更集中
    private func requestAccess(
        for mediaType: AVMediaType,
        completion: @escaping (Bool) -> Void
    ) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            Self.log("requestAccess \(mediaType.rawValue): already authorized")
            completion(true)
        case .notDetermined:
            Self.log("requestAccess \(mediaType.rawValue): requesting system permission")
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: completion)
        case .denied, .restricted:
            Self.log("requestAccess \(mediaType.rawValue): denied/restricted")
            completion(false)
        @unknown default:
            Self.log("requestAccess \(mediaType.rawValue): unknown default")
            completion(false)
        }
    }

    // MARK: - Session 配置

    /// 只在第一次真正需要时配置 session。
    ///
    /// 这是 AVCaptureSession 使用中的常规优化：
    /// - 输入输出只加一次
    /// - 后续页面切回来，只需要 startRunning 即可
    private func configureSessionIfNeededAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            Self.log("configureSessionIfNeededAndStart on sessionQueue, didConfigureSession=\(self.didConfigureSession)")

            if !self.didConfigureSession {
                self.configureSession()
            }

            self.startSession()
        }
    }

    /// 真正的采集链路配置入口。
    ///
    /// 这里做的事，本质上和 Android Camera2 的“选设备 + 配输出”非常像：
    /// 1. 找到后置摄像头和麦克风
    /// 2. 创建 input
    /// 3. 把 input 加到 session
    /// 4. 创建 output
    /// 5. 把 output 加到 session
    ///
    /// 对应到 iOS 传统理解，可以把 `AVCaptureSession` 看成一条可配置的媒体 pipeline。
    private func configureSession() {
        guard !didConfigureSession else { return }
        Self.log("configureSession begin")

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .high

        do {
            let backCamera = try makeBackCameraInput()
            if session.canAddInput(backCamera) {
                session.addInput(backCamera)
                videoInput = backCamera
                Self.log("added video input: \(backCamera.device.localizedName)")
            }

            let microphone = try makeMicrophoneInput()
            if session.canAddInput(microphone) {
                session.addInput(microphone)
                audioInput = microphone
                Self.log("added audio input: \(microphone.device.localizedName)")
            }

            if session.canAddOutput(movieOutput) {
                session.addOutput(movieOutput)
                Self.log("added movie output")

                // 录制链路里尽量开启稳定功能，减少手持场景抖动。
                if let videoConnection = movieOutput.connection(with: .video),
                   videoConnection.isVideoStabilizationSupported {
                    videoConnection.preferredVideoStabilizationMode = .auto
                    Self.log("enabled video stabilization: auto")
                }
            }

            if session.canAddOutput(audioDataOutput) {
                session.addOutput(audioDataOutput)
                Self.log("added audio data output for level metering")

                // 音频数据输出只负责拿到 PCM 样本，计算当前麦克风能量。
                audioDataOutput.setSampleBufferDelegate(self, queue: audioLevelQueue)
            }

            didConfigureSession = true
            Self.log("configureSession success")
            DispatchQueue.main.async {
                self.statusText = "采集链路配置完成，可以开始预览和录制"
            }
        } catch {
            Self.log("configureSession failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.statusText = "初始化采集链路失败：\(error.localizedDescription)"
            }
        }
    }

    private func makeBackCameraInput() throws -> AVCaptureDeviceInput {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw NSError(
                domain: "CameraRecorderViewModel",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "没有找到后置摄像头。"]
            )
        }
        return try AVCaptureDeviceInput(device: device)
    }

    private func makeMicrophoneInput() throws -> AVCaptureDeviceInput {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            throw NSError(
                domain: "CameraRecorderViewModel",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "没有找到麦克风。"]
            )
        }
        return try AVCaptureDeviceInput(device: device)
    }

    /// 启动采集会话。
    ///
    /// iOS 这里的 `startRunning()` 很像“整条采集管线开始流动”：
    /// - 预览层会开始收到视频帧
    /// - 音频输出会开始收到 PCM 数据
    /// - 录制输出也随时可以开始写文件
    private func startSession() {
        guard !session.isRunning else { return }
        Self.log("startSession")
        session.startRunning()
        DispatchQueue.main.async {
            self.statusText = "摄像头预览已启动"
        }
    }

    /// 停止采集会话。
    private func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.session.isRunning else { return }
            Self.log("stopSession")
            self.session.stopRunning()
        }
    }

    // MARK: - 录制控制

    /// 供按钮点击调用的统一入口。
    func toggleRecording() {
        Self.log("toggleRecording, isRecording=\(isRecording), hasFullPermission=\(hasFullPermission)")
        isRecording ? stopRecordingIfNeeded() : startRecording()
    }

    /// 开始录制。
    ///
    /// `AVCaptureMovieFileOutput` 的使用思路比 Android `MediaRecorder` 更接近：
    /// - 先把 input/output 全配进 session
    /// - 再调用 `startRecording`
    /// - 数据会被直接封装成 mov 文件
    private func startRecording() {
        guard hasFullPermission else {
            Self.log("startRecording blocked: no permission")
            statusText = "没有权限，无法开始录制"
            return
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard !self.movieOutput.isRecording else { return }

            let outputURL = self.makeRecordingURL()
            let existsBefore = FileManager.default.fileExists(atPath: outputURL.path)
            Self.log("startRecording to \(outputURL.path), existsBefore=\(existsBefore)")

            // iOS 视频文件录制默认得到的是 .mov。
            // 这是 AVFoundation 非常常见的默认输出格式，后续如需 mp4，可以再加转封装流程。
            self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)

            DispatchQueue.main.async {
                self.statusText = "正在录制音视频，停止后会自动回放"
                self.isRecording = true
            }
        }
    }

    /// 停止录制。
    ///
    /// 真正的录制结束结果，要等 `fileOutput(_:didFinishRecordingTo:...)` 回调。
    private func stopRecordingIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.movieOutput.isRecording else { return }
            Self.log("stopRecordingIfNeeded")
            self.movieOutput.stopRecording()
        }
    }

    /// 生成录制文件输出地址。
    ///
    /// 文件放到 app 沙盒的 Documents 目录下，便于调试和 Finder/Xcode 容器查看。
    private func makeRecordingURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = "capture_\(formatter.string(from: Date())).mov"
        return documentsURL.appendingPathComponent(filename)
    }

    // MARK: - 播放器

    /// 用最新录制完成的文件重建循环播放器。
    ///
    /// 这里选择 AVQueuePlayer + AVPlayerLooper，而不是普通 AVPlayer：
    /// - 普通 AVPlayer 可以播
    /// - 但如果你想“自动无缝循环”，AVPlayerLooper 更直接
    private func prepareLoopingPlayer(with url: URL) {
        Self.log("prepareLoopingPlayer with url=\(url.path)")
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        playerLooper = looper
        player = queuePlayer
        Self.log("looping player ready, itemStatus=\(item.status.rawValue)")
        queuePlayer.play()
    }

    /// 进入硬解码播放页时暂停主页面的循环播放器。
    ///
    /// 为什么需要这个：
    /// - 主页面录制完成后会用 AVQueuePlayer 循环播放最新文件
    /// - 子页面也会自己解码并播放同一个文件
    /// - 如果不暂停主页面播放器，就会出现两路音频同时播放，听起来像杂音/重音
    func pausePreviewPlaybackForCodecPage() {
        Self.log("pausePreviewPlaybackForCodecPage")
        player?.pause()
    }

    /// 从硬解码播放页回来时恢复主页面循环播放。
    ///
    /// 这里只在已有播放器时恢复，不会主动新建播放器。
    func resumePreviewPlaybackAfterCodecPage() {
        Self.log("resumePreviewPlaybackAfterCodecPage")
        player?.play()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraRecorderViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        Self.log("didStartRecordingTo \(fileURL.path)")
        DispatchQueue.main.async {
            self.statusText = "开始写入文件：\(fileURL.lastPathComponent)"
        }
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        Self.log("didFinishRecordingTo \(outputFileURL.path), error=\(error?.localizedDescription ?? "nil")")
        DispatchQueue.main.async {
            self.isRecording = false
        }

        if let error {
            DispatchQueue.main.async {
                self.statusText = "录制失败：\(error.localizedDescription)"
                self.audioLevel = 0
            }
            return
        }

        let exists = FileManager.default.fileExists(atPath: outputFileURL.path)
        let fileSize: Int64 = (try? FileManager.default.attributesOfItem(atPath: outputFileURL.path)[.size] as? Int64) ?? -1
        Self.log("recorded file exists=\(exists), size=\(fileSize) bytes")

        DispatchQueue.main.async {
            self.latestRecordingURL = outputFileURL
            self.statusText = "录制完成，正在循环回放最新视频"
            self.audioLevel = 0
            self.prepareLoopingPlayer(with: outputFileURL)
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate

extension CameraRecorderViewModel: AVCaptureAudioDataOutputSampleBufferDelegate {

    /// 通过 PCM 音频样本计算一个简单的麦克风电平。
    ///
    /// 这段逻辑和 Android 版通过 `getMaxAmplitude()` 做电平条是同一个目的：
    /// 不追求专业音频分析，只追求“看得见麦克风正在工作”。
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard output == audioDataOutput else { return }
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }

        let length = CMBlockBufferGetDataLength(blockBuffer)
        guard length > 0 else { return }

        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { bytes in
            guard let baseAddress = bytes.baseAddress else {
                return kCMBlockBufferBadCustomBlockSourceErr
            }
            return CMBlockBufferCopyDataBytes(
                blockBuffer,
                atOffset: 0,
                dataLength: length,
                destination: baseAddress
            )
        }

        guard status == kCMBlockBufferNoErr else { return }

        let level = data.withUnsafeBytes { rawBuffer -> Double in
            let sampleBuffer = rawBuffer.bindMemory(to: Int16.self)
            guard !sampleBuffer.isEmpty else { return 0 }

            // 做一个很简单的均方根能量估算，再映射到 0...1。
            var sum: Double = 0
            for sample in sampleBuffer {
                let normalized = Double(sample) / Double(Int16.max)
                sum += normalized * normalized
            }
            let rms = sqrt(sum / Double(sampleBuffer.count))

            // 对 UI 来说太小的数看不出变化，这里做一点拉伸。
            return min(max(rms * 8, 0), 1)
        }

        DispatchQueue.main.async {
            self.audioLevel = level
        }
    }
}
