import SwiftUI
import CoreData
import UIKit

struct Chapter3LayoutContainersView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 3,
            title: "布局与容器",
            introduction: "布局章节是 SwiftUI 的地基。你后面看到的大多数页面，本质上都是不同容器叠加组合出来的。"
        ) {
            BookDemoCard(
                title: "1. VStack / HStack / ZStack 对比",
                summary: "切换不同容器，看同样三块内容在垂直、水平和叠层布局中的差异。"
            ) {
                Chapter3LayoutDemo()
            }

            BookDemoCard(
                title: "2. ScrollView：超出屏幕也能浏览",
                summary: "对应教材的滚动视图部分。内容一多，就不能再指望固定容器把所有内容都塞进来。"
            ) {
                Chapter3ScrollViewDemo()
            }

            BookDemoCard(
                title: "3. Lazy Stacks 性能位置感",
                summary: "对应教材里的惰性堆栈。你可以先把它理解成“延迟创建子项”，更适合长列表。"
            ) {
                Chapter3LazyConceptDemo()
            }

            BookDemoCard(
                title: "4. 综合示例：社交帖子布局",
                summary: "对应教材里的综合示例。真正页面通常是多种容器一起配合。"
            ) {
                Chapter3SocialPostDemo()
            }

            BookTipView(
                title: "布局选择指南",
                points: [
                    "线性排列先想 VStack / HStack，叠层再想 ZStack。",
                    "内容可能超高时优先考虑 ScrollView。",
                    "长列表和大数据量优先考虑 Lazy 容器。"
                ]
            )
        }
    }
}

private struct Chapter3ScrollViewDemo: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(1...8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.12))
                        .frame(width: 120, height: 90)
                        .overlay {
                            Text("卡片 \(index)")
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct Chapter3LazyConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "VStack", value: "一次建很多", tint: .orange)
            MetricBadge(title: "LazyVStack", value: "按需创建", tint: .green)
            MetricBadge(title: "场景", value: "长列表", tint: .blue)
        }
    }
}

private struct Chapter3SocialPostDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay { Image(systemName: "person.fill") }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Swift 学习小组")
                        .font(.headline)
                    Text("2 分钟前")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text("这就是一个典型的组合布局：头像和标题用 HStack，整体再放进 VStack，图片和操作条继续往下叠。")
                .font(.subheadline)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.14))
                .frame(height: 120)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct Chapter3LayoutDemo: View {
    private enum Mode: String, CaseIterable {
        case vstack = "VStack"
        case hstack = "HStack"
        case zstack = "ZStack"
    }

    @State private var mode: Mode = .vstack

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Picker("布局模式", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)

            Group {
                switch mode {
                case .vstack:
                    VStack(spacing: 10) { layoutBlocks }
                case .hstack:
                    HStack(spacing: 10) { layoutBlocks }
                case .zstack:
                    ZStack { layoutBlocks }
                        .frame(height: 160)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var layoutBlocks: some View {
        Color.blue.opacity(0.7)
            .frame(width: 90, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        Color.orange.opacity(0.7)
            .frame(width: 120, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        Color.green.opacity(0.7)
            .frame(width: 100, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
