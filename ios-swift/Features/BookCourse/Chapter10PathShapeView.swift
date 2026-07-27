import SwiftUI
import CoreData
import UIKit

struct Chapter10PathShapeView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 10,
            title: "绘图与形状",
            introduction: "第 10 章就是我们刚才补强过的 Path / Shape 学习页。这一章很值得多点几次，因为它会直接影响你以后做图形化 UI 和自定义进度视图。"
        ) {
            BookDemoCard(
                title: "1. Path / Shape 关系总览",
                summary: "Path 负责定义路径，Shape 把路径封装成可复用视图；内置图形解决大多数业务底图，自定义图形解决特殊视觉需求。"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("重点 API：move(to:) / addLine(to:) / closeSubpath() / trim(from:to:)")
                        .font(.headline)
                    Text("你可以把这一章看成后面高级动画、视觉效果、加载控件的基础。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            BookDemoCard(
                title: "2. 最小 Path 示例",
                summary: "对应教材入门阶段最该先理解的部分：先能亲手画出一条简单路径。"
            ) {
                Chapter10MiniPathDemo()
            }

            BookDemoCard(
                title: "3. 完整 Path / Shape 页",
                summary: "包含三角形 Path、内置 Shape、自定义五角星、trim 动画和票券形状动画。"
            ) {
                NavigationLink("打开完整 Path / Shape Demo") {
                    PathShapeLearningView()
                }
                .buttonStyle(.borderedProminent)
            }

            BookTipView(
                title: "第 10 章学习重点",
                points: [
                    "先理解路径是怎么画出来的，再去记复杂形状。",
                    "自定义图形最好参数化，这样后面动画才能复用。",
                    "`trim` 很适合做进度、描边、路径出现效果。"
                ]
            )
        }
    }
}

private struct Chapter10MiniPathDemo: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 20, y: 100))
            path.addLine(to: CGPoint(x: 110, y: 20))
            path.addLine(to: CGPoint(x: 200, y: 100))
        }
        .stroke(Color.indigo, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
        .frame(height: 120)
        .background(Color.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - 第 11 章：修饰符
