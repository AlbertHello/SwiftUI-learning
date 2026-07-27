import SwiftUI
import CoreData
import UIKit

struct Chapter22LayoutView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 22,
            title: "自定义布局",
            introduction: "当 `HStack / VStack / LazyVGrid` 都不够用时，就轮到 `Layout` 协议登场了。最典型的案例就是标签流式布局。"
        ) {
            BookDemoCard(
                title: "1. Layout 协议核心方法",
                summary: "对应教材开头的核心方法说明。先把 `sizeThatFits` 和 `placeSubviews` 的职责分清。"
            ) {
                LayoutProtocolOverviewDemo()
            }

            BookDemoCard(
                title: "2. 基础模板示例",
                summary: "对应教材里的基础模板。这里我把最小 Layout 思路做成了一个等间距行布局例子。"
            ) {
                LayoutTemplateDemo()
            }

            BookDemoCard(
                title: "3. 标签流式布局",
                summary: "容器会根据可用宽度自动换行，这正是很多搜索页、筛选页里常见的布局需求。"
            ) {
                CustomLayoutFlowDemo()
            }

            BookDemoCard(
                title: "4. 灵活网格布局实现",
                summary: "对应教材里的网格布局实战。这里给你一个自适应网格，方便和前面的流式布局做对比。"
            ) {
                AdaptiveGridLayoutDemo()
            }

            BookDemoCard(
                title: "5. 缓存优化示例",
                summary: "对应教材里的性能优化部分。重点不是复杂缓存，而是知道 Layout 允许你缓存中间计算结果。"
            ) {
                LayoutCacheConceptDemo()
            }

            BookDemoCard(
                title: "6. 课后练习：等间距 / 圆形 / 响应式 / 堆叠",
                summary: "把教材第 22 章的几个练习做成一个实验台，你可以切换不同布局效果来理解它们的差别。"
            ) {
                Chapter22ExerciseLayoutDemo()
            }

            BookDemoCard(
                title: "7. 挑战任务：瀑布流布局",
                summary: "按教材要求，新增项目时自动放到当前最短列；这里还支持动态添加和删除。"
            ) {
                Chapter22WaterfallChallengeDemo()
            }

            BookTipView(
                title: "自定义布局注意事项",
                points: [
                    "先想清楚容器想表达的布局意图，再决定是否真的要上 `Layout` 协议。",
                    "`sizeThatFits` 负责估尺寸，`placeSubviews` 负责摆位置，这两个职责不要混。",
                    "当子项数量变化频繁时，要考虑动画和性能，不要每次都做过重计算。"
                ]
            )
        }
    }
}

private struct LayoutProtocolOverviewDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "估尺寸", value: "sizeThatFits", tint: .blue)
            MetricBadge(title: "摆位置", value: "placeSubviews", tint: .green)
            MetricBadge(title: "复用计算", value: "cache", tint: .orange)
        }
    }
}

private struct LayoutTemplateDemo: View {
    var body: some View {
        EqualSpacingRowLayout {
            templateBlock("模板 A", color: .blue)
            templateBlock("模板 B", color: .orange)
            templateBlock("模板 C", color: .green)
        }
        .frame(height: 60)
    }

    private func templateBlock(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.footnote.bold())
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(color.opacity(0.16), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct CustomLayoutFlowDemo: View {
    @State private var tags = ["SwiftUI", "动画", "布局", "并发", "网络", "可访问性", "Path", "Shape", "Core Data", "Widget"]
    @State private var newTag = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("输入一个新标签", text: $newTag)
                    .textFieldStyle(.roundedBorder)

                Button("添加") {
                    let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard trimmed.isEmpty == false else { return }
                    withAnimation(.spring) {
                        tags.append(trimmed)
                    }
                    newTag = ""
                }
                .buttonStyle(.borderedProminent)
            }

            TagFlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12), in: Capsule())
                        .onTapGesture {
                            withAnimation(.spring) {
                                tags.removeAll { $0 == tag }
                            }
                        }
                }
            }
        }
    }
}

private struct AdaptiveGridLayoutDemo: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
            ForEach(1...8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.indigo.opacity(0.14))
                    .frame(height: 72)
                    .overlay {
                        Text("网格 \(index)")
                    }
            }
        }
    }
}

private struct LayoutCacheConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "第一次", value: "测量并记录", tint: .purple)
                MetricBadge(title: "后续", value: "复用缓存", tint: .pink)
            }

            Text("当子视图数量很多、尺寸计算复杂时，缓存中间结果能减少重复测量。这个概念你先记住，后面做复杂自定义布局时很有用。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

/// 自定义 `Layout` 的最小可学版本。
///
/// 你可以把它理解成：
/// - `sizeThatFits`：先问这个容器“你大概需要多大”
/// - `placeSubviews`：真正把孩子们一个个摆进去
private struct TagFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )

            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

