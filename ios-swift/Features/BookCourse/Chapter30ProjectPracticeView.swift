import SwiftUI
import CoreData
import UIKit

struct Chapter30ProjectPracticeView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 30,
            title: "项目实战",
            introduction: "最后一章我给你做了一个轻量版任务管理器，把列表、表单、状态过滤、统计信息组合到一个可运行页面里。这个例子很适合你继续往真实项目方向扩展。"
        ) {
            BookDemoCard(
                title: "1. 课程目标与应用规划",
                summary: "对应教材开头的目标和规划部分。先看清这个小应用到底要解决什么问题，再看代码才不会散。"
            ) {
                Chapter30PlanningDemo()
            }

            BookDemoCard(
                title: "2. MVVM 架构图",
                summary: "对应教材里的应用架构图。最后一章最重要的不是堆功能，而是把前面分散知识点串起来。"
            ) {
                Chapter30MVVMDemo()
            }

            BookDemoCard(
                title: "3. 数据模型设计",
                summary: "对应教材里的模型设计部分。当前工程没有直接上 SwiftData target，这里先用轻量模型结构把思路讲清楚。"
            ) {
                Chapter30ModelDesignDemo()
            }

            BookDemoCard(
                title: "4. SwiftTask 轻量实战",
                summary: "支持新增任务、切换完成状态、过滤查看和统计，是一个小型 MVVM 风格样板。"
            ) {
                ProjectPracticeTaskBoardDemo()
            }

            BookDemoCard(
                title: "5. 关键代码片段：TaskRow",
                summary: "对应教材的任务列表行视图。这里我给你做一个更聚焦的行组件，方便单独理解。"
            ) {
                Chapter30TaskRowDemo()
            }

            BookDemoCard(
                title: "6. 关键代码片段：TaskViewModel",
                summary: "对应教材里的 ViewModel 示例。这个卡片专门看 ViewModel 管什么，不和大页面揉在一起。"
            ) {
                Chapter30ViewModelConceptDemo()
            }

            BookDemoCard(
                title: "7. 项目结构视角",
                summary: "教材最后一章不是单纯拼功能，而是把前面零散知识点串成一个完整项目。你可以从“模型、状态、页面、扩展能力”四层去看。"
            ) {
                HStack {
                    MetricBadge(title: "Model", value: "任务数据", tint: .blue)
                    MetricBadge(title: "State", value: "筛选 / 完成", tint: .green)
                    MetricBadge(title: "UI", value: "列表 + 输入", tint: .orange)
                    MetricBadge(title: "扩展", value: "分享 / 统计", tint: .purple)
                }
            }

            BookDemoCard(
                title: "8. 教材扩展挑战映射",
                summary: "教材提到 iCloud、小组件、统计、暗黑模式、分享。当前页已经先覆盖了统计和分享，后续你还可以继续往真实产品走。"
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("已覆盖：统计视图预演", systemImage: "checkmark.circle.fill")
                    Label("已覆盖：分享导出任务列表", systemImage: "checkmark.circle.fill")
                    Label("可继续扩展：Widget / iCloud / Dark Mode", systemImage: "arrow.right.circle")
                }
                .font(.subheadline)
            }

            BookTipView(
                title: "项目实战注意事项",
                points: [
                    "把前面学过的状态、输入、列表、持久化能力串起来，才算真正形成项目思维。",
                    "先保证结构清晰，再往里塞功能；项目越大越要抗拒“大 View 一锅炖”。",
                    "实战页最适合继续演进成你自己的练手项目。"
                ]
            )
        }
    }
}

private struct Chapter30PlanningDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "目标", value: "任务管理", tint: .blue)
                MetricBadge(title: "功能", value: "新增 / 删除 / 筛选", tint: .green)
                MetricBadge(title: "扩展", value: "统计 / 分享", tint: .orange)
            }

            Text("最后一章最像真正项目：先做清楚范围，再决定结构和实现。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct Chapter30MVVMDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "Model", value: "TaskItem", tint: .blue)
            MetricBadge(title: "ViewModel", value: "状态与动作", tint: .green)
            MetricBadge(title: "View", value: "列表与输入", tint: .orange)
        }
    }
}

