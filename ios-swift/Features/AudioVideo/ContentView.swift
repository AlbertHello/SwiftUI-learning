import AVKit
import SwiftUI

/// 主页面。
///
/// 布局目标和 Android 版保持一致：
/// - 上半区：预览摄像头 + 展示麦克风电平
/// - 下半区：播放最近一次录制完成的视频
/// - 底部：权限按钮 + 开始/停止录制按钮 + 硬解码播放按钮
///
/// 如果你是 OC/UIKit 背景，可以先这样看：
/// - `@StateObject` 有点像"页面持有的强引用控制器对象"
/// - `body` 就像"声明这个页面长什么样"
/// - 不再是 `viewDidLoad` 里 addSubview，而是状态变了，界面自动刷新
///
/// 再补两点关键的思维切换：
/// 1. `ContentView` 本身不是 `UIViewController`
///    - SwiftUI 页面通常是 `struct + View`
///    - 底层依然会有 UIKit 容器承载它，通常可以粗略理解成系统帮你包了一层
///      `UIHostingController`
///    - 只是这层容器由系统管理，业务代码一般不直接操作
/// 2. 它为什么是首页
///    - 因为在 `ios_swiftApp.swift` 的 `WindowGroup` 里，根视图就是 `ContentView()`
///    - 所以这个页面就是应用启动后首先展示的那个页面
struct ContentView: View {
    /// `@StateObject` 表示“这个 View 自己拥有并持有这个对象”。
    ///
    /// 为什么这里要用它：
    /// - `ContentView` 是值类型 struct，SwiftUI 在刷新界面时可能反复重建这个 View
    /// - 但我们不希望 `CameraRecorderViewModel` 跟着被反复重建
    /// - `@StateObject` 会保证这个对象的生命周期稳定，适合作为页面级状态持有者
    ///
    /// 粗略类比 OC：
    /// - 有点像 `UIViewController` 持有一个强引用的业务控制器 / viewModel 属性
    /// - 只要这个页面还活着，这个对象就尽量保持同一份实例
    @StateObject private var viewModel = CameraRecorderViewModel()

    /// 控制是否展示硬解码播放子页面。
    ///
    /// iOS 这里跟 Android 的 startActivity(Intent) 等价。
    /// Android 要写 3 行: Intent + putExtra + startActivity
    /// iOS 用 sheet 一行搞定 (iOS 15+ 写法)
    @State private var showCodecPlayer: Bool = false

    private static func log(_ message: String) {
        print("[ContentView] \(message)")
    }

    /// `body` 是 SwiftUI 的核心。
    ///
    /// 它不是“只执行一次的 viewDidLoad”，而是：
    /// - 每当依赖的状态发生变化
    /// - SwiftUI 就会重新计算 `body`
    /// - 然后决定界面哪些地方需要刷新
    ///
    /// 所以这里更像是在“声明界面长什么样”，而不是“手动搭 View 树”。
    ///
    /// `some View` 的意思是：
    /// - 返回某个具体的 View 类型
    /// - 但把具体类型名隐藏起来
    /// - 编译器仍然知道真实类型，只是你不用手写那个很长的泛型名字
    ///
    /// 这和 `id` / `id<Protocol>` 不完全一样：
    /// - `some View` 仍然是强类型、编译期可知
    /// - 只是把“具体类型名”省略掉了
    var body: some View {
        /// `VStack` = Vertical Stack，表示“垂直堆叠布局”。
        ///
        /// 你可以把它理解成：
        /// - Flutter 的 `Column`
        /// - UIKit 里的垂直 `UIStackView`
        ///
        /// 它会把里面的子 View 从上到下排开。
        /// 这里的 `alignment: .leading` 表示左对齐，
        /// `spacing: 16` 表示每个子 View 之间间距 16。
        VStack(alignment: .leading, spacing: 16) {
            /// `VStack` 大括号里的每一项都会按“独占一行”的方式自上而下排列。
            ///
            /// 这里这一段可以顺着读成：
            /// - 第一行：标题文本
            /// - 第二行：状态文本
            /// - 第三行：预览区标题
            /// - 第四行：`previewPanel`
            /// - 第五行：回放区标题
            /// - 第六行：`playbackPanel`
            /// - 第七行：`controlPanel`
            /// - 第八行：跳转按钮
            Text("iOS 音视频采集/回放 Demo")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(viewModel.statusText)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))

