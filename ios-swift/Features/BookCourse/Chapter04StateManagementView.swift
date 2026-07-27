import SwiftUI
import CoreData
import UIKit

struct Chapter4StateManagementView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 4,
            title: "状态管理",
            introduction: "状态管理讲的是：哪些数据放在 View 本地，哪些数据放到可观察对象里，哪些只是临时交互状态。你后面写任何页面都离不开它。"
        ) {
            BookDemoCard(
                title: "1. 属性包装器总览",
                summary: "对应教材的属性包装器对比总览。先把它们各自负责的状态范围建立起来。"
            ) {
                HStack {
                    MetricBadge(title: "本地", value: "@State", tint: .green)
                    MetricBadge(title: "拥有对象", value: "@StateObject", tint: .blue)
                    MetricBadge(title: "观察对象", value: "@ObservedObject", tint: .orange)
                    MetricBadge(title: "环境共享", value: "@EnvironmentObject", tint: .purple)
                }
            }

            BookDemoCard(
                title: "2. @State 与 @StateObject",
                summary: "同一页里同时演示：局部计数器用 `@State`，跨组件共享且有逻辑的数据放到 `@StateObject`。"
            ) {
                Chapter4StateDemo()
            }

            BookDemoCard(
                title: "3. 实战练习：待办事项状态流",
                summary: "对应教材第 4 章的挑战任务：这里同时用到了 `@StateObject`、`@Binding`、`@ObservedObject` 和 `@EnvironmentObject`。"
            ) {
                Chapter4TodoChallengeDemo()
            }

            BookTipView(
                title: "第 4 章注意事项",
                points: [
                    "先判断状态归谁拥有，再决定用哪个属性包装器。",
                    "不要把临时交互状态和跨页面业务状态混成一类。",
                    "状态越清晰，后面数据流和调试就越轻松。"
                ]
            )
        }
    }
}

private struct Chapter4StateDemo: View {
    @State private var localCount = 0
    @StateObject private var viewModel = Chapter4LessonViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                MetricBadge(title: "@State", value: "\(localCount)", tint: .green)
                MetricBadge(title: "@StateObject", value: "\(viewModel.totalFinished)", tint: .blue)
            }

            HStack {
                Button("本地 +1") {
                    localCount += 1
                }
                .buttonStyle(.borderedProminent)

                Button("完成一节课") {
                    viewModel.finishLesson()
                }
                .buttonStyle(.bordered)
            }

            Text("局部短状态常放 `@State`；如果数据带逻辑、要被子视图共享，通常升到 `ObservableObject`。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private final class Chapter4LessonViewModel: ObservableObject {
    @Published var totalFinished = 3

    func finishLesson() {
        totalFinished += 1
    }
}

private struct Chapter4TodoItem: Identifiable {
    let id = UUID()
    let title: String
    var isDone: Bool
}

private final class Chapter4TodoViewModel: ObservableObject {
    @Published var tasks: [Chapter4TodoItem] = [
        Chapter4TodoItem(title: "理解 @State", isDone: true),
        Chapter4TodoItem(title: "练习 @Binding", isDone: false),
        Chapter4TodoItem(title: "把主题做成 EnvironmentObject", isDone: false)
    ]

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        tasks.insert(Chapter4TodoItem(title: trimmed, isDone: false), at: 0)
    }

    func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isDone.toggle()
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }
}

private final class Chapter4ThemeSettings: ObservableObject {
    @Published var useWarmTheme = false
}

private struct Chapter4TodoChallengeDemo: View {
    @StateObject private var viewModel = Chapter4TodoViewModel()
    @StateObject private var theme = Chapter4ThemeSettings()
    @State private var draft = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chapter4TodoAddView(title: $draft) {
                viewModel.addTask(title: draft)
                draft = ""
            }

            Chapter4TodoListView(viewModel: viewModel)
                .environmentObject(theme)

            Chapter4TodoSettingsView()
                .environmentObject(theme)
        }
    }
}

private struct Chapter4TodoAddView: View {
    @Binding var title: String
    let onAdd: () -> Void

    var body: some View {
        HStack {
            TextField("输入一个新任务", text: $title)
                .textFieldStyle(.roundedBorder)

            Button("添加", action: onAdd)
                .buttonStyle(.borderedProminent)
        }
    }
}

private struct Chapter4TodoListView: View {
    @ObservedObject var viewModel: Chapter4TodoViewModel
    @EnvironmentObject private var theme: Chapter4ThemeSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.tasks) { task in
                HStack {
                    Button {
                        viewModel.toggleTask(id: task.id)
                    } label: {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(task.isDone ? .green : theme.useWarmTheme ? .orange : .blue)
                    }
                    .buttonStyle(.plain)

                    Text(task.title)
                        .strikethrough(task.isDone)

                    Spacer()

                    Button("删") {
                        viewModel.deleteTask(id: task.id)
                    }
                    .font(.footnote)
                    .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background((theme.useWarmTheme ? Color.orange : Color.blue).opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct Chapter4TodoSettingsView: View {
    @EnvironmentObject private var theme: Chapter4ThemeSettings

    var body: some View {
        Toggle("使用暖色主题（EnvironmentObject）", isOn: $theme.useWarmTheme)
    }
}
