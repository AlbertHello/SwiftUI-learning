//
//  CustomAnimationView.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

/// 高级动画学习页。
///
/// 这一页专门讲几类“比基础动画再往前一步”的能力：
/// 1. `AnimatableModifier`：让数字、进度这类值平滑补间
/// 2. `Shape + animatableData`：让自定义图形本身参与动画
/// 3. `GeometryEffect`：直接控制几何变换，做出跳跃、抖动、翻转这类效果
/// 4. 自定义动画曲线：不满足系统默认曲线时，自己定义节奏
/// 5. 粒子效果：把多个小元素组合成一个更“有氛围感”的动效
///
/// 如果你是 UIKit / Flutter 背景，可以先这样建立映射：
/// - `AnimatableModifier` ≈ 给“显示层结果”做插值
/// - `GeometryEffect` ≈ 对 View 做自定义 transform 动画
/// - 粒子效果 ≈ 一组小 View 各自带延迟和路径，最后组合成一个爆发动画
struct AdvancedAnimationLearningView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SwiftUI 高级动画")
                        .font(.largeTitle.bold())

                    Text("这一页不只是看效果，而是把 Animatable、GeometryEffect、自定义曲线和粒子系统拆开讲，方便你理解“为什么这样写”。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                AdvancedAnimationSectionCard(
                    title: "1. AnimatableModifier：数字补间",
                    summary: "最适合做分数增长、金额滚动、进度数字刷新。重点不是 View 怎么移动，而是“显示的值”怎么被平滑插值。"
                ) {
                    AnimatedCounterDemoView()
                }

                AdvancedAnimationSectionCard(
                    title: "2. Shape 动画：波浪加载条",
                    summary: "自定义 Shape 只要把关键参数放进 `animatableData`，SwiftUI 就能自动帮你把形状从旧状态补间到新状态。"
                ) {
                    WavyLoadingDemoView()
                }

                AdvancedAnimationSectionCard(
                    title: "3. GeometryEffect：跳跃几何动画",
                    summary: "当你想直接控制位移、旋转、缩放路径时，`GeometryEffect` 会比堆 modifier 更清晰。"
                ) {
                    JumpingBallDemoView()
                }

                AdvancedAnimationSectionCard(
                    title: "4. 自定义节奏：弹跳勋章",
                    summary: "默认 `easeInOut` 不够有个性时，可以自己定义 timing curve，让动画更像真实产品里的反馈。"
                ) {
                    CustomCurveBadgeDemoView()
                }

                AdvancedAnimationSectionCard(
                    title: "5. 粒子系统：完成时爆发",
                    summary: "把多个小粒子延迟发射、分散运动、逐渐淡出，就能做出完成态、庆祝态、点赞态常见的“氛围动效”。"
                ) {
                    ParticleSystemDemoView()
                }
            }
            .padding()
        }
        .navigationTitle("高级动画")
        .background(Color(.systemGroupedBackground))
    }
}

/// 学习页里每一段示例卡片。
///
/// 这个封装的目的有两个：
/// 1. 让每个高级动画示例看起来像一张独立“知识卡”
/// 2. 后面继续扩充 demo 时，不需要重复写卡片外壳
private struct AdvancedAnimationSectionCard<Content: View>: View {
    let title: String
    let summary: String
    let content: Content

    init(
        title: String,
        summary: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.summary = summary
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())

            Text(summary)
                .font(.footnote)
                .foregroundStyle(.secondary)

            content
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - 1. AnimatableModifier：数字补间

/// 这个 modifier 的作用是“把一个 Double 以动画方式显示成整数文本”。
///
/// 为什么这里不用普通 `Text("\(value)")`？
/// - 因为普通 Text 只会看到值瞬间切换
/// - `AnimatableModifier` 则允许 SwiftUI 在动画过程中不断传入中间值
/// - 所以用户看到的就不是“100 -> 800”硬切，而是一个滚动增长的过程
private struct AnimatedNumberTextModifier: AnimatableModifier {
    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    func body(content: Content) -> some View {
        Text("\(Int(value.rounded()))")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.blue)
    }
}

