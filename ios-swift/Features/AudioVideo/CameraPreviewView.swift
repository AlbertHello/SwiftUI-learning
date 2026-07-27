import AVFoundation
import SwiftUI
import UIKit

/// 一个专门承载 `AVCaptureVideoPreviewLayer` 的 UIView。
///
/// 为什么这里不用纯 SwiftUI 直接画？
/// 因为相机预览本质上还是 `CALayer`/`UIView` 体系里的能力：
/// - `AVCaptureVideoPreviewLayer` 负责把 AVCaptureSession 的视频帧显示出来
/// - SwiftUI 通过 `UIViewRepresentable` 把这个 UIKit View 包进来
///
/// 对有 OC/UIKit 背景的人来说，可以把它理解成：
/// “写一个普通 UIView，然后在它的 layer 上挂相机预览层，再嵌回 SwiftUI 页面。”
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // SwiftUI 在状态更新时会反复调用这里。
        // 只要 session 变了，就把新的 session 绑定给 previewLayer。
        uiView.previewLayer.session = session
    }
}

/// 一个自定义 UIView，把自己的底层 layer 类型改成 AVCaptureVideoPreviewLayer。
///
/// 这是一种非常经典的写法：
/// - 默认 UIView 的 layer 是 CALayer
/// - 重写 `layerClass` 后，这个 View 的底层 layer 就直接变成了 AVCaptureVideoPreviewLayer
/// - 这样你就不需要再手动 addSublayer 了
final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("PreviewView 的底层 layer 必须是 AVCaptureVideoPreviewLayer。")
        }
        return layer
    }
}
