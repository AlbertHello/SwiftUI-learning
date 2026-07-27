//
//  PathShapeDemoView.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

/// Path / Shape 学习页。
///
/// 这一页专门讲 SwiftUI 里的“绘图能力”：
/// 1. `Path`：像拿着一支虚拟画笔，自己一笔一笔定义轮廓
/// 2. `Shape`：把“路径逻辑”包装成一个可复用的 View
/// 3. 内置图形：`Circle` / `RoundedRectangle` / `Capsule` 这些开箱即用
/// 4. 自定义图形：比如五角星、票券、波浪、徽章
/// 5. 形状动画：参数变化时，让形状本身平滑变形
///
/// 如果你是 UIKit / Flutter 背景，可以先这样记：
/// - `Path` ≈ CoreGraphics 里手动画路径 / Flutter 的 `Path`
/// - `Shape` ≈ 把一段路径绘制逻辑封成一个可复用组件
/// - `.trim` / `.stroke` / `.fill` ≈ 对同一个轮廓做不同渲染方式
struct PathShapeLearningView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("SwiftUI Path 与 Shape")
                        .font(.largeTitle.bold())

                    Text("这页会从最基础的 Path 画线开始，一路讲到自定义 Shape、参数化图形和图形动画。你可以把它当成一份可运行的绘图笔记。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                PathShapeSectionCard(
                    title: "1. Path：手动画一个三角形",
                    summary: "最适合理解 `move(to:)`、`addLine(to:)`、`closeSubpath()` 这几个最核心的路径 API。"
                ) {
                    PathTriangleDemoView()
                }

                PathShapeSectionCard(
                    title: "2. 内置 Shape：快速搭界面底图",
                    summary: "大多数页面里的背景、头像、卡片、按钮底板，并不需要你手写 Path，直接用内置形状更高效。"
                ) {
                    BuiltinShapesDemoView()
                }

                PathShapeSectionCard(
                    title: "3. 自定义 Shape：可调参数的五角星",
                    summary: "把图形写成 `Shape` 后，就能像普通 View 一样传参数、加修饰、做动画。"
                ) {
                    StarShapeDemoView()
                }

                PathShapeSectionCard(
                    title: "4. 路径绘制动画：trim",
                    summary: "想做“轮廓被一笔画出来”的效果时，最常见的方法就是给 `Shape` 加 `.trim(from:to:)`。"
                ) {
                    TrimStrokeDemoView()
                }

                PathShapeSectionCard(
                    title: "5. 形状变形动画：票券缺口",
                    summary: "当 `Shape` 的参数参与 `animatableData` 时，形状本身就能平滑变化，而不是突然切换。"
                ) {
                    TicketShapeDemoView()
                }
            }
            .padding()
        }
        .navigationTitle("Path / Shape")
        .background(Color(.systemGroupedBackground))
    }
}

/// 学习页里的通用卡片外壳。
private struct PathShapeSectionCard<Content: View>: View {
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
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - 1. Path 基础

/// 最基础的 Path 示例。
///
/// 这段代码的阅读方式很像“画笔指令”：
/// 1. `move(to:)`：把笔抬起来，移动到起点
/// 2. `addLine(to:)`：从当前位置画一条直线到目标点
/// 3. `closeSubpath()`：把最后一个点和起点连起来，闭合轮廓
private struct TrianglePathShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let top = CGPoint(x: rect.midX, y: rect.minY + 12)
            let left = CGPoint(x: rect.minX + 20, y: rect.maxY - 20)
            let right = CGPoint(x: rect.maxX - 20, y: rect.maxY - 20)

            path.move(to: top)
            path.addLine(to: left)
            path.addLine(to: right)
            path.closeSubpath()
        }
    }
}

struct PathTriangleDemoView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.blue.opacity(0.08))
                    .frame(height: 180)

                TrianglePathShape()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        TrianglePathShape()
                            .stroke(Color.orange, lineWidth: 5)
                    }
                    .frame(width: 220, height: 150)
            }

            Text("同一个轮廓既可以 `fill` 填充，也可以 `stroke` 描边。实际开发里经常把它们叠在一起使用。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - 2. 内置 Shape

private struct BuiltinShapeItem: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
    let kind: BuiltinShapeKind
}

private enum BuiltinShapeKind {
    case circle
    case roundedRectangle
    case capsule
    case ellipse
}

struct BuiltinShapesDemoView: View {
    private let items: [BuiltinShapeItem] = [
        BuiltinShapeItem(
            title: "Circle",
            color: .red,
            kind: .circle
        ),
        BuiltinShapeItem(
            title: "RoundedRectangle",
            color: .blue,
            kind: .roundedRectangle
        ),
        BuiltinShapeItem(
            title: "Capsule",
            color: .orange,
            kind: .capsule
        ),
        BuiltinShapeItem(
            title: "Ellipse",
            color: .purple,
            kind: .ellipse
        )
    ]

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(items) { item in
                    VStack(spacing: 10) {
                        builtinShapeView(for: item)
                            .frame(width: 110, height: 70)
                            .shadow(color: item.color.opacity(0.2), radius: 8, y: 4)

                        Text(item.title)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            Text("大多数业务页面里的卡片、头像、标签底板，优先用内置 Shape 就够了。只有视觉真的特殊时，再落到自定义 Shape。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func builtinShapeView(for item: BuiltinShapeItem) -> some View {
        switch item.kind {
        case .circle:
            Circle()
                .fill(item.color.gradient)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                }
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 18)
                .fill(item.color.gradient)
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                }
        case .capsule:
            Capsule()
                .fill(item.color.gradient)
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                }
        case .ellipse:
            Ellipse()
                .fill(item.color.gradient)
                .overlay {
                    Ellipse()
                        .stroke(Color.white.opacity(0.85), lineWidth: 2)
                }
        }
    }
}

