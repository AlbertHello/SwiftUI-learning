import SwiftUI
import CoreData
import UIKit

struct Chapter25TestingDebugView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 25,
            title: "测试与调试",
            introduction: "这一章不是只讲写测试文件，还包括让你的界面和 ViewModel 天生更容易被验证、更容易打日志、更容易被 UI 测试定位。"
        ) {
            BookDemoCard(
                title: "1. 基础预览配置",
                summary: "对应教材 Preview 调试的第一部分。你要先习惯用 Preview 快速验证不同状态下的 UI。"
            ) {
                PreviewDebugConceptDemo()
            }

            BookDemoCard(
                title: "2. 动态预览与交互调试",
                summary: "对应教材第二部分。可交互的预演有助于在真正运行前先验证状态变化。"
            ) {
                PreviewInteractionDemo()
            }

            BookDemoCard(
                title: "3. 可测试的计数器 ViewModel",
                summary: "把业务逻辑放到 ViewModel，UI 只是显示状态；同时给按钮加辅助标识符，方便 UI Test 定位。"
            ) {
                TestingDebugDemo()
            }

            BookDemoCard(
                title: "4. 测试绑定与状态",
                summary: "教材会提到：状态变化要可观测、可断言。这里用一个最小绑定链路做演示。"
            ) {
                BindingStateTestConceptDemo()
            }

            BookDemoCard(
                title: "5. UI 测试与辅助标识符",
                summary: "对应教材的 UI Test 部分。`accessibilityIdentifier` 是自动化定位控件的重要抓手。"
            ) {
                UITestIdentifierDemo()
            }

            BookDemoCard(
                title: "6. 测试金字塔实践指南",
                summary: "教材最后会强调测试层级：逻辑多做单测，关键流程做 UI Test，预览负责提升开发反馈速度。"
            ) {
                HStack {
                    MetricBadge(title: "Preview", value: "快速看 UI", tint: .orange)
                    MetricBadge(title: "单测", value: "测逻辑", tint: .blue)
                    MetricBadge(title: "UI Test", value: "测流程", tint: .green)
                }
            }

            BookTipView(
                title: "测试章节注意事项",
                points: [
                    "业务逻辑越独立，越容易写单测。",
                    "UI 测试依赖稳定标识符，不要让定位方式过于脆弱。",
                    "日志既是调试工具，也是理解状态变化的重要证据。"
                ]
            )
        }
    }
}

private struct PreviewDebugConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "静态预览", value: "看布局", tint: .orange)
            MetricBadge(title: "多状态预览", value: "看差异", tint: .blue)
            MetricBadge(title: "运行工程", value: "看真实环境", tint: .green)
        }
    }
}

private struct PreviewInteractionDemo: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("模拟交互状态", isOn: $isExpanded.animation())
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.opacity(0.16))
                .frame(height: isExpanded ? 140 : 80)
                .overlay {
                    Text(isExpanded ? "展开态" : "收起态")
                        .font(.headline)
                }
        }
    }
}

private struct TestingDebugDemo: View {
    @StateObject private var viewModel = Chapter25CounterViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前值：\(viewModel.count)")
                .font(.title2.bold())

            HStack {
                Button("加一") {
                    viewModel.increment()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("chapter25.increment")

                Button("重置") {
                    viewModel.reset()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("chapter25.reset")
            }

            Text("最近日志：\(viewModel.lastLog)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct BindingStateTestConceptDemo: View {
    @State private var nickname = "Swift Learner"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("父视图状态：\(nickname)")
                .font(.headline)
            TestingBindingChildView(name: $nickname)
        }
    }
}

private struct TestingBindingChildView: View {
    @Binding var name: String

    var body: some View {
        TextField("修改绑定值", text: $name)
            .textFieldStyle(.roundedBorder)
    }
}

private struct UITestIdentifierDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("按钮 `chapter25.increment` 可被 UI Test 稳定定位", systemImage: "checkmark.circle")
            Label("按钮 `chapter25.reset` 可被 UI Test 稳定定位", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

private final class Chapter25CounterViewModel: ObservableObject {
    @Published var count = 0
    @Published var lastLog = "暂无操作"

    func increment() {
        count += 1
        lastLog = "increment -> \(count)"
        print("Chapter25CounterViewModel increment -> \(count)")
    }

    func reset() {
        count = 0
        lastLog = "reset -> 0"
        print("Chapter25CounterViewModel reset -> 0")
    }
}

// MARK: - 第 26 章：多平台适配
