import SwiftUI
import CoreData
import UIKit

struct Chapter26MultiPlatformView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 26,
            title: "多平台适配",
            introduction: "多平台适配的核心不是 if else 越写越多，而是先把“信息层级”和“布局意图”理清，再针对不同宽度组织排列方式。"
        ) {
            BookDemoCard(
                title: "1. 项目结构概览",
                summary: "对应教材开头的项目设置部分。多平台工程一般会有共享层和平台差异层。"
            ) {
                MultiPlatformProjectStructureDemo()
            }

            BookDemoCard(
                title: "2. 使用 SizeClass 适配",
                summary: "对应教材里的自适应布局小节。虽然当前运行在 iPhone 上，但我们可以用一个模拟开关先感受不同布局策略。"
            ) {
                MultiPlatformAdaptiveDemo()
            }

            BookDemoCard(
                title: "3. 平台差异与条件编译",
                summary: "教材里会讲平台差异能力。你现在先建立认知：共享逻辑优先，差异能力局部隔离。"
            ) {
                ConditionalCompilationConceptDemo()
            }

            BookDemoCard(
                title: "4. 平台特定功能与修饰符",
                summary: "对应教材里的导航差异、窗口与场景管理。当前工程先做概念对照，而不是硬做多平台 target。"
            ) {
                PlatformSpecificFeatureDemo()
            }

            BookDemoCard(
                title: "5. 资源与图标适配",
                summary: "教材里还会提醒图标、资源、间距在不同平台要有不同考虑。"
            ) {
                ResourceAdaptationDemo()
            }

            BookDemoCard(
                title: "6. 多平台思维",
                summary: "教材里这章真正想教你的，不是写很多平台分支，而是先让信息结构能适应不同尺寸。"
            ) {
                HStack {
                    MetricBadge(title: "尺寸", value: "SizeClass", tint: .indigo)
                    MetricBadge(title: "差异能力", value: "条件编译", tint: .blue)
                    MetricBadge(title: "布局策略", value: "自适应", tint: .green)
                }
            }

            BookTipView(
                title: "多平台适配注意事项",
                points: [
                    "优先做自适应布局，而不是到处写平台专属分支。",
                    "平台差异只在必要时暴露，尽量复用同一套业务结构。",
                    "宽屏不意味着把 iPhone 页面简单拉宽，而是重新组织层级。"
                ]
            )
        }
    }
}

private struct MultiPlatformProjectStructureDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "共享层", value: "业务 / ViewModel", tint: .blue)
            MetricBadge(title: "平台层", value: "修饰符 / 场景", tint: .green)
            MetricBadge(title: "资源层", value: "图标 / 布局", tint: .orange)
        }
    }
}

private struct MultiPlatformAdaptiveDemo: View {
    @State private var useRegularLayout = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle("模拟宽屏 / Regular 布局", isOn: $useRegularLayout.animation())

            Group {
                if useRegularLayout {
                    HStack(spacing: 12) {
                        adaptivePanel(title: "侧栏", color: .indigo)
                        adaptivePanel(title: "内容区", color: .blue)
                    }
                } else {
                    VStack(spacing: 12) {
                        adaptivePanel(title: "顶部摘要", color: .indigo)
                        adaptivePanel(title: "主内容", color: .blue)
                    }
                }
            }
        }
    }

    private func adaptivePanel(title: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(color.opacity(0.16))
            .frame(height: 120)
            .overlay {
                Text(title)
                    .font(.headline)
            }
    }
}

private struct ConditionalCompilationConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("常见思路：先让页面结构共享，再用条件编译或条件修饰符处理平台差异。")
                .font(.headline)
            Text("也就是说，多平台不是从第一天就写满 `#if os(...)`，而是先尽量复用，再局部定制。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct PlatformSpecificFeatureDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "iPhone", value: "NavigationStack", tint: .blue)
            MetricBadge(title: "iPad", value: "Split View", tint: .indigo)
            MetricBadge(title: "macOS", value: "多窗口", tint: .purple)
        }
    }
}

private struct ResourceAdaptationDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("图标尺寸和留白不要跨平台硬套", systemImage: "checkmark.circle")
            Label("宽屏下信息密度和分栏策略要调整", systemImage: "checkmark.circle")
            Label("交互控件在触控和鼠标环境下关注点不同", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

// MARK: - 第 27 章：Widget
