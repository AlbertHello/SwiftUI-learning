import AVFoundation
import SwiftUI
import UIKit

/// 桥接 AVSampleBufferDisplayLayer 的 SwiftUI 包装。
///
/// 为什么不用纯 SwiftUI?
///   因为 AVSampleBufferDisplayLayer 是一个 CALayer,
///   SwiftUI 不支持直接挂 CALayer, 必须走 UIViewRepresentable。
///
/// 跟 Android 的"TextureView/SurfaceView 包成 Activity 里的 View"完全是一回事。
struct SampleBufferDisplayView: UIViewRepresentable {
    /// 由 ViewModel 持有并创建好的 displayLayer。
    let displayLayer: AVSampleBufferDisplayLayer

    func makeUIView(context: Context) -> SampleBufferHostView {
        let view = SampleBufferHostView()
        view.backgroundColor = .black
        view.attach(displayLayer: displayLayer)
        print("[SampleBufferDisplayView] makeUIView, attach displayLayer=\(ObjectIdentifier(displayLayer))")
        return view
    }

    func updateUIView(_ uiView: SampleBufferHostView, context: Context) {
        // SwiftUI 状态变化时会反复调这里。
        // displayLayer 引用是稳定的, 这里不做事。
        if uiView.attachedLayer !== displayLayer {
            uiView.attach(displayLayer: displayLayer)
            print("[SampleBufferDisplayView] updateUIView reattach displayLayer=\(ObjectIdentifier(displayLayer))")
        }
    }
}

/// 自定义 UIView, 专门承载外部传进来的 AVSampleBufferDisplayLayer。
///
/// 这里有个非常重要的坑：
/// - 不能像 CameraPreviewView 那样只重写 `layerClass`
/// - 因为 `layerClass` 会让 UIView 自己创建一个新的 AVSampleBufferDisplayLayer
/// - 但真正被 ViewModel enqueue(sampleBuffer) 的，是 ViewModel 持有的那个 displayLayer
///
/// 之前的错误写法相当于：
/// - ViewModel 往 A layer 里塞视频帧
/// - 屏幕上显示的是 UIView 自己创建的 B layer
/// - 所以日志里 sample 都 enqueue 了，但页面还是黑的
///
/// 正确做法：
/// - 直接把 ViewModel 持有的 displayLayer add 到这个 UIView 的 layer 上
/// - layoutSubviews 时同步 frame
/// - 这样 enqueue 到 A layer 的帧，屏幕上看到的也是 A layer
final class SampleBufferHostView: UIView {
    private(set) weak var attachedLayer: AVSampleBufferDisplayLayer?

    /// 把外部传入的 displayLayer 接到本 view 的 layer 上。
    func attach(displayLayer: AVSampleBufferDisplayLayer) {
        if attachedLayer === displayLayer {
            return
        }

        attachedLayer?.removeFromSuperlayer()

        displayLayer.videoGravity = .resizeAspect
        displayLayer.backgroundColor = UIColor.black.cgColor
        displayLayer.frame = bounds
        layer.addSublayer(displayLayer)
        attachedLayer = displayLayer
        print("[SampleBufferHostView] attached real displayLayer=\(ObjectIdentifier(displayLayer)), bounds=\(bounds)")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        attachedLayer?.frame = bounds
    }
}