private struct Chapter30ModelDesignDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("模型最少要有：`id`、`title`、`isDone`。")
                .font(.headline)
            Text("如果你后面继续扩展，还可以再加：截止时间、优先级、标签、创建时间。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct Chapter30TaskRowDemo: View {
    @State private var isDone = false

    var body: some View {
        HStack {
            Button {
                isDone.toggle()
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text("实现 TaskRow 行视图")
                .strikethrough(isDone)

            Spacer()

            Text("高优先级")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.12), in: Capsule())
        }
    }
}

private struct Chapter30ViewModelConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("保存任务数组", systemImage: "checkmark.circle")
            Label("处理新增 / 删除 / 切换完成", systemImage: "checkmark.circle")
            Label("提供过滤结果和统计值", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

private struct ProjectPracticeTaskBoardDemo: View {
    @StateObject private var viewModel = Chapter30TaskBoardViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("新增任务", text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        viewModel.addTask()
                        isInputFocused = false
                    }

                Button("添加") {
                    viewModel.addTask()
                    isInputFocused = false
                }
                .buttonStyle(.borderedProminent)
            }

            Picker("筛选", selection: $viewModel.filter) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                MetricBadge(title: "总数", value: "\(viewModel.tasks.count)", tint: .blue)
                MetricBadge(title: "已完成", value: "\(viewModel.tasks.filter(\.isDone).count)", tint: .green)
                MetricBadge(title: "未完成", value: "\(viewModel.tasks.filter { !$0.isDone }.count)", tint: .orange)
            }

            if viewModel.tasks.isEmpty == false {
                ShareLink(item: viewModel.exportText) {
                    Label("导出 / 分享任务列表", systemImage: "square.and.arrow.up")
                }
                .font(.subheadline)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("扩展挑战预演")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 12) {
                    challengeBar(title: "完成", count: viewModel.completedCount, color: .green)
                    challengeBar(title: "待办", count: viewModel.pendingCount, color: .orange)
                }
                .frame(height: 110)

                Text("教材里提到的小组件、数据统计、分享能力，这里我先帮你把“分享”和“统计”做进来了。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.filteredTasks) { task in
                HStack {
                    Button {
                        viewModel.toggleTask(id: task.id)
                    } label: {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(task.isDone ? .green : .secondary)
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
                Divider()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false
        }
    }

    private func challengeBar(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.25))
                .frame(width: 48, height: max(18, CGFloat(count) * 22))
                .overlay(alignment: .top) {
                    Text("\(count)")
                        .font(.caption.bold())
                        .padding(.top, 6)
                }
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

private enum TaskFilter: CaseIterable {
    case all
    case active
    case completed

    var title: String {
        switch self {
        case .all: return "全部"
        case .active: return "未完成"
        case .completed: return "已完成"
        }
    }
}

private struct Chapter30TaskItem: Identifiable {
    let id = UUID()
    let title: String
    var isDone: Bool
}

private final class Chapter30TaskBoardViewModel: ObservableObject {
    @Published var tasks: [Chapter30TaskItem] = [
        Chapter30TaskItem(title: "完成第 30 章实战页", isDone: false),
        Chapter30TaskItem(title: "给任务列表加筛选", isDone: true),
        Chapter30TaskItem(title: "继续补网络与持久化能力", isDone: false)
    ]
    @Published var inputText = ""
    @Published var filter: TaskFilter = .all

    var completedCount: Int {
        tasks.filter(\.isDone).count
    }

    var pendingCount: Int {
        tasks.filter { !$0.isDone }.count
    }

    var exportText: String {
        tasks.enumerated().map { index, task in
            "\(index + 1). [\(task.isDone ? "x" : " ")] \(task.title)"
        }.joined(separator: "\n")
    }

    var filteredTasks: [Chapter30TaskItem] {
        switch filter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isDone }
        case .completed:
            return tasks.filter(\.isDone)
        }
    }

    func addTask() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        tasks.insert(Chapter30TaskItem(title: trimmed, isDone: false), at: 0)
        inputText = ""
    }

    func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isDone.toggle()
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }
}

#Preview {
    SwiftUIBookCourseHubView()
}