private struct Chapter22ExerciseLayoutDemo: View {
    private enum Mode: String, CaseIterable {
        case equal = "等间距"
        case circle = "圆形"
        case grid = "响应式"
        case stack = "堆叠"
    }

    @State private var mode: Mode = .equal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("布局练习", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch mode {
                case .equal:
                    EqualSpacingRowLayout {
                        sampleLayoutChip("A", color: .blue)
                        sampleLayoutChip("B", color: .orange)
                        sampleLayoutChip("C", color: .green)
                    }
                    .frame(height: 60)
                case .circle:
                    CircleOrbitLayout {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill([Color.blue, .orange, .green, .pink, .purple, .mint][index])
                                .frame(width: 42, height: 42)
                        }
                    }
                    .frame(height: 220)
                case .grid:
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 10)], spacing: 10) {
                        ForEach(0..<10, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.indigo.opacity(0.14))
                                .frame(height: 64)
                                .overlay {
                                    Text("Item \(index + 1)")
                                }
                        }
                    }
                case .stack:
                    ZStack {
                        ForEach(0..<4, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 18)
                                .fill([Color.blue, .purple, .pink, .orange][index].opacity(0.2 + Double(index) * 0.12))
                                .frame(height: 120)
                                .offset(x: CGFloat(index * 8), y: CGFloat(index * 8))
                        }
                    }
                    .frame(height: 170)
                }
            }
        }
    }

    private func sampleLayoutChip(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct EqualSpacingRowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 300, height: 60)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.isEmpty == false else { return }
        let slotWidth = bounds.width / CGFloat(subviews.count)
        for (index, subview) in subviews.enumerated() {
            let x = bounds.minX + CGFloat(index) * slotWidth
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                proposal: ProposedViewSize(width: slotWidth - 8, height: bounds.height)
            )
        }
    }
}

private struct CircleOrbitLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let side = min(proposal.width ?? 220, proposal.height ?? 220)
        return CGSize(width: side, height: side)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.isEmpty == false else { return }
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) * 0.34
        let step = (Double.pi * 2) / Double(subviews.count)

        for (index, subview) in subviews.enumerated() {
            let angle = step * Double(index) - Double.pi / 2
            let size = subview.sizeThatFits(.unspecified)
            let point = CGPoint(
                x: center.x + CGFloat(Darwin.cos(angle)) * radius - size.width / 2,
                y: center.y + CGFloat(Darwin.sin(angle)) * radius - size.height / 2
            )
            subview.place(at: point, proposal: ProposedViewSize(size))
        }
    }
}

private struct Chapter22WaterfallTile: Identifiable {
    let id = UUID()
    let height: CGFloat
    let color: Color
}

private struct Chapter22WaterfallChallengeDemo: View {
    @State private var tiles: [Chapter22WaterfallTile] = [
        .init(height: 90, color: .blue),
        .init(height: 140, color: .orange),
        .init(height: 110, color: .green),
        .init(height: 160, color: .pink),
        .init(height: 120, color: .purple)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("新增卡片") {
                    withAnimation(.spring) {
                        tiles.append(
                            .init(
                                height: CGFloat(Int.random(in: 90...170)),
                                color: [Color.blue, .orange, .green, .pink, .purple, .mint].randomElement() ?? .blue
                            )
                        )
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("删除最后一个") {
                    guard tiles.isEmpty == false else { return }
                    withAnimation(.spring) {
                        _ = tiles.popLast()
                    }
                }
                .buttonStyle(.bordered)
            }

            HStack(alignment: .top, spacing: 10) {
                waterfallColumn(items: columnedTiles.0)
                waterfallColumn(items: columnedTiles.1)
            }
        }
    }

    private var columnedTiles: ([Chapter22WaterfallTile], [Chapter22WaterfallTile]) {
        var left: [Chapter22WaterfallTile] = []
        var right: [Chapter22WaterfallTile] = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        for tile in tiles {
            if leftHeight <= rightHeight {
                left.append(tile)
                leftHeight += tile.height
            } else {
                right.append(tile)
                rightHeight += tile.height
            }
        }

        return (left, right)
    }

    private func waterfallColumn(items: [Chapter22WaterfallTile]) -> some View {
        VStack(spacing: 10) {
            ForEach(items) { tile in
                RoundedRectangle(cornerRadius: 16)
                    .fill(tile.color.opacity(0.18))
                    .frame(height: tile.height)
                    .overlay {
                        Text("\(Int(tile.height))pt")
                            .font(.headline)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 第 23 章：视觉效果
