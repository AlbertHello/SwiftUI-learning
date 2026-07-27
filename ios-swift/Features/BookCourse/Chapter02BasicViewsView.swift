import SwiftUI
import CoreData
import UIKit

struct Chapter2BasicViewsView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 2,
            title: "基础视图",
            introduction: "第二章是在认识 SwiftUI 最常见的基础组件。你可以把它理解成“工具箱开箱”：先知道每种控件擅长干什么。"
        ) {
            BookDemoCard(
                title: "1. 基础控件画廊",
                summary: "把 `Text / Image / Label / Button / Toggle / ProgressView` 放在同一页，方便你感受它们的职责差异。"
            ) {
                Chapter2BasicViewsDemo()
            }

            BookDemoCard(
                title: "2. 布局与辅助组件",
                summary: "对应教材里的布局与辅助组件部分，把 `Spacer / Divider / GroupBox` 这类“不是主角但很常用”的组件放在一起看。"
            ) {
                Chapter2HelperViewsDemo()
            }

            BookDemoCard(
                title: "3. 组合使用示例",
                summary: "对应教材里的布局示例：把基础控件组合成一块真正像页面的内容。"
            ) {
                Chapter2CombinedCardDemo()
            }

            BookTipView(
                title: "第二章学习重点",
                points: [
                    "不要孤立记每个控件，最好记“它在页面里通常承担什么职责”。",
                    "`Spacer`、`Divider` 这类辅助组件虽然小，但会高频出现。",
                    "真正开发时，基础控件的价值在于被组合成完整页面。"
                ]
            )
        }
    }
}

private struct Chapter2HelperViewsDemo: View {
    var body: some View {
        GroupBox("辅助组件实验") {
            VStack(spacing: 10) {
                HStack {
                    Text("左侧")
                    Spacer()
                    Text("Spacer 把空间撑开")
                }
                Divider()
                Text("GroupBox 适合把一组内容包起来")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct Chapter2CombinedCardDemo: View {
    @State private var liked = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "swift")
                .font(.system(size: 34))
                .foregroundStyle(.orange)
                .frame(width: 56, height: 56)
                .background(Color.orange.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("SwiftUI 学习卡片")
                    .font(.headline)
                Text("把 Text、Image、Button 组合起来，就是一个有业务感的区块。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                liked.toggle()
            } label: {
                Image(systemName: liked ? "heart.fill" : "heart")
                    .foregroundStyle(liked ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct Chapter2BasicViewsDemo: View {
    @State private var isDownloading = false
    @State private var progress: Double = 0.4

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SwiftUI 基础视图组件")
                .font(.title3.bold())

            Label("这是 Label：图标 + 文案 的常用组合", systemImage: "star.fill")
                .foregroundStyle(.orange)

            HStack(spacing: 12) {
                Image(systemName: "iphone.gen3")
                    .font(.system(size: 34))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Image 用来显示图像")
                    Text("Text 用来显示纯文本")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Toggle("模拟下载中", isOn: $isDownloading)

            ProgressView(value: progress)
                .tint(isDownloading ? .blue : .green)

            Button("推进进度") {
                withAnimation {
                    progress = min(progress + 0.1, 1)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
