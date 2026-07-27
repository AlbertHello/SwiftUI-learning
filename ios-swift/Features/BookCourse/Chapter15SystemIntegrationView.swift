import SwiftUI
import CoreData
import UIKit

struct Chapter15SystemIntegrationView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 15,
            title: "系统集成",
            introduction: "不是所有组件都必须重写成纯 SwiftUI。遇到 UIKit 现成能力时，可以用 `UIViewRepresentable` 做桥接，这对老项目渐进迁移特别实用。"
        ) {
            BookDemoCard(
                title: "1. 示例：UIActivityIndicatorView 集成",
                summary: "对应教材里的 UIKit 示例。先用一个最小案例理解 `UIViewRepresentable`。"
            ) {
                ActivityIndicatorBridgeDemo()
            }

            BookDemoCard(
                title: "2. 生命周期与数据流",
                summary: "对应教材里 `makeUIView / updateUIView / Coordinator` 的角色说明。这个卡片帮你把桥接生命周期一眼看清。"
            ) {
                RepresentableLifecycleDemo()
            }

            BookDemoCard(
                title: "3. 示例：可编辑文本视图",
                summary: "对应教材里的“可编辑文本视图”场景。虽然 HTML 写的是 NSTextView，但在 iOS 工程里我们用 UITextView 做同类桥接学习。"
            ) {
                EditableUIKitTextDemo()
            }

            BookDemoCard(
                title: "4. AppKit / WatchKit 位置感",
                summary: "当前工程运行在 iOS，所以不能直接跑 AppKit / WatchKit 组件，但教材里的平台分工你还是要有概念。"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MetricBadge(title: "iOS", value: "UIViewRepresentable", tint: .blue)
                        MetricBadge(title: "macOS", value: "NSViewRepresentable", tint: .purple)
                        MetricBadge(title: "watchOS", value: "协同容器", tint: .green)
                    }
                    Text("你现在先把模式学会最重要：SwiftUI 是外层声明式壳子，平台原生视图通过 representable 方式被包进来。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            BookTipView(
                title: "桥接时要关注",
                points: [
                    "`makeUIView` 类似 UIKit 的初始化阶段。",
                    "`updateUIView` 类似把 SwiftUI 最新状态同步回 UIKit 视图。",
                    "如果 UIKit 组件有回调，要通过 `Coordinator` 把事件再传回 SwiftUI。"
                ]
            )
        }
    }
}

private struct ActivityIndicatorBridgeDemo: View {
    @State private var isAnimating = true

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ActivityIndicatorRepresentable(isAnimating: isAnimating, tintColor: .systemBlue)
                    .frame(width: 44, height: 44)

                Toggle("转圈动画", isOn: $isAnimating)
            }

        }
    }
}

private struct RepresentableLifecycleDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "创建原生视图", value: "makeUIView", tint: .blue)
                MetricBadge(title: "同步新状态", value: "updateUIView", tint: .purple)
                MetricBadge(title: "原生回调回传", value: "Coordinator", tint: .green)
            }

            Text("如果你是 UIKit 背景，可以这样记：`makeUIView` 像初始化，`updateUIView` 像给已有实例重新赋值，`Coordinator` 像 delegate/target 的桥。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct EditableUIKitTextDemo: View {
    @State private var notes = "这里是 UIKit 的 UITextView，通过 Coordinator 把内容回写给 SwiftUI。"

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            UIKitTextViewRepresentable(text: $notes)
                .frame(height: 130)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                }

            Text("当前文字长度：\(notes.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ActivityIndicatorRepresentable: UIViewRepresentable {
    let isAnimating: Bool
    let tintColor: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.color = tintColor
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        uiView.color = tintColor
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

private struct UIKitTextViewRepresentable: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
    }
}

// MARK: - 第 16 章：场景与窗口
