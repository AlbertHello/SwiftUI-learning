import SwiftUI
import CoreData
import UIKit

struct Chapter1IntroductionView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 1,
            title: "SwiftUI 初探",
            introduction: "第一章最重要的是建立正确心智模型：SwiftUI 不是“手动改界面”，而是“状态变了，界面重新描述”。这和 UIKit 的命令式更新思维很不一样。"
        ) {
            BookDemoCard(
                title: "1. 声明式 UI 小实验",
                summary: "点击按钮不是去手动改 label 背景，而是改状态；状态变了，View 根据新状态重新渲染。"
            ) {
                Chapter1DeclarativeDemo()
            }

            BookDemoCard(
                title: "2. 核心思想拆解",
                summary: "对应教材里的核心思想：声明式语法、单一数据源、组合优于继承、跨平台一致性。"
            ) {
                HStack {
                    MetricBadge(title: "声明式", value: "描述结果", tint: .blue)
                    MetricBadge(title: "单一真相", value: "State", tint: .green)
                    MetricBadge(title: "组合", value: "小组件拼装", tint: .orange)
                    MetricBadge(title: "跨平台", value: "同一思路", tint: .purple)
                }
            }

            BookDemoCard(
                title: "3. 快速开始：第一个 SwiftUI 视图",
                summary: "对应教材最后的快速开始。这里用最小化欢迎页，帮助你把 `Text + Button + 状态` 串起来。"
            ) {
                Chapter1FirstViewDemo()
            }

            BookTipView(
                title: "第一章核心结论",
                points: [
                    "SwiftUI 的重点不是“怎么找到某个控件”，而是“当前状态下界面应该长什么样”。",
                    "单一数据源意味着：尽量让一份状态成为事实来源，别在多处复制同一份真相。",
                    "组合优于继承：大页面拆小组件，再把小组件拼回去。"
                ]
            )
        }
    }
}

private struct Chapter1FirstViewDemo: View {
    @State private var username = "Swift 初学者"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.indigo.opacity(0.14))
                .frame(height: 110)
                .overlay {
                    VStack(spacing: 8) {
                        Text("你好，\(username)")
                            .font(.title3.bold())
                        Text("这就是一个最小 SwiftUI 视图组合")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

            Button("切换成游客名称") {
                username = username == "Swift 初学者" ? "游客" : "Swift 初学者"
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct Chapter1DeclarativeDemo: View {
    @State private var isStudying = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 18)
                .fill(isStudying ? Color.blue : Color.gray.opacity(0.16))
                .frame(height: 120)
                .overlay {
                    VStack(spacing: 8) {
                        Text(isStudying ? "正在学习 SwiftUI" : "点击下方按钮开始学习")
                            .font(.headline)
                            .foregroundStyle(isStudying ? .white : .primary)
                        Text("这里只由 `isStudying` 一个状态驱动")
                            .font(.footnote)
                            .foregroundStyle(isStudying ? .white.opacity(0.9) : .secondary)
                    }
                }

            Button(isStudying ? "切回待机状态" : "开始学习") {
                withAnimation(.spring) {
                    isStudying.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
