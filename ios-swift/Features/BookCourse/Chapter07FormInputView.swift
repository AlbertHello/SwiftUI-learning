import SwiftUI
import CoreData
import UIKit

struct Chapter7FormInputView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 7,
            title: "表单与用户输入",
            introduction: "表单是业务开发最常见的页面形态之一。你需要熟悉输入、选择、开关、步进器这些最基础的输入控件。"
        ) {
            BookDemoCard(
                title: "1. 核心控件速览",
                summary: "对应教材里的控件详解：输入、选择、开关、步进器这几类在表单里最常见。"
            ) {
                HStack {
                    MetricBadge(title: "输入", value: "TextField", tint: .blue)
                    MetricBadge(title: "选择", value: "Picker", tint: .green)
                    MetricBadge(title: "开关", value: "Toggle", tint: .orange)
                    MetricBadge(title: "数值", value: "Stepper", tint: .purple)
                }
            }

            BookDemoCard(
                title: "2. 迷你注册表单",
                summary: "把几个高频输入控件放进同一块区域，快速建立手感。"
            ) {
                Chapter7MiniFormDemo()
            }

            BookDemoCard(
                title: "3. 完整表单学习页",
                summary: "你前面已经补过键盘回收和更多控件组合，这里直接接入完整版本。"
            ) {
                NavigationLink("打开完整 Form Demo") {
                    RegistrationFormView()
                }
                .buttonStyle(.borderedProminent)
            }

            BookTipView(
                title: "第 7 章最佳实践",
                points: [
                    "表单输入要尽量减少用户来回切换焦点的成本。",
                    "输入组件很多时，优先考虑分组和摘要展示。",
                    "提交前最好给用户一个清晰的当前表单摘要。"
                ]
            )
        }
    }
}

private struct Chapter7MiniFormDemo: View {
    @State private var name = ""
    @State private var level = 1
    @State private var receivePush = true
    @State private var favoriteTopic = "动画"

    private let topics = ["动画", "布局", "网络", "并发"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("昵称", text: $name)
                .textFieldStyle(.roundedBorder)

            Picker("最想学的主题", selection: $favoriteTopic) {
                ForEach(topics, id: \.self) { topic in
                    Text(topic).tag(topic)
                }
            }
            .pickerStyle(.menu)

            Stepper("当前等级：\(level)", value: $level, in: 1...10)
            Toggle("接收学习提醒", isOn: $receivePush)

            Text("表单摘要：\(name.isEmpty ? "未填写昵称" : name) / \(favoriteTopic) / Level \(level)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