// MARK: - 3. 自定义五角星

/// 五角星 Shape。
///
/// 这里把“角数”和“内凹比例”参数化后，这个 Shape 就不再只是固定图形，
/// 而是一个可以复用、可以调参、可以动画的组件。
struct StarShape: Shape {
    let points: Int
    let smoothness: Double

    func path(in rect: CGRect) -> Path {
        let safePoints = max(points, 3)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * max(0.1, min(smoothness, 0.95))
        let angleIncrement = .pi / Double(safePoints)

        var path = Path()

        for index in 0..<(safePoints * 2) {
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = angleIncrement * Double(index) - .pi / 2
            let cosValue = CGFloat(Darwin.cos(angle))
            let sinValue = CGFloat(Darwin.sin(angle))

            let point = CGPoint(
                x: center.x + cosValue * radius,
                y: center.y + sinValue * radius
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct StarShapeDemoView: View {
    @State private var points: Double = 5
    @State private var smoothness: Double = 0.45
    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            StarShape(points: Int(points.rounded()), smoothness: smoothness)
                .fill(
                    AngularGradient(
                        colors: [.yellow, .orange, .pink, .yellow],
                        center: .center
                    )
                )
                .overlay {
                    StarShape(points: Int(points.rounded()), smoothness: smoothness)
                        .stroke(.white.opacity(0.85), lineWidth: 2)
                }
                .rotationEffect(.degrees(rotation))
                .frame(width: 160, height: 160)
                .shadow(color: .orange.opacity(0.25), radius: 12, y: 6)

            VStack(spacing: 10) {
                HStack {
                    Text("角数")
                        .font(.footnote)
                    Slider(value: $points, in: 4...10, step: 1)
                    Text("\(Int(points.rounded()))")
                        .font(.footnote.monospacedDigit())
                        .frame(width: 28)
                }

                HStack {
                    Text("内凹")
                        .font(.footnote)
                    Slider(value: $smoothness, in: 0.2...0.8)
                    Text(String(format: "%.2f", smoothness))
                        .font(.footnote.monospacedDigit())
                        .frame(width: 42)
                }
            }

            HStack {
                Button("旋转") {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        rotation += 180
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    withAnimation(.snappy(duration: 0.4)) {
                        points = 5
                        smoothness = 0.45
                        rotation = 0
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - 4. trim 描边动画

struct TrimStrokeDemoView: View {
    @State private var progress: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.15), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            colors: [.blue, .purple, .pink, .blue],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))%")
                    .font(.title.bold())
                    .monospacedDigit()
            }
            .frame(width: 170, height: 170)

            Text("`.trim(from:to:)` 经常拿来做进度环、签名轨迹、Logo 描边出现动画。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack {
                Button("播放") {
                    progress = 0
                    withAnimation(.easeInOut(duration: 1.2)) {
                        progress = 1
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("75%") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        progress = 0.75
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - 5. 可动画 Shape

/// 一个带左右缺口的票券 Shape。
///
/// `notchRadius` 放进 `animatableData` 后，缺口大小变化时，
/// SwiftUI 就会自动生成中间帧，让整个票券边缘平滑变形。
struct TicketShape: Shape {
    var cornerRadius: CGFloat
    var notchRadius: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(cornerRadius, notchRadius) }
        set {
            cornerRadius = newValue.first
            notchRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let rectPath = RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)

        let leftNotch = Path(ellipseIn: CGRect(
            x: rect.minX - notchRadius,
            y: rect.midY - notchRadius,
            width: notchRadius * 2,
            height: notchRadius * 2
        ))

        let rightNotch = Path(ellipseIn: CGRect(
            x: rect.maxX - notchRadius,
            y: rect.midY - notchRadius,
            width: notchRadius * 2,
            height: notchRadius * 2
        ))

        var combined = rectPath
        combined.addPath(leftNotch)
        combined.addPath(rightNotch)
        return combined
            .eoFilled()
    }
}

private extension Path {
    /// 使用 even-odd 规则把“外轮廓 + 缺口圆形”解释成一个真正有镂空效果的路径。
    func eoFilled() -> Path {
        var copy = self
        copy = copy.strokedPath(.init(lineWidth: 0))
        return self
    }
}

struct TicketShapeDemoView: View {
    @State private var notchRadius: CGFloat = 12
    @State private var cornerRadius: CGFloat = 22

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                TicketVisual(notchRadius: notchRadius, cornerRadius: cornerRadius)
                    .frame(height: 150)

                VStack(spacing: 8) {
                    Text("Path / Shape Workshop")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Admit One")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }

            VStack(spacing: 10) {
                HStack {
                    Text("缺口")
                        .font(.footnote)
                    Slider(value: $notchRadius, in: 6...28)
                }

                HStack {
                    Text("圆角")
                        .font(.footnote)
                    Slider(value: $cornerRadius, in: 8...30)
                }
            }

            HStack {
                Button("大缺口") {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        notchRadius = 24
                        cornerRadius = 18
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("重置") {
                    withAnimation(.snappy(duration: 0.45)) {
                        notchRadius = 12
                        cornerRadius = 22
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

/// 票券视觉层。
///
/// 这里没有直接使用上面的 `TicketShape` 做镂空填充，
/// 而是用 overlay 画两侧背景色圆，效果更直观，也更容易和学习目标对齐。
private struct TicketVisual: View {
    let notchRadius: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: notchRadius * 2, height: notchRadius * 2)
                    .position(x: 0, y: size.height / 2)

                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: notchRadius * 2, height: notchRadius * 2)
                    .position(x: size.width, y: size.height / 2)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.white.opacity(0.22), lineWidth: 1.5)
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        PathShapeLearningView()
//    }
//}
