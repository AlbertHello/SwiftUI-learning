import SwiftUI
import CoreData
import UIKit

struct Chapter11ModifiersView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 11,
            title: "视图修饰符",
            introduction: "这一章最重要的心智模型是：SwiftUI 的修饰符不是“改掉原对象”，而是基于旧 View 继续包装出一个新 View。你可以把它理解成一层一层包裹。"
        ) {
            BookDemoCard(
                title: "1. 系统修饰符实验台",
                summary: "调字体、颜色、阴影、圆角，直观看 `font / foregroundStyle / padding / background` 叠加后的结果。"
            ) {
                ModifierPlaygroundDemo()
            }

            BookDemoCard(
                title: "2. 自定义 ViewModifier",
                summary: "当同一组样式要被多个地方复用时，不要到处复制粘贴，应该提炼成自定义修饰符。"
            ) {
                CustomModifierDemo()
            }

            BookDemoCard(
                title: "3. 实战练习：渐变 / 脉动 / 新拟物卡片",
                summary: "对应教材第 11 章的练习：`GradientBackgroundModifier`、`PulseAnimationModifier`、`NeumorphismModifier`，以及它们的组合效果。"
            ) {
                Chapter11ExerciseModifiersDemo()
            }

            BookTipView(
                title: "这一章要记住",
                points: [
                    "修饰符的顺序很重要，`.padding().background()` 和 `.background().padding()` 的视觉结果不同。",
                    "自定义 `ViewModifier` 很适合沉淀业务里的“统一卡片样式”“统一标题样式”。",
                    "UIKit 里你常常是改 view 的属性；SwiftUI 里更常见的是不断返回新的 View 组合。"
                ]
            )
        }
    }
}

private struct ModifierPlaygroundDemo: View {
    @State private var fontSize: Double = 24
    @State private var isHighlighted = true
    @State private var useShadow = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SwiftUI 修饰符真的是一层一层包上去的")
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(isHighlighted ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(isHighlighted ? Color.blue : Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: useShadow ? .blue.opacity(0.25) : .clear, radius: 12, y: 6)

            VStack(alignment: .leading, spacing: 8) {
                Text("字体大小：\(Int(fontSize))")
                Slider(value: $fontSize, in: 16...34, step: 1)
                Toggle("高亮模式", isOn: $isHighlighted)
                Toggle("阴影效果", isOn: $useShadow)
            }
            .font(.subheadline)
        }
    }
}

/// 自定义修饰符示例。
///
/// 这个写法和 OC 里“封一个分类方法统一配置按钮样式”的目标很像，
/// 只是 SwiftUI 更推荐把样式抽成 `ViewModifier`。
private struct EmphasisCardModifier: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(tint.opacity(0.35), lineWidth: 1)
            }
    }
}

private extension View {
    func emphasisCard(tint: Color) -> some View {
        modifier(EmphasisCardModifier(tint: tint))
    }
}

private struct CustomModifierDemo: View {
    @State private var useWarningStyle = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("切换到提醒样式", isOn: $useWarningStyle)

            Text(useWarningStyle ? "库存告急，请尽快补货。" : "库存健康，今日无需补货。")
                .emphasisCard(tint: useWarningStyle ? .red : .green)
        }
    }
}

private struct GradientBackgroundModifier: ViewModifier {
    let colors: [Color]

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 18)
            )
    }
}

private struct PulseAnimationModifier: ViewModifier {
    let isPulsing: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.08 : 0.94)
            .opacity(isPulsing ? 1 : 0.76)
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)
    }
}

private struct NeumorphismModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .white.opacity(0.9), radius: 8, x: -6, y: -6)
            .shadow(color: .black.opacity(0.12), radius: 8, x: 6, y: 6)
    }
}

private extension View {
    func gradientBackground(colors: [Color]) -> some View {
        modifier(GradientBackgroundModifier(colors: colors))
    }

    func pulseAnimation(isActive: Bool) -> some View {
        modifier(PulseAnimationModifier(isPulsing: isActive))
    }

    func neumorphismCard() -> some View {
        modifier(NeumorphismModifier())
    }
}

private struct Chapter11ExerciseModifiersDemo: View {
    @State private var isPulsing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("渐变背景修饰符")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .gradientBackground(colors: [.blue, .purple])

            HStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.15), in: Circle())
                    .pulseAnimation(isActive: isPulsing)

                VStack(alignment: .leading, spacing: 4) {
                    Text("脉动提醒")
                        .font(.headline)
                    Text("这个效果很适合做待办提醒、消息提示、弱引导。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                isPulsing = true
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("新拟物练习卡片")
                    .font(.headline)
                Text("把多个自定义修饰符组合起来后，就能沉淀出一套风格统一的卡片系统。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .neumorphismCard()
        }
    }
}

// MARK: - 第 12 章：组合与复用

