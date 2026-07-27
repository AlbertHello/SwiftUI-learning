import SwiftUI
import CoreData
import UIKit

struct Chapter9AdvancedAnimationView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 9,
            title: "高级动画",
            introduction: "第 9 章已经和我们做过的高级动画页高度对应。这里我把教材主题和现有 demo 串起来，方便你顺着学。"
        ) {
            BookDemoCard(
                title: "1. Animatable / GeometryEffect 总览",
                summary: "对应教材前两部分。你要先分清：一个偏“数据插值”，一个偏“几何变换”。"
            ) {
                HStack {
                    MetricBadge(title: "数值插值", value: "Animatable", tint: .blue)
                    MetricBadge(title: "几何变化", value: "GeometryEffect", tint: .orange)
                    MetricBadge(title: "节奏控制", value: "自定义曲线", tint: .purple)
                }
            }

            BookDemoCard(
                title: "2. 高级动画重点",
                summary: "教材关键词：Animatable / GeometryEffect / 自定义曲线 / 粒子系统。"
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("这些内容你前面已经在高级动画学习页里摸过一遍，现在可以带着教材术语重新回看，会更容易把“现象”和“原理”对上。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            BookDemoCard(
                title: "3. 完整高级动画页",
                summary: "包含数字补间、波浪 Shape、GeometryEffect 跳跃、自定义 timing curve 和粒子系统。"
            ) {
                NavigationLink("打开完整高级动画 Demo") {
                    AdvancedAnimationLearningView()
                }
                .buttonStyle(.borderedProminent)
            }

            BookTipView(
                title: "第 9 章学习重点",
                points: [
                    "高级动画的关键不是 API 多，而是知道动画在哪一层发生。",
                    "数值变化和几何变化虽然都在动，但思维模型不同。",
                    "复杂动画最好拆开看，再组合。"
                ]
            )
        }
    }
}
