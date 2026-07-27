import SwiftUI
import CoreData
import UIKit

struct Chapter13GestureView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 13,
            title: "手势识别",
            introduction: "SwiftUI 的手势也是声明式的。你描述“这个 View 响应什么手势、发生后状态怎么变化”，系统负责把识别流程串起来。"
        ) {
            BookDemoCard(
                title: "1. 点击、长按、拖拽",
                summary: "把几个最常用的手势放到一个交互卡片里，观察不同手势对状态的影响。"
            ) {
                GesturePlaygroundDemo()
            }

            BookDemoCard(
                title: "2. 缩放 + 旋转手势",
                summary: "这是教程里明确提到但之前漏掉的部分。很多图片预览、地图、白板、海报编辑器都会同时用到缩放和旋转。"
            ) {
                MagnifyRotateGestureDemo()
            }

            BookDemoCard(
                title: "3. @GestureState：临时交互状态",
                summary: "拖拽进行中这类“手指一松就该消失”的状态，很适合放在 `@GestureState` 里，而不是长期存到业务状态。"
            ) {
                GestureStateDemo()
            }

            BookDemoCard(
                title: "4. 综合示例：可交互卡片",
                summary: "把教程里的综合示例真正落成 demo：支持拖动、缩放、旋转，松手后还能平滑回弹。"
            ) {
                InteractiveGestureCardDemo()
            }

            BookDemoCard(
                title: "5. 手势冲突与组合",
                summary: "真实业务里，最常见的问题不是不会写，而是多个手势抢同一个区域。"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("组合手势时，先想清楚：是同时识别，还是一个成功后另一个失效。")
                        .font(.subheadline)
                    HStack {
                        MetricBadge(title: "离散事件", value: "Tap", tint: .blue)
                        MetricBadge(title: "持续状态", value: "Drag", tint: .orange)
                        MetricBadge(title: "模式切换", value: "LongPress", tint: .green)
                    }
                }
            }

            BookTipView(
                title: "实战建议",
                points: [
                    "短暂状态优先用 `@GestureState`，业务状态用 `@State` 或 ViewModel。",
                    "如果手势多、互相冲突，先拆成多个小区域分别处理，再考虑组合。",
                    "UIKit 里你常写 `UITapGestureRecognizer`；SwiftUI 里更强调把手势直接挂在 View 上。",
                    "缩放、旋转、拖拽这三类手势经常同时出现，做编辑器类页面时尤其要熟。"
                ]
            )
        }
    }
}

private struct GesturePlaygroundDemo: View {
    @State private var tapCount = 0
    @State private var isPressed = false
    @State private var cardOffset: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundedRectangle(cornerRadius: 22)
                .fill(isPressed ? Color.orange.gradient : Color.blue.gradient)
                .frame(height: 150)
                .overlay {
                    VStack(spacing: 8) {
                        Text("点我、长按我、拖动我")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("点击次数：\(tapCount)")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .offset(cardOffset)
                .onTapGesture {
                    tapCount += 1
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    withAnimation(.spring) {
                        isPressed.toggle()
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            cardOffset = value.translation
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                cardOffset = .zero
                            }
                        }
                )

            Text("你会发现：点击负责离散事件，长按更像进入某种模式，拖拽则持续返回位移。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MagnifyRotateGestureDemo: View {
    @State private var scale: CGFloat = 1
    @State private var rotation: Angle = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.purple.gradient)
                .frame(height: 180)
                .overlay {
                    Image(systemName: "photo.stack.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                }
                .scaleEffect(scale)
                .rotationEffect(rotation)
                .gesture(
                    SimultaneousGesture(
                        MagnifyGesture()
                            .onChanged { value in
                                scale = value.magnification
                            }
                            .onEnded { _ in
                                withAnimation(.spring) {
                                    scale = 1
                                }
                            },
                        RotationGesture()
                            .onChanged { angle in
                                rotation = angle
                            }
                            .onEnded { _ in
                                withAnimation(.spring) {
                                    rotation = .zero
                                }
                            }
                    )
                )

            Text("当前缩放：\(scale, specifier: "%.2f")，当前旋转：\(rotation.degrees, specifier: "%.0f")°")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct GestureStateDemo: View {
    @GestureState private var dragOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.green.opacity(0.2))
                .frame(height: 110)
                .overlay {
                    Text("拖我，松手后临时状态会自动清空")
                        .font(.headline)
                }
                .offset(
                    x: accumulatedOffset.width + dragOffset.width,
                    y: accumulatedOffset.height + dragOffset.height
                )
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            accumulatedOffset.width += value.translation.width
                            accumulatedOffset.height += value.translation.height
                        }
                )

            Text("临时偏移：(\(Int(dragOffset.width)), \(Int(dragOffset.height)))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct InteractiveGestureCardDemo: View {
    @State private var finalOffset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var pinchScale: CGFloat = 1
    @GestureState private var rotationAngle: Angle = .zero
    @State private var baseScale: CGFloat = 1
    @State private var baseRotation: Angle = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 210)
                .overlay {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.image.fill")
                            .font(.system(size: 44))
                        Text("综合示例：可交互卡片")
                            .font(.headline)
                        Text("拖动、缩放、旋转都可以同时试")
                            .font(.footnote)
                    }
                    .foregroundStyle(.white)
                }
                .scaleEffect(baseScale * pinchScale)
                .rotationEffect(baseRotation + rotationAngle)
                .offset(
                    x: finalOffset.width + dragOffset.width,
                    y: finalOffset.height + dragOffset.height
                )
                .gesture(combinedGesture)

            Button("回到初始状态") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    finalOffset = .zero
                    baseScale = 1
                    baseRotation = .zero
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var combinedGesture: some Gesture {
        let drag = DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                finalOffset.width += value.translation.width
                finalOffset.height += value.translation.height
            }

        let magnify = MagnifyGesture()
            .updating($pinchScale) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                baseScale *= value.magnification
            }

        let rotate = RotationGesture()
            .updating($rotationAngle) { value, state, _ in
                state = value
            }
            .onEnded { value in
                baseRotation += value
            }

        return SimultaneousGesture(
            drag,
            SimultaneousGesture(magnify, rotate)
        )
    }
}

// MARK: - 第 14 章：拖放
