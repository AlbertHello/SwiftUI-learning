import SwiftUI
import CoreData
import UIKit

struct Chapter29PerformanceView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 29,
            title: "性能优化",
            introduction: "性能优化的本质不是迷信某个 API，而是知道哪里在浪费计算、哪里在重复渲染、哪里在不必要地处理大数据。"
        ) {
            BookDemoCard(
                title: "1. 性能问题对照表",
                summary: "对应教材的瓶颈识别部分。先建立一张脑中的排查表，再去写具体优化。"
            ) {
                PerformanceBottleneckTableDemo()
            }

            BookDemoCard(
                title: "2. EquatableView 与减少重绘",
                summary: "对应教材第一条优化策略。核心思路是：状态没变时，不要让某块视图重复刷新。"
            ) {
                EquatableRenderDemo()
            }

            BookDemoCard(
                title: "3. 列表性能优化：Identifiable 与差异化数据",
                summary: "对应教材第二条优化策略。稳定 identity 会直接影响列表刷新效率。"
            ) {
                IdentifiableListDiffDemo()
            }

            BookDemoCard(
                title: "4. 状态与绑定优化",
                summary: "对应教材第三条优化策略。谁依赖状态，谁订阅状态，不要让整棵视图树一起刷新。"
            ) {
                StateDependencyDemo()
            }

            BookDemoCard(
                title: "5. 过滤性能对比",
                summary: "模拟一批课程数据，比较“每次现算”与“预处理缓存”两种思路。"
            ) {
                PerformanceFilterDemo()
            }

            BookDemoCard(
                title: "6. 性能排查路线",
                summary: "教材里这一章的价值，在于帮你建立排查顺序：先看重绘，再看数据量，再看状态依赖，再看昂贵计算。"
            ) {
                HStack {
                    MetricBadge(title: "重绘", value: "View 更新范围", tint: .red)
                    MetricBadge(title: "数据量", value: "List / Lazy", tint: .orange)
                    MetricBadge(title: "计算", value: "缓存", tint: .blue)
                }
            }

            BookTipView(
                title: "高频实战建议",
                points: [
                    "长列表优先用 `List` 或 `LazyVStack`，不要一股脑把所有子项都立刻创建出来。",
                    "避免在 `body` 里做昂贵计算，把它们提前到 ViewModel 或缓存里。",
                    "只让真正依赖某状态的子视图订阅该状态，减少整棵树一起刷新。"
                ]
            )
        }
    }
}

private struct PerformanceBottleneckTableDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "重绘多", value: "检查状态范围", tint: .red)
            MetricBadge(title: "列表卡", value: "检查 identity", tint: .orange)
            MetricBadge(title: "输入慢", value: "检查计算量", tint: .blue)
        }
    }
}

private struct EquatableRenderDemo: View {
    @State private var counter = 0
    @State private var unrelated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EquatableNumberBadge(value: counter)

            HStack {
                Button("数字 +1") { counter += 1 }
                    .buttonStyle(.borderedProminent)
                Toggle("无关状态", isOn: $unrelated)
            }

            Text("当无关状态变化时，如果视图具备良好的等价判断，就能减少不必要重绘。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct EquatableNumberBadge: View, Equatable {
    let value: Int

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }

    var body: some View {
        Text("关键值：\(value)")
            .font(.title3.bold())
            .padding()
            .background(Color.red.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct IdentifiableListDiffDemo: View {
    @State private var items: [PerformanceItem] = [
        .init(title: "SwiftUI"),
        .init(title: "性能优化"),
        .init(title: "可访问性")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button("头部插入一项") {
                items.insert(.init(title: "新条目 \(Int.random(in: 1...99))"), at: 0)
            }
            .buttonStyle(.borderedProminent)

            ForEach(items) { item in
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                Divider()
            }
        }
    }
}

private struct PerformanceItem: Identifiable {
    let id = UUID()
    let title: String
}

private struct StateDependencyDemo: View {
    @State private var parentText = "SwiftUI"
    @State private var childCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("父状态", text: $parentText)
                .textFieldStyle(.roundedBorder)

            ChildCounterCard(count: $childCount)

            Text("把子模块自己的状态留在子模块里，比让父页面订阅所有细节更稳。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ChildCounterCard: View {
    @Binding var count: Int

    var body: some View {
        HStack {
            Text("子模块计数：\(count)")
            Spacer()
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct PerformanceFilterDemo: View {
    @State private var keyword = ""
    @State private var resultCount = 0
    @State private var lastCost = "尚未执行"

    private let items = (0..<5000).map { "SwiftUI 课程样本 \($0)" }
    private let lowercaseItems = (0..<5000).map { "swiftui 课程样本 \($0)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("输入关键字，比如 12 / 99 / swiftui", text: $keyword)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("朴素过滤") {
                    let start = CFAbsoluteTimeGetCurrent()
                    let count = items.filter { $0.localizedCaseInsensitiveContains(keyword) }.count
                    let end = CFAbsoluteTimeGetCurrent()
                    resultCount = count
                    lastCost = String(format: "朴素过滤耗时：%.3f ms", (end - start) * 1000)
                }
                .buttonStyle(.borderedProminent)

                Button("缓存过滤") {
                    let key = keyword.lowercased()
                    let start = CFAbsoluteTimeGetCurrent()
                    let count = lowercaseItems.filter { $0.contains(key) }.count
                    let end = CFAbsoluteTimeGetCurrent()
                    resultCount = count
                    lastCost = String(format: "缓存过滤耗时：%.3f ms", (end - start) * 1000)
                }
                .buttonStyle(.bordered)
            }

            Text("结果数：\(resultCount)")
            Text(lastCost)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 第 30 章：项目实战
