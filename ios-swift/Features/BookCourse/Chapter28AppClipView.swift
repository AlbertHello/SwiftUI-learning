import SwiftUI
import CoreData
import UIKit

struct Chapter28AppClipView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 28,
            title: "App Clip 开发",
            introduction: "App Clip 的重点是“足够轻、足够快、只解决一个瞬时场景”。所以你在设计时要克制，只保留用户当下必须的流程。"
        ) {
            BookDemoCard(
                title: "1. App Clip 的核心特性与限制",
                summary: "对应教材开头的概念部分。你要先知道它为什么存在，以及为什么不能把它当完整 App 来做。"
            ) {
                AppClipCapabilityDemo()
            }

            BookDemoCard(
                title: "2. 添加 App Clip Target",
                summary: "对应教材第一步。当前工程没有真实 App Clip target，这里先把工程结构变化讲清楚。"
            ) {
                AppClipTargetConceptDemo()
            }

            BookDemoCard(
                title: "3. 设计轻量级 UI",
                summary: "对应教材第二步。App Clip 页面必须把流程压缩到最短。"
            ) {
                AppClipLightweightUIDemo()
            }

            BookDemoCard(
                title: "4. 配置 Associated Domains / AASA",
                summary: "对应教材第三、第四步。真正决定能否通过链接调起的关键，在域名关联和 AASA 文件。"
            ) {
                AppClipDomainConceptDemo()
            }

            BookDemoCard(
                title: "5. 处理传入 URL",
                summary: "对应教材第五步。输入一个 URL，模拟 App Clip 只拿关键参数快速进入目标场景。"
            ) {
                AppClipSimulationDemo()
            }

            BookDemoCard(
                title: "6. 测试与分发",
                summary: "对应教材最后一步。App Clip 除了本地能跑，还要确保入口链路、参数解析和部署都正确。"
            ) {
                AppClipTestingChecklistDemo()
            }

            BookDemoCard(
                title: "7. App Clip 约束清单",
                summary: "教材会反复强调：轻量、快速、单场景。App Clip 不是把整个 App 缩小，而是把最关键那一步单独拿出来。"
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("入口要短：扫一下、点一下就能进", systemImage: "checkmark.circle")
                    Label("界面要少：只保留当下任务所需内容", systemImage: "checkmark.circle")
                    Label("深链参数要明确：快速定位到具体场景", systemImage: "checkmark.circle")
                }
                .font(.subheadline)
            }

            BookTipView(
                title: "App Clip 注意事项",
                points: [
                    "不要试图把完整 App 流程都塞进 App Clip。",
                    "入口设计比界面设计还重要，必须保证用户能秒进秒用。",
                    "URL 参数、关联域名、场景路由要从一开始就设计清楚。"
                ]
            )
        }
    }
}

private struct AppClipCapabilityDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "特点", value: "轻量 / 快速", tint: .purple)
            MetricBadge(title: "定位", value: "单场景", tint: .blue)
            MetricBadge(title: "限制", value: "能力受限", tint: .orange)
        }
    }
}

private struct AppClipTargetConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("新增独立 App Clip Target", systemImage: "checkmark.circle")
            Label("共享必要业务代码，不复制整套应用", systemImage: "checkmark.circle")
            Label("只暴露当前场景所需页面和资源", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

private struct AppClipLightweightUIDemo: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color.purple.opacity(0.14))
            .frame(height: 150)
            .overlay {
                VStack(spacing: 8) {
                    Text("咖啡店快速支付")
                        .font(.headline)
                    Text("1 步选金额，1 步确认")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
    }
}

private struct AppClipDomainConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "域名关联", value: "Associated Domains", tint: .blue)
            MetricBadge(title: "站点声明", value: "AASA", tint: .green)
            MetricBadge(title: "入口解析", value: "URL Routing", tint: .purple)
        }
    }
}

private struct AppClipSimulationDemo: View {
    @State private var urlText = "https://demo.example.com/clip?scene=pay&shop=coffee"
    @State private var parsedScene = "尚未解析"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("输入深链 URL", text: $urlText)
                .textFieldStyle(.roundedBorder)

            Button("模拟打开 App Clip") {
                parseURL()
            }
            .buttonStyle(.borderedProminent)

            Text("解析结果：\(parsedScene)")
                .font(.headline)
        }
    }

    private func parseURL() {
        guard
            let components = URLComponents(string: urlText),
            let items = components.queryItems
        else {
            parsedScene = "URL 无效"
            return
        }

        let scene = items.first(where: { $0.name == "scene" })?.value ?? "default"
        let shop = items.first(where: { $0.name == "shop" })?.value ?? "unknown"
        parsedScene = "快速进入 \(scene) 场景，店铺：\(shop)"
    }
}

private struct AppClipTestingChecklistDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("验证链接能否正确拉起场景", systemImage: "checkmark.circle")
            Label("验证参数解析是否稳定", systemImage: "checkmark.circle")
            Label("验证场景完成后能否顺滑回到主 App", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

// MARK: - 第 29 章：性能优化
