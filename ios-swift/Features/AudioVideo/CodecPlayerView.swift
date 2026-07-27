import SwiftUI

/// 硬解码播放页面。
///
/// 跟 Android 那边 `CodecPlayerActivity` 的布局完全对应:
///
///   Android                                iOS (这里)
///   ─────────                              ─────────
///   activity_codec_player.xml              CodecPlayerView
///   SurfaceView                            SampleBufferDisplayView
///   "硬解码播放" Button                     Button(action: startDecode)
///   "软解码播放" Button                     Button(action: showToast)
///   "循环播放" Switch                       Toggle(isOn: $isLooping)
///   SeekBar + TextView                     Slider + Text(currentSeconds)
struct CodecPlayerView: View {
    private static func log(_ message: String) {
        print("[CodecPlayerView] \(message)")
    }

    /// 视频文件 URL (从主页面传过来)。
    let videoURL: URL

    /// 用 @StateObject 持有 ViewModel, 跟 Android 的字段引用是同一个意思。
    ///
    /// 注意这里用了一个 trick:
    ///   @StateObject 的初始化需要参数, 但 @StateObject 不支持带参数 init
    ///   所以我们用 _viewModel = StateObject(wrappedValue:) 显式构造
    @StateObject private var viewModel: CodecPlayerViewModel

    /// 软解按钮点击后, 弹一个提示。
    @State private var softDecodeAlertMessage: String = "iOS 软解码需要集成 FFmpegKit, 当前 Demo 暂未启用。"

    /// 控制弹窗显示。
    @State private var showSoftDecodeAlert: Bool = false

    init(videoURL: URL) {
        self.videoURL = videoURL
        // 显式构造 @StateObject, 把 videoURL 传进 ViewModel
        _viewModel = StateObject(wrappedValue: CodecPlayerViewModel(videoURL: videoURL))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 顶部标题
            Text("MediaCodec 硬解码播放")
                .font(.title2.bold())
                .foregroundStyle(.white)

            // 状态文案
            Text(viewModel.statusText)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))

            // 文件路径
            Text("视频源: \(videoURL.lastPathComponent)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)

            // 显示区域
            displayPanel

            // 进度条
            progressPanel

            // 循环播放开关
            Toggle(isOn: Binding(
                get: { viewModel.isLooping },
                set: { viewModel.toggleLooping($0) }
            )) {
                Text("循环播放")
                    .foregroundStyle(.white)
            }
            .tint(.green)

            // 两个解码按钮
            HStack(spacing: 12) {
                Button {
                    Self.log("点击硬解码播放按钮")
                    viewModel.onAppear()
                } label: {
                    Text("硬解码播放")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledCapsuleButtonStyle(backgroundColor: .blue))
                .disabled(viewModel.isPlaying)

                Button {
                    showSoftDecodeAlert = true
                } label: {
                    Text("软解码播放")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(FilledCapsuleButtonStyle(backgroundColor: .gray))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255))
        .onAppear {
            Self.log("onAppear, videoURL=\(videoURL.path)")
            viewModel.onAppear()
        }
        .onDisappear {
            Self.log("onDisappear")
            viewModel.onDisappear()
        }
        .alert("软解码未启用", isPresented: $showSoftDecodeAlert) {
            Button("好") { }
        } message: {
            Text(softDecodeAlertMessage)
        }
    }

    // MARK: - 子 View

    /// 显示区域: 把 AVSampleBufferDisplayLayer 嵌进 SwiftUI。
    private var displayPanel: some View {
        SampleBufferDisplayView(displayLayer: viewModel.displayLayer)
            .frame(maxWidth: .infinity)
            .aspectRatio(9.0 / 16.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background(Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255))
    }

    /// 进度条 + 时间文字。
    private var progressPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Slider(
                value: Binding(
                    get: { viewModel.currentSeconds },
                    set: { viewModel.seekTo(seconds: $0) }
                ),
                in: 0...max(viewModel.durationSeconds, 0.001)
            )
            .tint(.green)
            .disabled(viewModel.durationSeconds <= 0)

            HStack {
                Text(formatTime(viewModel.currentSeconds))
                Spacer()
                Text(formatTime(viewModel.durationSeconds))
            }
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.white.opacity(0.8))
        }
    }

    /// 把秒数格式化成 mm:ss。
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "00:00" }
        let total = Int(seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    // Preview 里用 sandbox 里的占位文件, 跑不起来没关系, 主要看 UI
    CodecPlayerView(
        videoURL: URL(fileURLWithPath: "/tmp/preview.mov")
    )
}
