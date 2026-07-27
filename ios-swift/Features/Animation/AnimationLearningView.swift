//
//  AnmationDemo.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

/// 动画学习总页。
///
/// 这里把多种常见动画示例收在同一个界面里：
/// 1. 隐式动画：状态变化后，系统按你声明的 animation 自动补间
/// 2. 显式动画：用 `withAnimation {}` 包住状态修改，明确指定这次变化要带动画
/// 3. 过渡动画：控制“某个 View 插入/移除”时怎么出现、怎么消失
/// 4. 按钮反馈：真实 App 里很常见的按下缩放、点赞弹跳
/// 5. Toast 横幅：网络请求成功/失败后，从顶部或底部滑出的提示
/// 6. 卡片展开：列表卡片点击后放大展开，是很多内容类 App 常见的过渡方式
/// 7. 完成庆祝：任务完成后让奖章弹出、轻微晃动，强化“完成了”的反馈
///
/// 如果你是 Flutter / UIKit 背景，可以先这样记：
/// - 隐式动画 ≈ Flutter `AnimatedContainer`
/// - 显式动画 ≈ 手动触发一次动画事务
/// - 过渡动画 ≈ 控制一个子 View show/hide 时的进入退出效果
struct AnimationLearningView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("SwiftUI 常用动画合集")
                    .font(.largeTitle.bold())

                Text("除了基础概念，这里还补了真实开发里常见的按钮反馈、Toast、卡片展开。你可以把它当成一份随手可抄的动画备忘录。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                AnimationSectionCard(
                    title: "1. 隐式动画",
                    summary: "给某个 View 声明 `.animation(..., value:)`，当状态变化时，相关属性会自动带动画变化。"
                ) {
                    ImplicitAnimationView()
                }

                AnimationSectionCard(
                    title: "2. 显式动画",
                    summary: "用 `withAnimation` 把某次状态修改包起来，精确控制“这一次变化”该用什么动画。"
                ) {
                    ExplicitAnimationView()
                }

                AnimationSectionCard(
                    title: "3. 过渡动画",
                    summary: "当某个 View 被插入或移除时，用 `.transition(...)` 定义它的出现和消失方式。"
                ) {
                    TransitionView()
                }

                AnimationSectionCard(
                    title: "4. 按钮反馈动画",
                    summary: "按钮按下时轻微缩放、阴影变化，点击后图标再做一次弹跳，这是很常见的交互反馈动画。"
                ) {
                    PressFeedbackAnimationView()
                }

                AnimationSectionCard(
                    title: "5. Toast / Banner 动画",
                    summary: "请求结果提示、保存成功提示，经常会从顶部或底部滑入，再过一会自动消失。"
                ) {
                    ToastBannerAnimationView()
                }

                AnimationSectionCard(
                    title: "6. 卡片展开动画",
                    summary: "用 `matchedGeometryEffect` 在“小卡片”和“大详情卡片”之间建立几何关联，做出更顺滑的展开过渡。"
                ) {
                    MatchedGeometryAnimationView()
                }

                AnimationSectionCard(
                    title: "7. 任务完成庆祝动画",
                    summary: "结合缩放、旋转、透明度和弹簧动画，让奖章图标在点击后弹出并轻微晃动。这类动效很适合任务完成、闯关成功、勋章解锁。"
                ) {
                    TaskCompletionCelebrationView()
                }
            }
            .padding()
        }
        .navigationTitle("动画学习页")
        .background(Color(.systemGroupedBackground))
    }
}

