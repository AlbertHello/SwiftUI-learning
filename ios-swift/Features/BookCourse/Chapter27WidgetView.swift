import SwiftUI
import CoreData
import UIKit

struct Chapter27WidgetView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 27,
            title: "Widget 小组件开发",
            introduction: "当前工程还没有 Widget Extension，所以这里先做一个“组件思维练习页”：学会以尺寸、时间线、低交互的约束来设计界面。"
        ) {
            BookDemoCard(
                title: "1. 开发步骤总览",
                summary: "对应教材的 5 个开发步骤。即使当前工程没建 Widget Extension，你也要先把流程链路记住。"
            ) {
                WidgetDevelopmentStepsDemo()
            }

            BookDemoCard(
                title: "2. Timeline Entry / Provider",
                summary: "对应教材里的时间线条目和提供者。Widget 的数据刷新核心就在这里。"
            ) {
                WidgetTimelineConceptDemo()
            }

            BookDemoCard(
                title: "3. 构建 Widget 视图",
                summary: "对应教材里的 SwiftUI 视图片段。Widget 页面和普通页面最大的不同，是内容必须更克制。"
            ) {
                WidgetPreviewLearningDemo()
            }

            BookDemoCard(
                title: "4. 组装与注册 Widget",
                summary: "对应教材的最后一步。你现在先记住：配置、入口、预览、尺寸都要一起收口。"
            ) {
                WidgetAssemblyConceptDemo()
            }

            BookDemoCard(
                title: "5. 尺寸适配",
                summary: "对应教材的设计要点：切换 small / medium，感受同一份数据在不同 Widget family 下如何取舍内容。"
            ) {
                WidgetSizeAdaptationDemo()
            }

            BookDemoCard(
                title: "6. 性能与更新",
                summary: "教材会强调：Widget 不是实时界面，刷新预算有限，视图也应该尽量轻。"
            ) {
                WidgetPerformanceConceptDemo()
            }

            BookDemoCard(
                title: "7. 核心 API 速查表",
                summary: "把教材里的关键 API 再归纳成一个小抄，方便你以后回看。"
            ) {
                WidgetAPICheatSheetDemo()
            }

            BookTipView(
                title: "Widget 注意事项",
                points: [
                    "小组件可交互能力有限，优先展示最关键的信息。",
                    "同一份数据在不同尺寸下，要敢于删减内容。",
                    "Widget 更偏“快照设计”，不要按 App 页面那套持续交互思路去做。"
                ]
            )
        }
    }
}

private struct WidgetDevelopmentStepsDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("1. 创建 Widget Extension", systemImage: "checkmark.circle")
            Label("2. 定义 TimelineEntry", systemImage: "checkmark.circle")
            Label("3. 实现 TimelineProvider", systemImage: "checkmark.circle")
            Label("4. 构建 Widget 视图", systemImage: "checkmark.circle")
            Label("5. 组装并注册 Widget", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

private struct WidgetTimelineConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "数据入口", value: "TimelineEntry", tint: .mint)
            MetricBadge(title: "刷新策略", value: "TimelineProvider", tint: .green)
            MetricBadge(title: "结果集合", value: "Timeline", tint: .teal)
        }
    }
}

private struct WidgetAssemblyConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "配置", value: "WidgetConfiguration", tint: .blue)
            MetricBadge(title: "展示", value: "Widget View", tint: .purple)
            MetricBadge(title: "预览", value: "Preview", tint: .orange)
        }
    }
}

private struct WidgetSizeAdaptationDemo: View {
    @State private var useMedium = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("使用 Medium 尺寸", isOn: $useMedium.animation())

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mint.gradient)
                .frame(height: useMedium ? 160 : 140)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SwiftTask")
                            .font(.headline)
                        Text("今日完成 5/8")
                            .font(.title2.bold())
                        if useMedium {
                            Text("剩余重点：Path / Shape、并发、性能优化")
                                .font(.subheadline)
                        }
                    }
                    .padding()
                    .foregroundStyle(.white)
                }
        }
    }
}

private struct WidgetPerformanceConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("刷新依赖时间线，不要假设能实时轮询", systemImage: "checkmark.circle")
            Label("内容越精简越好，避免把 App 主页面硬塞进去", systemImage: "checkmark.circle")
            Label("数据准备尽量前置，Widget 视图层保持轻量", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

private struct WidgetAPICheatSheetDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "条目", value: "TimelineEntry", tint: .green)
            MetricBadge(title: "提供者", value: "Provider", tint: .mint)
            MetricBadge(title: "尺寸", value: "Family", tint: .teal)
        }
    }
}

private struct WidgetPreviewLearningDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.mint.gradient)
                .frame(height: 140)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SwiftTask")
                            .font(.headline)
                        Text("今日完成 5/8")
                            .font(.title2.bold())
                        Text("只保留最关键的一条补充信息")
                            .font(.subheadline)
                    }
                    .padding()
                    .foregroundStyle(.white)
                }

            Text("真实 Widget 会通过 Timeline 提供未来多个时间点的数据快照，而不是像普通 App 一样持续运行。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 第 28 章：App Clip
