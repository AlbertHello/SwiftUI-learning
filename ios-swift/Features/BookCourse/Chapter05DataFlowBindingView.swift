import SwiftUI
import CoreData
import UIKit

struct Chapter5DataFlowBindingView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 5,
            title: "数据流与绑定",
            introduction: "这一章最值得吃透的是 `Binding`。父视图掌管真状态，子视图拿到一条“可读可写的引用通道”，这样数据流就既清晰又可控。"
        ) {
            BookDemoCard(
                title: "1. 单向数据流架构图",
                summary: "对应教材里的核心概念。数据通常自上而下流动，事件再自下而上回传。"
            ) {
                HStack {
                    MetricBadge(title: "状态下发", value: "Parent -> Child", tint: .blue)
                    MetricBadge(title: "事件回传", value: "Child -> Action", tint: .green)
                    MetricBadge(title: "桥梁", value: "Binding", tint: .orange)
                }
            }

            BookDemoCard(
                title: "2. 父子组件双向编辑",
                summary: "父视图持有任务标题，子组件只通过 `@Binding` 编辑它。"
            ) {
                Chapter5BindingDemo()
            }

            BookDemoCard(
                title: "3. 属性包装器与协议位置感",
                summary: "对应教材里的 `@ObservedObject / @StateObject / @Published / ObservableObject` 说明。"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("`ObservableObject` 负责“我是一类可被观察的数据对象”。")
                    Text("`@Published` 负责“我的某个字段变了，要通知界面”。")
                    Text("`@StateObject` 负责“当前 View 拥有这个对象”。")
                    Text("`@ObservedObject` 负责“当前 View 只是观察它，不拥有它”。")
                }
                .font(.subheadline)
            }

            BookDemoCard(
                title: "4. 实战：任务管理器",
                summary: "对应教材里的任务管理器方向。这里给一个最小任务流：新增、切换完成、自动刷新。"
            ) {
                Chapter5TaskManagerDemo()
            }

            BookTipView(
                title: "第 5 章常见陷阱",
                points: [
                    "不要让子组件自己偷偷复制一份父状态，容易造成双份真相。",
                    "对象谁创建，谁拥有；观察者不要顺手变成拥有者。",
                    "数据流越单向，问题越容易查。"
                ]
            )
        }
    }
}

private final class Chapter5TaskStore: ObservableObject {
    @Published var tasks: [String] = ["理解单向数据流", "练习 Binding"]

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        tasks.insert(trimmed, at: 0)
    }
}

private struct Chapter5BindingDemo: View {
    @State private var taskTitle = "学习第 5 章：Binding"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("父视图当前值：\(taskTitle)")
                .font(.headline)

            Chapter5BindingEditor(title: $taskTitle)
        }
    }
}

private struct Chapter5BindingEditor: View {
    @Binding var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("编辑任务标题", text: $title)
                .textFieldStyle(.roundedBorder)

            Text("子组件并不拥有数据，它只是通过 Binding 改父组件的状态。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct Chapter5TaskManagerDemo: View {
    @StateObject private var store = Chapter5TaskStore()
    @State private var input = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("输入任务", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button("新增") {
                    store.addTask(input)
                    input = ""
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(store.tasks, id: \.self) { task in
                Text(task)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                Divider()
            }
        }
    }
}