/// 每种动画示例外面包一层卡片，方便在一个页面里分段展示。
private struct AnimationSectionCard<Content: View>: View {
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
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ImplicitAnimationView: View {
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // 这里最典型的特征是：
            // - 我们没有在按钮点击时显式写 `withAnimation`
            // - 只是声明：当 `isExpanded` 改变时，Circle 的这些属性要带动画
            // - 这就是“隐式动画”
            Circle()
                .fill(isExpanded ? Color.orange : Color.green)
                .frame(width: isExpanded ? 150 : 80,
                       height: isExpanded ? 150 : 80)
                .shadow(color: isExpanded ? .orange.opacity(0.35) : .green.opacity(0.25), radius: isExpanded ? 20 : 8)
                .animation(.easeInOut(duration: 0.8), value: isExpanded)

            Button("切换状态") {
                isExpanded.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ExplicitAnimationView: View {
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 30) {
            // 显式动画更适合“同一个状态，不同按钮触发时想用不同动画”的场景。
            Rectangle()
                .fill(Color.purple)
                .frame(width: 100, height: 100)
                .offset(x: offsetX)
                .rotationEffect(.degrees(rotation))

            ViewThatFits(in: .vertical) {
                HStack {
                    moveButton
                    rotateButton
                }

                VStack(spacing: 12) {
                    moveButton
                    rotateButton
                }
            }

            Button("重置") {
                withAnimation(.smooth(duration: 0.45)) {
                    offsetX = 0
                    rotation = 0
                }
            }
        }
    }

    private var moveButton: some View {
        Button("向右移动") {
            // 同样是改状态，但这里明确指定“这一次”用弹簧动画。
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                offsetX += 50
            }
        }
        .buttonStyle(.borderedProminent)
    }

    private var rotateButton: some View {
        Button("旋转") {
            // 这里又换成了线性动画。
            // 这就是显式动画的自由度：同一个 View，不同交互用不同动画策略。
            withAnimation(.linear(duration: 1.0)) {
                rotation += 180
            }
        }
        .buttonStyle(.bordered)
    }
}


struct TransitionView: View {
    @State private var showDetails = false

    var body: some View {
        VStack(spacing: 20) {
            Button(showDetails ? "隐藏详情" : "显示详情") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showDetails.toggle()
                }
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            if showDetails {
                // `transition` 只在“插入 / 移除”时生效：
                // - 它不负责一个 View 内部属性怎么变
                // - 它负责这个 View 整体怎么进场、怎么退场
                Text("🎉 这里是详细的说明内容！")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .slide.combined(with: .opacity)
                    ))
            }

            Color.clear
                .frame(height: 1)
        }
    }
}

/// 按钮反馈动画。
///
/// 这是实际开发里非常常见的一类：
/// - 点击按钮时先有“按下”的缩放反馈
/// - 动作完成后图标再做一次弹跳，告诉用户“操作成功触发了”
struct PressFeedbackAnimationView: View {
    @State private var likeCount = 12
    @State private var didLike = false

    var body: some View {
        VStack(spacing: 18) {
            Text("点赞数：\(likeCount)")
                .font(.headline)

            HStack(spacing: 16) {
                Button {
                    didLike.toggle()
                    likeCount += didLike ? 1 : -1
                } label: {
                    Label(didLike ? "已点赞" : "点赞", systemImage: didLike ? "heart.fill" : "heart")
                        .font(.headline)
                        .frame(minWidth: 110)
                }
                .buttonStyle(PressScaleButtonStyle(tint: didLike ? .pink : .blue))
                .symbolEffect(.bounce, value: didLike)

                Button("收藏") {
                }
                .buttonStyle(PressScaleButtonStyle(tint: .orange))
            }

            Text("这种按钮反馈通常用在点赞、收藏、提交、购买等关键操作上。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

/// 自定义按钮样式：按下时缩小一点、阴影变浅一点。
///
/// 这可以类比 UIKit 里给按钮加一个按压态 transform：
/// - 按下：`scale = 0.96`
/// - 松开：回到 `1.0`
private struct PressScaleButtonStyle: ButtonStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(tint.gradient, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .shadow(color: tint.opacity(configuration.isPressed ? 0.12 : 0.28), radius: configuration.isPressed ? 4 : 10, y: configuration.isPressed ? 2 : 6)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

/// Toast / Banner 动画。
///
/// 这类动画在 App 里很实用：
/// - 保存成功
/// - 网络失败
/// - 已加入购物车
/// - 已复制到剪贴板
struct ToastBannerAnimationView: View {
    @State private var showBanner = false
    @State private var bannerMessage = "保存成功"

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.blue.opacity(0.08))
                    .frame(height: 140)

                if showBanner {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(bannerMessage)
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85), in: Capsule())
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Text("点击下面的按钮，观察提示条从顶部滑入再淡出。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 74)
            }

            HStack {
                Button("成功提示") {
                    showToast(message: "资料已保存")
                }
                .buttonStyle(.borderedProminent)

                Button("复制提示") {
                    showToast(message: "已复制链接")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func showToast(message: String) {
        bannerMessage = message
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            showBanner = true
        }

        // 真实项目里常见写法：展示一小会儿后自动收回。
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.28)) {
                showBanner = false
            }
        }
    }
}

/// 卡片展开动画。
///
/// `matchedGeometryEffect` 是 SwiftUI 很有代表性的“共享几何动画”：
/// - 小卡片和大卡片不是同一个 View
/// - 但你告诉系统：它们本质上代表同一个内容
/// - 系统就会帮你把位置、尺寸、圆角等变化补成一条连续动画
struct MatchedGeometryAnimationView: View {
    @Namespace private var cardNamespace
    @State private var isExpanded = false

