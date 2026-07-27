import SwiftUI
import CoreData
import UIKit

struct Chapter24AccessibilityView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 24,
            title: "辅助功能",
            introduction: "无障碍不是额外工作，而是 UI 定义的一部分。给 VoiceOver 合理的标签、值、提示，能让界面真正被更多人使用。"
        ) {
            BookDemoCard(
                title: "1. 基础按钮无障碍化",
                summary: "对应教材里的第一个实战示例：给按钮补充 label、hint 和 traits。"
            ) {
                AccessibilityButtonDemo()
            }

            BookDemoCard(
                title: "2. 自定义视图组无障碍",
                summary: "对应教材里的第二个实战示例：把多个视觉元素组合成一个可被 VoiceOver 更好理解的整体。"
            ) {
                AccessibilityRatingDemo()
            }

            BookDemoCard(
                title: "3. 常见无障碍 Traits",
                summary: "教材会专门提 traits。你可以把它理解成给辅助功能系统的“角色标签”。"
            ) {
                AccessibilityTraitsDemo()
            }

            BookDemoCard(
                title: "4. 调试与测试",
                summary: "无障碍不只是写修饰符，还要知道怎么检查自己的页面有没有被正确朗读。"
            ) {
                AccessibilityDebugChecklistDemo()
            }

            BookDemoCard(
                title: "5. 无障碍检查清单",
                summary: "教材这章核心不是背修饰符，而是形成检查习惯：标签、值、提示、分组、可点击区域。"
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("给控件一个清晰 label", systemImage: "checkmark.circle")
                    Label("状态型控件补 value", systemImage: "checkmark.circle")
                    Label("复杂组合用 combine / ignore", systemImage: "checkmark.circle")
                    Label("交互区域足够大", systemImage: "checkmark.circle")
                }
                .font(.subheadline)
            }

            BookTipView(
                title: "辅助功能注意事项",
                points: [
                    "不要只让界面“看起来可用”，还要让它“被朗读时也可理解”。",
                    "多个视觉元素表达同一个语义时，通常应该组合成一个无障碍元素。",
                    "给自定义控件补辅助标签和提示，是把 UI 做完整的一部分。"
                ]
            )
        }
    }
}

private struct AccessibilityButtonDemo: View {
    @State private var didSubmit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(didSubmit ? "已加入学习计划" : "加入学习计划") {
                didSubmit.toggle()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("加入学习计划")
            .accessibilityHint("双击后会把当前课程加入计划")
            .accessibilityAddTraits(.isButton)

            Text("这个按钮即使视觉文案变化，辅助功能名称也保持稳定。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct AccessibilityRatingDemo: View {
    @State private var rating = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                        .font(.title2)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("课程评分")
            .accessibilityValue("\(rating) 星，共 5 星")
            .accessibilityHint("左右滑动可听到当前评分")

            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                VStack(alignment: .leading) {
                    Text("Swift 初学者")
                    Text("已学习第 24 章辅助功能")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("学习状态卡片")
            .accessibilityValue("Swift 初学者，已学习第 24 章辅助功能")
        }
    }
}

private struct AccessibilityTraitsDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "按钮", value: ".isButton", tint: .blue)
            MetricBadge(title: "选中", value: ".isSelected", tint: .green)
            MetricBadge(title: "标题", value: ".isHeader", tint: .orange)
        }
    }
}

private struct AccessibilityDebugChecklistDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("打开 VoiceOver 逐项检查朗读是否自然", systemImage: "checkmark.circle")
            Label("确认组合元素是否被重复朗读", systemImage: "checkmark.circle")
            Label("检查按钮和可点击区域是否足够大", systemImage: "checkmark.circle")
        }
        .font(.subheadline)
    }
}

// MARK: - 第 25 章：测试与调试
