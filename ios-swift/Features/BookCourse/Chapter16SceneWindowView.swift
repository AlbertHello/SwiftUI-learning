import SwiftUI
import CoreData
import UIKit

struct Chapter16SceneWindowView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        BookChapterScaffold(
            chapter: 16,
            title: "场景与窗口",
            introduction: "这一章更偏应用架构。你已经学过 `App`、`WindowGroup` 了，这里继续往上走，理解“为什么 SwiftUI 把应用拆成多个 Scene”。"
        ) {
            BookDemoCard(
                title: "1. WindowGroup 的关键特性",
                summary: "对应教材里的第一块重点：WindowGroup 是 SwiftUI 应用最常见的场景入口。"
            ) {
                WindowGroupFeatureDemo()
            }

            BookDemoCard(
                title: "2. 当前 Scene 状态观察",
                summary: "虽然当前 demo 工程不是多窗口应用，但你已经可以观察 scenePhase 的变化。"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        MetricBadge(title: "当前 scenePhase", value: phaseText(scenePhase), tint: .indigo)
                        MetricBadge(title: "入口容器", value: "WindowGroup", tint: .blue)
                    }

                    Text("当 App 进入后台、回前台、切换激活状态时，这个值会变化。SwiftUI 希望你围绕 Scene，而不是单纯围绕 ViewController 管理应用生命周期。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            BookDemoCard(
                title: "3. 多场景配置示例",
                summary: "对应教材里的多场景配置思路。这里先用学习卡片模拟“主窗口 + 辅助窗口”的职责分离。"
            ) {
                MultiSceneConceptDemo()
            }

            BookDemoCard(
                title: "4. 场景类型对照",
                summary: "教材会讲 `WindowGroup` 和 `DocumentGroup`。即使当前工程没做文档型 App，也要先建立概念。"
            ) {
                HStack {
                    MetricBadge(title: "普通应用", value: "WindowGroup", tint: .blue)
                    MetricBadge(title: "文档应用", value: "DocumentGroup", tint: .indigo)
                }
            }

            BookDemoCard(
                title: "5. 场景生命周期管理示例",
                summary: "对应教材里的场景管理最佳实践：前后台切换时，通常会在这里决定恢复、暂停、保存。"
            ) {
                SceneLifecycleManagementDemo(scenePhase: scenePhase)
            }

            BookTipView(
                title: "理解场景的角度",
                points: [
                    "`WindowGroup` 更像“可以创建一个或多个窗口实例的场景模板”。",
                    "在 iPad / macOS 上，多窗口能力会更明显；iPhone 上也建议按 Scene 思维组织代码。",
                    "以后做文档类应用时，你会看到 `DocumentGroup` 这类更特化的场景。"
                ]
            )
        }
    }

    private func phaseText(_ phase: ScenePhase) -> String {
        switch phase {
        case .active: return "active"
        case .inactive: return "inactive"
        case .background: return "background"
        @unknown default: return "unknown"
        }
    }
}

private struct WindowGroupFeatureDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "默认入口", value: "App -> WindowGroup", tint: .blue)
            MetricBadge(title: "多窗口潜力", value: "iPad / macOS", tint: .indigo)
            MetricBadge(title: "承载页面", value: "Root View", tint: .teal)
        }
    }
}

private struct MultiSceneConceptDemo: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.blue.opacity(0.14))
                .frame(height: 120)
                .overlay {
                    VStack {
                        Text("主窗口")
                            .font(.headline)
                        Text("内容浏览")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.indigo.opacity(0.14))
                .frame(height: 120)
                .overlay {
                    VStack {
                        Text("辅助窗口")
                            .font(.headline)
                        Text("详情 / 编辑")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
        }
    }
}

private struct SceneLifecycleManagementDemo: View {
    let scenePhase: ScenePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("当前场景状态：\(String(describing: scenePhase))")
                .font(.headline)
            Text(lifecycleMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var lifecycleMessage: String {
        switch scenePhase {
        case .active:
            return "active: 恢复动画、继续轮询、允许用户交互。"
        case .inactive:
            return "inactive: 处于过渡态，通常不要做重任务切换。"
        case .background:
            return "background: 保存必要状态、暂停资源消耗。"
        @unknown default:
            return "unknown: 为未来系统状态保留兜底逻辑。"
        }
    }
}

// MARK: - 第 17 章：生命周期
