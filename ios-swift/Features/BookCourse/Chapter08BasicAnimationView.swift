import SwiftUI
import CoreData
import UIKit

struct Chapter8BasicAnimationView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 8,
            title: "动画基础",
            introduction: "第 8 章对应我们已经做过的基础动画学习页。这里先给你一个缩略版预热，再提供入口进入完整动画实验场。"
        ) {
            BookDemoCard(
                title: "1. 隐式 / 显式 / 过渡 总览",
                summary: "对应教材前三部分，先把基础动画分类建立起来。"
            ) {
                HStack {
                    MetricBadge(title: "隐式", value: ".animation", tint: .blue)
                    MetricBadge(title: "显式", value: "withAnimation", tint: .pink)
                    MetricBadge(title: "进出场", value: "transition", tint: .purple)
                }
            }

            BookDemoCard(
                title: "2. 缩略版动画预演",
                summary: "点按钮后观察缩放和透明度变化，感受最基础的状态驱动动画。"
            ) {
                Chapter8AnimationPreviewDemo()
            }

            BookDemoCard(
                title: "3. 动画曲线预演",
                summary: "对应教材的动画曲线章节。不同曲线会直接影响同一个动效的性格。"
            ) {
                Chapter8CurveDemo()
            }

            BookDemoCard(
                title: "4. 完整基础动画页",
                summary: "包含隐式动画、显式动画、过渡、按钮反馈、Toast、卡片展开、任务完成动效。"
            ) {
                NavigationLink("打开完整基础动画 Demo") {
                    AnimationLearningView()
                }
                .buttonStyle(.borderedProminent)
            }

            BookTipView(
                title: "第 8 章最佳实践",
                points: [
                    "先让动画服务于反馈和层级，再追求炫。",
                    "曲线不同，用户感受到的“性格”会很不一样。",
                    "基础动画学扎实了，后面的高级动画会轻松很多。"
                ]
            )
        }
    }
}

private struct Chapter8CurveDemo: View {
    @State private var move = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 20, height: 20)
                    .offset(x: move ? 140 : 0)
                    .animation(.easeInOut(duration: 0.8), value: move)

                Circle()
                    .fill(.pink)
                    .frame(width: 20, height: 20)
                    .offset(x: move ? 140 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.55), value: move)
            }
            .frame(height: 40)

            Button("切换曲线效果") {
                move.toggle()
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct Chapter8AnimationPreviewDemo: View {
    @State private var animate = false

    var body: some View {
        VStack(spacing: 14) {
            Circle()
                .fill(animate ? Color.purple.gradient : Color.blue.gradient)
                .frame(width: animate ? 130 : 90, height: animate ? 130 : 90)
                .scaleEffect(animate ? 1.05 : 0.9)
                .opacity(animate ? 1 : 0.7)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: animate)

            Button("切换动画") {
                animate.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
    }
}
