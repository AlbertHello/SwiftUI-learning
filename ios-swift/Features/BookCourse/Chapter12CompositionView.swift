import SwiftUI
import CoreData
import UIKit

struct Chapter12CompositionView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 12,
            title: "视图组合与复用",
            introduction: "当页面开始变复杂时，你要学会把大页面拆成小组件。SwiftUI 鼓励你像搭积木一样拼页面，而不是把所有 UI 都塞在一个巨大 `body` 里。"
        ) {
            BookDemoCard(
                title: "1. 可复用学生任务卡片",
                summary: "把徽章、按钮、进度、信息行拆成独立组件，然后再组合成完整卡片。"
            ) {
                CompositionStudentTaskDemo()
            }

            BookDemoCard(
                title: "2. ViewBuilder 插槽思维",
                summary: "很多可复用组件并不是把所有内容都写死，而是预留一个插槽，让调用方把自定义内容塞进来。"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("这和 Flutter 里的 `child` / `children` 很像。")
                        .font(.subheadline)
                    StudentTaskCard(
                        title: "插槽练习",
                        subtitle: "把固定卡片骨架和可变内容分离",
                        progress: 0.72,
                        isDone: false
                    )
                }
            }

            BookDemoCard(
                title: "3. 教程重点覆盖",
                summary: "教材里强调“组合优于继承”。真正实战时，优先拆小组件，再通过参数和 ViewBuilder 组合，而不是做层层继承。"
            ) {
                HStack {
                    MetricBadge(title: "组件颗粒度", value: "小而清晰", tint: .orange)
                    MetricBadge(title: "复用方式", value: "参数 + 插槽", tint: .blue)
                }
            }

            BookTipView(
                title: "拆组件时的判断标准",
                points: [
                    "一个区域如果会在多个页面出现，就值得抽成组件。",
                    "一个 View 如果代码太长，先尝试拆成语义更明确的小块。",
                    "`@ViewBuilder` 适合把“插槽”传给组件，和 Flutter 里的 `child` / `children` 很像。"
                ]
            )
        }
    }
}

private struct CompositionStudentTaskDemo: View {
    @State private var progress: Double = 0.35
    @State private var isDone = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            StudentTaskCard(
                title: "第 12 章学习计划",
                subtitle: "练习把复杂页面拆成可复用组件",
                progress: progress,
                isDone: isDone
            )

            Slider(value: $progress, in: 0...1)

            Toggle("标记完成", isOn: $isDone)
        }
    }
}

private struct StudentTaskCard: View {
    let title: String
    let subtitle: String
    let progress: Double
    let isDone: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TaskStatusBadge(isDone: isDone)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.headline)
            }

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: progress)
                .tint(isDone ? .green : .blue)
        }
        .padding()
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct TaskStatusBadge: View {
    let isDone: Bool

    var body: some View {
        Text(isDone ? "已完成" : "进行中")
            .font(.caption.weight(.bold))
            .foregroundStyle(isDone ? .green : .blue)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background((isDone ? Color.green : Color.blue).opacity(0.14), in: Capsule())
    }
}

// MARK: - 第 13 章：手势