            Text("窗口 1：AVCaptureSession 预览 + 麦克风电平")
                .font(.headline)
                .foregroundStyle(.white)

            /// `previewPanel` 虽然看起来像一个普通变量，
            /// 但它本质上是一个“返回 View 的计算属性”：
            /// `private var previewPanel: some View { ... }`
            ///
            /// 所以把它直接写在这里时，可以理解成：
            /// - SwiftUI 读取这个属性
            /// - 得到一段子 UI
            /// - 再把这段子 UI 塞进当前 `VStack`
            ///
            /// 它不需要你像 UIKit 那样先 `alloc/init` 再 `addSubview`，
            /// 因为这里不是在手动操作真实视图树，
            /// 而是在“声明当前界面应该长什么样”。
            previewPanel

            Text("窗口 2：AVPlayer 最新文件回放")
                .font(.headline)
                .foregroundStyle(.white)

            playbackPanel

            controlPanel

            // 硬解码播放跳转按钮
            Button {
                Self.log("点击进入硬解码播放页, latestRecordingURL=\(viewModel.latestRecordingURL?.path ?? "nil")")
                showCodecPlayer = true
            } label: {
                Text("进入 MediaCodec 解码播放")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FilledCapsuleButtonStyle(backgroundColor: .indigo))
            .disabled(viewModel.latestRecordingURL == nil)
        }
        /// 下面这一串 `.padding / .frame / .background` 是在修饰谁？
        ///
        /// 是在修饰“前面整个 `VStack { ... }` 生成出来的那个 View”。
        /// 你可以把它理解成：
        /// - 先得到一个垂直布局容器
        /// - 再继续给这个容器加内边距、尺寸约束、背景色
        ///
        /// 也就是说，这几个 modifier 描述的是当前 `body` 最外层这块内容，
        /// 不是只修饰某一个 `Text`，也不是在单独定义别的对象。
        .padding(16)
        /// `padding(16)` 是“内容到自己边界”的内边距。
        ///
        /// 这里可以粗略理解成：
        /// - `VStack` 里面那一整坨内容
        /// - 距离 `VStack` 外边框四周都留 16pt 空白
        ///
        /// 更像 UIKit 里“父容器内部 contentInset / layoutMargins”的感觉，
        /// 不是两个兄弟 View 之间的间距。
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        /// `frame(...)` 是继续给这个最外层 View 提供尺寸和对齐约束。
        ///
        /// 这里不是说“body 这个语法对象有一个固定像素大小”，
        /// 而是说：
        /// - 希望这块最外层内容尽量撑满父容器提供的宽高
        /// - 多出来的空间里，把内容对齐到顶部 (`alignment: .top`)
        ///
        /// 所以可以先粗略理解成：
        /// “让当前页面主容器尽量铺满屏幕，并把内容顶到上面”
        .background(Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255))
        /// `background(...)` 也是加在这个最外层 View 上。
        ///
        /// 因为它写在 `.frame(...)` 后面，所以你可以把它理解成：
        /// - 先把最外层容器撑开
        /// - 再给撑开后的这块区域铺一个背景色
        ///
        /// 最终看到的就是整个页面主区域的深色背景。
        /// `onAppear` 可以先粗略理解成：
        /// - 页面进入屏幕范围时触发
        /// - 语义上接近 `viewWillAppear/viewDidAppear`
        ///
        /// 但它和 UIKit 生命周期不是 1:1 严格对应：
        /// - SwiftUI View 是值类型，可能被重建
        /// - 所以不要把它机械地当成唯一一次初始化入口
        ///
        /// 更稳妥的经验是：
        /// - “页面出现时要做的事”放这里
        /// - “只想创建一次的对象”放 `@StateObject`
        /// - “应用级前后台切换”看 `scenePhase`
        .onAppear {
            Self.log("onAppear")
            viewModel.onAppear()
        }
        /// `onDisappear` 粗略对应 `viewWillDisappear/viewDidDisappear`。
        ///
        /// 适合在这里做：
        /// - 停止预览
        /// - 释放临时资源
        /// - 停止监听 / 定时器
        ///
        /// 也同样不要把它当成 UIKit 那种绝对稳定、严格单次配对的回调去理解。
        .onDisappear {
            Self.log("onDisappear")
            viewModel.onDisappear()
        }
        .onChange(of: showCodecPlayer) { _, newValue in
            Self.log("showCodecPlayer changed: \(newValue), latestRecordingURL=\(viewModel.latestRecordingURL?.path ?? "nil")")
            if newValue {
                viewModel.pausePreviewPlaybackForCodecPage()
            } else {
                viewModel.resumePreviewPlaybackAfterCodecPage()
            }
        }
        // iOS 15+ 的 sheet 写法, 相当于 Android 的 startActivity
        .sheet(isPresented: $showCodecPlayer) {
            if let url = viewModel.latestRecordingURL {
                CodecPlayerView(videoURL: url)
            } else {
                Text("没有可用的录制文件")
                    .foregroundStyle(.white)
            }
        }
    }

    /// 这种 `private var xxx: some View` 不是新页面，而是把大页面拆成小片段。
    ///
    /// 目的主要是两个：
    /// - 让 `body` 更短、更好读
    /// - 把一段相对独立的 UI 描述抽出来复用或维护
    ///
    /// 它仍然只是 `ContentView` 的一部分，类似你在 UIKit 里把一块 UI 抽成
    /// `makePreviewPanel()` 或一个私有子 view。
    private var previewPanel: some View {
        /// `ZStack` = Z-axis Stack，表示“沿 Z 轴叠放”。
        ///
        /// 和 `VStack` / `HStack` 不同，它不是上下排、也不是左右排，
        /// 而是把多个子 View 一层一层盖在一起。
        ///
        /// 你可以把它理解成：
        /// - Flutter 的 `Stack`
        /// - UIKit 里多个 subview 叠加在同一个父 view 上
        ///
        /// 这里的写法就是：
        /// - 底层先放摄像头预览
        /// - 上层再盖一层文字和进度条说明
        ZStack(alignment: .bottomLeading) {
            CameraPreviewView(session: viewModel.session)
                .frame(maxWidth: .infinity)
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("预览摄像头画面。录制时下面的进度条会实时显示麦克风电平。")
                    .font(.caption)
                    .foregroundStyle(.white)

                ProgressView(value: viewModel.audioLevel, total: 1)
                    .tint(.green)

                Text("麦克风电平：\(Int(viewModel.audioLevel * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.58)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .background(Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var playbackPanel: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let player = viewModel.player {
                    VideoPlayer(player: player)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "video.slash")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.8))
                        Text("还没有录到视频。点击开始录制，停止后会自动回放。")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(9.0 / 16.0, contentMode: .fit)

            Text(viewModel.latestRecordingURL?.path ?? "最近一次录制文件路径会显示在这里")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.85))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .background(Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var controlPanel: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.requestPermissionsAndStartIfPossible()
            } label: {
                Text(viewModel.hasFullPermission ? "权限已授予" : "申请权限")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FilledCapsuleButtonStyle(backgroundColor: .teal))
            .disabled(viewModel.hasFullPermission)

            Button {
                viewModel.toggleRecording()
            } label: {
                Text(viewModel.isRecording ? "停止录制" : "开始录制")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(FilledCapsuleButtonStyle(backgroundColor: .green))
            .disabled(!viewModel.hasFullPermission)
        }
    }
}

/// 给两个底部按钮统一一个样式，避免 ContentView 里被重复修饰器淹没。
struct FilledCapsuleButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .font(.body.weight(.semibold))
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// `#Preview` 只给 Xcode 预览面板使用，不参与 App 正式启动流程。
///
/// 它的作用是：
/// - 在右侧 Canvas 里快速渲染这个页面
/// - 方便改 UI 时实时预览
/// - 不用每次都完整运行整个 App
///
/// 所以要区分两个概念：
/// - `WindowGroup { ContentView() }`：决定应用真正启动后先显示谁
/// - `#Preview { ContentView() }`：决定 Xcode 预览面板里展示谁
//#Preview {
//    ContentView()
//}