    var body: some View {
        ZStack {
            if !isExpanded {
                collapsedCard
            } else {
                expandedCard
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.52, dampingFraction: 0.86), value: isExpanded)
    }

    private var collapsedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("推荐专题")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            Text("SwiftUI 动画实践")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("点我展开，看卡片如何平滑过渡到详情视图。")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .matchedGeometryEffect(id: "card_background", in: cardNamespace)
        .onTapGesture {
            isExpanded = true
        }
    }

    private var expandedCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("SwiftUI 动画实践")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Spacer()

                Button("关闭") {
                    isExpanded = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.22))
            }

            Text("这是很多资讯、音乐、视频、商品类 App 都会用到的动效：先让用户点一张卡片，再把卡片流畅扩展为详情页。")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.88))

            Label("共享几何动画", systemImage: "sparkles")
                .foregroundStyle(.white)

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 250, alignment: .topLeading)
        .background(
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 24)
        )
        .matchedGeometryEffect(id: "card_background", in: cardNamespace)
    }
}

/// 任务完成庆祝动画。
///
/// 这个示例故意把几种常见属性动画揉在一起：
/// - `scaleEffect`：从小到大弹出来，营造“奖章出现”的感觉
/// - `rotationEffect`：轻微左右晃动，让结果更有生命力
/// - `opacity`：避免图标生硬地突然出现
/// - `spring`：让整个出现过程更像真实界面里的“完成反馈”
///
/// 这是业务里很常见的一类场景：
/// - 今日任务完成
/// - 勋章解锁
/// - 打卡成功
/// - 成就达成
struct TaskCompletionCelebrationView: View {
    @State private var isCompleted = false
    @State private var wiggleAngle: Double = 0
    @State private var statusText = "点击按钮，模拟任务完成"

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.yellow.opacity(0.12))
                    .frame(height: 190)

                VStack(spacing: 12) {
                    Image(systemName: "medal.star.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // 缩放：未出现时更小，完成后用弹簧动画弹出来。
                        .scaleEffect(isCompleted ? 1.0 : 0.18)
                        // 旋转：先从轻微倾斜开始，再在出现后做左右小幅晃动。
                        .rotationEffect(.degrees(isCompleted ? wiggleAngle : -25))
                        // 透明度：从 0 到 1，让出现过程更自然。
                        .opacity(isCompleted ? 1.0 : 0.0)
                        .shadow(color: .orange.opacity(0.28), radius: 14, y: 8)

                    Text(statusText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Button(isCompleted ? "重新播放" : "完成任务") {
                    playCelebration()
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    resetCelebration()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    /// 播放一次“任务完成”动画。
    ///
    /// 这里拆成两个阶段更容易理解：
    /// 1. 先让奖章用弹簧动画弹出来
    /// 2. 再给它一个很轻的左右晃动
    ///
    /// 这种写法和实际业务很像：
    /// - 主反馈先到达
    /// - 细节装饰动画随后补上
    private func playCelebration() {
        resetCelebration()
        statusText = "任务完成，奖励已送达"

        withAnimation(.spring(response: 0.48, dampingFraction: 0.55)) {
            isCompleted = true
        }

        // 等奖章先弹出来，再开始做轻微晃动。
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.14).repeatCount(6, autoreverses: true)) {
                wiggleAngle = 10
            }
        }

        // 晃动结束后把角度收回到 0，停在一个稳定的完成态。
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeOut(duration: 0.18)) {
                wiggleAngle = 0
            }
        }
    }

    /// 把界面回到初始状态，方便重复演示。
    private func resetCelebration() {
        isCompleted = false
        wiggleAngle = 0
        statusText = "点击按钮，模拟任务完成"
    }
}

//#Preview {
//    NavigationStack {
//        AnimationLearningView()
//    }
//}
