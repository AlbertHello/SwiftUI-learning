import SwiftUI
import CoreData
import UIKit

struct Chapter14DragDropView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 14,
            title: "拖放操作",
            introduction: "拖放操作很适合做任务流转、标签归类、文件整理。SwiftUI 从 iOS 16 开始提供了比较顺手的 `draggable` 和 `dropDestination`。"
        ) {
            BookDemoCard(
                title: "1. 使视图可拖动",
                summary: "对应教材里的第一步：先让一个视图真正可拖。这里我用课程卡片做一个最小化拖拽源。"
            ) {
                DragSourceOnlyDemo()
            }

            BookDemoCard(
                title: "2. 创建放置目标",
                summary: "对应教材里的第二步：不仅要能接住，还要给用户一个明显的目标反馈。"
            ) {
                DropTargetHighlightDemo()
            }

            BookDemoCard(
                title: "3. 任务拖拽分栏",
                summary: "把任务从“待处理”拖到“已完成”区域，理解拖拽源和放置目标的职责分工。"
            ) {
                DragDropBoardDemo()
            }

            BookDemoCard(
                title: "4. 组合与交互",
                summary: "对应教材里的“组合与交互”：把拖拽源、放置目标和业务状态更新完整串起来。"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        MetricBadge(title: "源头", value: "draggable", tint: .orange)
                        MetricBadge(title: "目标", value: "dropDestination", tint: .green)
                        MetricBadge(title: "交互反馈", value: "isTargeted", tint: .blue)
                    }
                    Text("要点是：拖拽源负责“能拖什么”，放置区负责“接不接”和“接住后怎么改状态”。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            BookTipView(
                title: "拖放注意事项",
                points: [
                    "先把数据模型设计清楚，再决定拖放后的流转规则。",
                    "拖放成功后一定要同步更新原始数据源，否则 UI 看起来变了，真实状态却没改。",
                    "如果拖放区域很多，优先做出明确的视觉反馈，避免用户不知道哪里能放。"
                ]
            )
        }
    }
}

private struct DragSourceOnlyDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("长按下面这张卡片并拖动，你会看到系统自动创建拖拽预览。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.opacity(0.18))
                .frame(height: 110)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.orange)
                        Text("把我拖出去")
                            .font(.headline)
                    }
                }
                .draggable("第14章拖拽源示例")
        }
    }
}

private struct DropTargetHighlightDemo: View {
    @State private var droppedText = "还没有收到内容"
    @State private var dragItems = ["SwiftUI", "拖放", "任务卡片"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ForEach(dragItems, id: \.self) { item in
                    Text(item)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.12), in: Capsule())
                        .draggable(item)
                }
            }

            DropTargetBox(receivedText: $droppedText)

            Text("最近接收：\(droppedText)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DropTargetBox: View {
    @Binding var receivedText: String
    @State private var isTargeted = false

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(isTargeted ? Color.green.opacity(0.22) : Color.green.opacity(0.12))
            .frame(height: 120)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: isTargeted ? "tray.and.arrow.down.fill" : "tray")
                        .font(.system(size: 30))
                        .foregroundStyle(.green)
                    Text(isTargeted ? "松手即可放下" : "把上面的标签拖到这里")
                        .font(.headline)
                }
            }
            .dropDestination(for: String.self) { items, _ in
                guard let first = items.first else { return false }
                receivedText = first
                return true
            } isTargeted: { targeted in
                isTargeted = targeted
            }
    }
}

private struct DragDropBoardDemo: View {
    @State private var todoTasks = ["看 14 章笔记", "写 drop demo", "整理状态流"]
    @State private var doneTasks = ["完成路径动画页"]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            DragColumnView(
                title: "待处理",
                tint: .orange,
                items: todoTasks
            ) { task in
                move(task: task, from: &doneTasks, to: &todoTasks)
            }

            DragColumnView(
                title: "已完成",
                tint: .green,
                items: doneTasks
            ) { task in
                move(task: task, from: &todoTasks, to: &doneTasks)
            }
        }
    }

    private func move(task: String, from source: inout [String], to destination: inout [String]) {
        source.removeAll { $0 == task }
        if destination.contains(task) == false {
            destination.append(task)
        }
    }
}

private struct DragColumnView: View {
    let title: String
    let tint: Color
    let items: [String]
    let onDropTask: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.subheadline)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
                        .draggable(item)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
            .padding()
            .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
            .dropDestination(for: String.self) { items, _ in
                guard let first = items.first else { return false }
                onDropTask(first)
                return true
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 第 15 章：系统集成