private extension View {
    func animatedNumberText(_ value: Double) -> some View {
        modifier(AnimatedNumberTextModifier(value: value))
    }
}

struct AnimatedCounterDemoView: View {
    @State private var score: Double = 128

    var body: some View {
        VStack(spacing: 16) {
            Text("今日积分")
                .font(.headline)

            Color.clear
                .frame(height: 1)
                .animatedNumberText(score)

            Text("点击按钮，观察数字是怎么被平滑补间到新值的。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button("+120") {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        score += 120
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    withAnimation(.snappy(duration: 0.5)) {
                        score = 128
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - 2. Shape 动画：波浪加载条

/// 一个能参与动画的波浪形状。
///
/// 关键点在 `animatableData`：
/// - `waveOffset` 决定波浪往前走了多少
/// - `amplitude` 决定浪高
/// - `frequency` 决定一个宽度里出现多少个波峰
///
/// 只要把这些关键参数放进 `animatableData`，SwiftUI 就知道：
/// “哦，这几个值变化时，我应该生成中间帧，而不是直接切到新形状。”
struct WavyRectangle: Shape {
    var waveOffset: Double
    var amplitude: Double
    var frequency: Double

    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get {
            AnimatablePair(waveOffset, AnimatablePair(amplitude, frequency))
        }
        set {
            waveOffset = newValue.first
            amplitude = newValue.second.first
            frequency = newValue.second.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height / 2))

        for x in stride(from: 0.0, through: width, by: 1.0) {
            let relativeX = x / width
            let y = height / 2 + sin(relativeX * frequency * .pi * 2 + waveOffset) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}

struct WavyLoadingDemoView: View {
    @State private var waveOffset: Double = 0
    @State private var amplitude: Double = 12
    @State private var frequency: Double = 2.4
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.blue.opacity(0.08))
                    .frame(height: 130)

                VStack(spacing: 12) {
                    WavyRectangle(
                        waveOffset: waveOffset,
                        amplitude: amplitude,
                        frequency: frequency
                    )
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Text(isAnimating ? "波浪加载中..." : "点击开始波浪动画")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            VStack(spacing: 10) {
                HStack {
                    Text("浪高")
                        .font(.footnote)
                    Slider(value: $amplitude, in: 4...24, step: 1)
                }

                HStack {
                    Text("频率")
                        .font(.footnote)
                    Slider(value: $frequency, in: 1...4, step: 0.1)
                }
            }

            HStack {
                Button(isAnimating ? "停止" : "开始") {
                    toggleWave()
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    isAnimating = false
                    waveOffset = 0
                    withAnimation(.easeInOut(duration: 0.3)) {
                        amplitude = 12
                        frequency = 2.4
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            toggleWave(startIfNeeded: true)
        }
    }

    private func toggleWave(startIfNeeded: Bool = false) {
        if !isAnimating {
            isAnimating = true
            waveOffset = 0
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 2
            }
        } else if !startIfNeeded {
            isAnimating = false
            waveOffset = 0
        }
    }
}

// MARK: - 3. GeometryEffect：跳跃几何动画

/// 一个自定义几何效果：让球体按“抛物线 + 轻微旋转”的路径跳起来。
///
/// 为什么这里更适合 `GeometryEffect`？
/// - 因为我们要同时控制平移和旋转
/// - 而且这些变化并不是简单的“某个固定 offset 值”
/// - 它们是跟 `phase` 这个进度一起计算出来的一整条运动路径
struct JumpEffect: GeometryEffect {
    var height: CGFloat
    var phase: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(height, phase) }
        set {
            height = newValue.first
            phase = newValue.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let normalizedPhase = max(0, min(1, phase))
        let jumpHeight = -sin(normalizedPhase * .pi) * height
        let rotation = sin(normalizedPhase * .pi * 2) * 8

        var transform = CGAffineTransform(translationX: 0, y: jumpHeight)
        transform = transform.rotated(by: rotation * .pi / 180)
        return ProjectionTransform(transform)
    }
}

struct JumpingBallDemoView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.black.opacity(0.08))
                    .frame(width: 120, height: 16)
                    .scaleEffect(x: 1 - phase * 0.25, y: 1 - phase * 0.15)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .modifier(JumpEffect(height: 70, phase: phase))
                    .shadow(color: .orange.opacity(0.3), radius: 12, y: 8)
            }
            .frame(height: 180)

            Text("点击按钮，观察球体不是单纯上移，而是按一条几何路径运动。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("跳一下") {
                phase = 0
                withAnimation(.easeInOut(duration: 0.75)) {
                    phase = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    phase = 0
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - 4. 自定义曲线

/// 一个“带回弹感”的 timing curve。
///
/// 默认的 `easeInOut` 比较平稳，但真实产品里的完成态、勋章弹出、奖励出现
/// 往往会更想要“先冲出来，再轻轻回一下”的感觉。
extension Animation {
    static func lessonBounce(duration: TimeInterval = 0.8) -> Animation {
        .timingCurve(0.68, -0.55, 0.3, 1.45, duration: duration)
    }
}

struct CustomCurveBadgeDemoView: View {
    @State private var showBadge = false
    @State private var useCustomCurve = true

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.yellow.opacity(0.1))
                    .frame(height: 170)

                Image(systemName: "medal.star.fill")
                    .font(.system(size: 78))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(showBadge ? 1 : 0.2)
                    .rotationEffect(.degrees(showBadge ? 0 : -20))
                    .opacity(showBadge ? 1 : 0)
                    .shadow(color: .orange.opacity(0.28), radius: 16, y: 8)
            }

            Toggle("使用自定义回弹曲线", isOn: $useCustomCurve)
                .toggleStyle(.switch)

            HStack {
                Button(showBadge ? "收起奖章" : "弹出奖章") {
                    let animation = useCustomCurve
                        ? Animation.lessonBounce(duration: 0.82)
                        : Animation.easeInOut(duration: 0.82)

                    withAnimation(animation) {
                        showBadge.toggle()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    showBadge = false
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - 5. 粒子系统

/// 高级动画里常见的“粒子运动效果”。
///
/// 这里把 `Bool` 改成了 `progress`，这是一个很关键的修正：
/// - 之前如果只传 `isActive`
/// - `GeometryEffect` 很难拿到 0 -> 1 的连续插值过程
/// - 改成 `CGFloat progress` 后，SwiftUI 才能真正对半径、旋转做中间帧补间
struct ParticleMotionEffect: GeometryEffect {
    let index: Int
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let angle = Double(index) / 18 * .pi * 2
        let radius = progress * 90

        let x = cos(angle) * radius
        let y = sin(angle) * radius
        let translation = CGAffineTransform(translationX: x, y: y)
        let rotation = CGAffineTransform(rotationAngle: angle * Double(progress))

        return ProjectionTransform(translation.concatenating(rotation))
    }
}

struct ParticleDotView: View {
    let index: Int
    let progress: CGFloat

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 8, height: 8)
            .scaleEffect(0.3 + progress * 0.9)
            .opacity(Double(1 - progress * 0.55))
            .modifier(ParticleMotionEffect(index: index, progress: progress))
    }
}

struct ParticleSystemDemoView: View {
    @State private var burstProgress: CGFloat = 0
    private let particleCount = 18

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 260)

                ForEach(0..<particleCount, id: \.self) { index in
                    ParticleDotView(index: index, progress: burstProgress)
                }

                VStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.white)
                        .scaleEffect(1 + burstProgress * 0.08)

                    Text("任务完成")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }

            Text("点击按钮后，粒子会从中心向外爆发。这类写法很适合完成态、庆祝态、点赞态。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button("播放粒子") {
                    burstProgress = 0
                    withAnimation(.easeOut(duration: 1.0)) {
                        burstProgress = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                        burstProgress = 0
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("停在终点") {
                    withAnimation(.easeOut(duration: 0.6)) {
                        burstProgress = 1
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AdvancedAnimationLearningView()
    }
}
