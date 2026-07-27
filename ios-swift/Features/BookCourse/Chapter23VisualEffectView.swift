import SwiftUI
import CoreData
import UIKit

struct Chapter23VisualEffectView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 23,
            title: "高级视觉效果",
            introduction: "这章适合你建立“视觉语言”直觉：阴影、模糊、遮罩、混合模式，都是在让同一套数据呈现出更好的层次感。"
        ) {
            BookDemoCard(
                title: "1. 混合模式（blendMode）",
                summary: "对应教材第一部分。先直观看几种常见混合模式叠加后的差异。"
            ) {
                BlendModeDemo()
            }

            BookDemoCard(
                title: "2. 遮罩与裁剪（mask / clipShape）",
                summary: "对应教材第二部分。遮罩更偏“按内容显隐”，裁剪更偏“按形状收边界”。"
            ) {
                MaskAndClipDemo()
            }

            BookDemoCard(
                title: "3. 阴影、发光与模糊",
                summary: "对应教材第三、第四部分。它们都影响视觉层次，但职责并不一样。"
            ) {
                VisualEffectPaletteDemo()
            }

            BookDemoCard(
                title: "4. 组合效果实战",
                summary: "对应教材第五部分。把混合模式、遮罩、阴影、模糊叠在一起，做一个更完整的视觉卡片。"
            ) {
                CompositeVisualEffectDemo()
            }

            BookDemoCard(
                title: "5. 视觉效果架构图",
                summary: "教材最后会把 API 再按职责归类。你可以先按“改变轮廓 / 改变光感 / 改变叠加方式”理解。"
            ) {
                HStack {
                    MetricBadge(title: "轮廓", value: "mask / clip", tint: .pink)
                    MetricBadge(title: "光感", value: "shadow / blur", tint: .purple)
                    MetricBadge(title: "叠加", value: "blendMode", tint: .indigo)
                }
            }

            BookTipView(
                title: "视觉效果注意事项",
                points: [
                    "效果越多，越要克制，不要把页面做成“每一层都在发光”。",
                    "视觉特效常常带来额外渲染开销，复杂场景要留意性能。",
                    "先保证信息层级清晰，再决定加哪些装饰效果。"
                ]
            )
        }
    }
}

private struct BlendModeDemo: View {
    @State private var mode: BlendMode = .screen

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.indigo.gradient)
                    .frame(height: 160)

                Circle()
                    .fill(.pink)
                    .frame(width: 100, height: 100)
                    .offset(x: -24)

                Circle()
                    .fill(.cyan)
                    .frame(width: 100, height: 100)
                    .offset(x: 24)
                    .blendMode(mode)
            }

            Picker("混合模式", selection: $mode) {
                Text("screen").tag(BlendMode.screen)
                Text("multiply").tag(BlendMode.multiply)
                Text("overlay").tag(BlendMode.overlay)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct MaskAndClipDemo: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.blue.gradient)
                .frame(height: 140)
                .mask {
                    VStack(spacing: 8) {
                        Image(systemName: "swift")
                            .font(.system(size: 40))
                        Text("MASK")
                            .font(.title3.bold())
                    }
                }

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.gradient)
                .frame(height: 140)
                .clipShape(Capsule())
        }
    }
}

private struct VisualEffectPaletteDemo: View {
    @State private var blurRadius: Double = 0
    @State private var glow: Double = 8
    @State private var progress: Double = 0.65

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.indigo.gradient)
                    .frame(height: 180)

                Circle()
                    .fill(.pink)
                    .frame(width: 110, height: 110)
                    .offset(x: -36, y: -12)
                    .blendMode(.screen)
                    .blur(radius: blurRadius)

                Capsule()
                    .fill(.white.opacity(0.85))
                    .frame(width: 170 * progress, height: 26)
                    .mask(alignment: .leading) {
                        Capsule()
                            .frame(width: 170, height: 26)
                    }
                    .offset(y: 48)
                    .shadow(color: .white.opacity(0.6), radius: glow)
            }

            Text("模糊：\(Int(blurRadius))  发光：\(Int(glow))  进度：\(Int(progress * 100))%")
                .font(.footnote)

            Slider(value: $blurRadius, in: 0...14)
            Slider(value: $glow, in: 0...22)
            Slider(value: $progress, in: 0.1...1)
        }
    }
}

private struct CompositeVisualEffectDemo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black.gradient)
                .frame(height: 200)

            Circle()
                .fill(.pink)
                .frame(width: 110, height: 110)
                .blur(radius: 18)
                .offset(x: -60, y: -30)

            Circle()
                .fill(.cyan)
                .frame(width: 110, height: 110)
                .blur(radius: 18)
                .offset(x: 60, y: 10)
                .blendMode(.screen)

            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .frame(height: 120)
                .padding(.horizontal, 20)
                .overlay {
                    Text("组合效果卡片")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                .shadow(color: .white.opacity(0.12), radius: 14)
        }
    }
}

// MARK: - 第 24 章：辅助功能
