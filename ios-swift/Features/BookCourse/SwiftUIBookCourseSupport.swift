import SwiftUI
import CoreData
import UIKit

/// 《SwiftUI 从入门到精通》1-30 章学习中心。
///
/// 设计目标：
/// 1. 严格按章节顺序组织，方便你和教材一一对照。
/// 2. 每章尽量给一个“能运行、能交互、能观察状态变化”的学习 demo。
/// 3. 注释尽量写清楚“为什么”，而不是只说“这里写了什么”。
/// 4. 延续我们前面 demo 页的风格：`ScrollView + VStack`、卡片化、适合逐块学习。
///
/// 如果你是 OC / UIKit 背景，可以把它理解成：
/// - 一个“课程目录 VC”
/// - 点进去后再进入每一章对应的示例页
/// - 只是这里的页面拼装方式换成了 SwiftUI 的声明式写法
struct SwiftUIBookCourseHubView: View {
    var body: some View {
        NavigationStack {
            List(SwiftUIBookChapter.allCases) { chapter in
                NavigationLink {
                    chapterView(for: chapter)
                } label: {
                    SwiftUIBookChapterRow(chapter: chapter)
                }
            }
            .navigationTitle("SwiftUI 1-30 章")
        }
    }

    /// 用 `@ViewBuilder` 把不同章节映射到不同页面。
    ///
    /// 这和 UIKit 里在 `didSelectRowAt` 根据 row push 不同 VC 的思路很像。
    @ViewBuilder
    private func chapterView(for chapter: SwiftUIBookChapter) -> some View {
        switch chapter {
        case .chapter1:
            Chapter1IntroductionView()
        case .chapter2:
            Chapter2BasicViewsView()
        case .chapter3:
            Chapter3LayoutContainersView()
        case .chapter4:
            Chapter4StateManagementView()
        case .chapter5:
            Chapter5DataFlowBindingView()
        case .chapter6:
            Chapter6ListNavigationView()
        case .chapter7:
            Chapter7FormInputView()
        case .chapter8:
            Chapter8BasicAnimationView()
        case .chapter9:
            Chapter9AdvancedAnimationView()
        case .chapter10:
            Chapter10PathShapeView()
        case .chapter11:
            Chapter11ModifiersView()
        case .chapter12:
            Chapter12CompositionView()
        case .chapter13:
            Chapter13GestureView()
        case .chapter14:
            Chapter14DragDropView()
        case .chapter15:
            Chapter15SystemIntegrationView()
        case .chapter16:
            Chapter16SceneWindowView()
        case .chapter17:
            Chapter17LifecycleView()
        case .chapter18:
            Chapter18NetworkView()
        case .chapter19:
            Chapter19PersistenceView()
        case .chapter20:
            Chapter20CoreDataView()
        case .chapter21:
            Chapter21ConcurrencyView()
        case .chapter22:
            Chapter22LayoutView()
        case .chapter23:
            Chapter23VisualEffectView()
        case .chapter24:
            Chapter24AccessibilityView()
        case .chapter25:
            Chapter25TestingDebugView()
        case .chapter26:
            Chapter26MultiPlatformView()
        case .chapter27:
            Chapter27WidgetView()
        case .chapter28:
            Chapter28AppClipView()
        case .chapter29:
            Chapter29PerformanceView()
        case .chapter30:
            Chapter30ProjectPracticeView()
        }
    }
}

/// 章节枚举。
///
/// 这里集中维护教材 11-30 章的标题、图标和颜色。
/// 以后你继续往后扩展时，只需要在这里补元数据，然后在 `switch` 里接上页面。
enum SwiftUIBookChapter: Int, CaseIterable, Identifiable {
    case chapter1 = 1
    case chapter2 = 2
    case chapter3 = 3
    case chapter4 = 4
    case chapter5 = 5
    case chapter6 = 6
    case chapter7 = 7
    case chapter8 = 8
    case chapter9 = 9
    case chapter10 = 10
    case chapter11 = 11
    case chapter12 = 12
    case chapter13 = 13
    case chapter14 = 14
    case chapter15 = 15
    case chapter16 = 16
    case chapter17 = 17
    case chapter18 = 18
    case chapter19 = 19
    case chapter20 = 20
    case chapter21 = 21
    case chapter22 = 22
    case chapter23 = 23
    case chapter24 = 24
    case chapter25 = 25
    case chapter26 = 26
    case chapter27 = 27
    case chapter28 = 28
    case chapter29 = 29
    case chapter30 = 30

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .chapter1: return "SwiftUI 初探"
        case .chapter2: return "基础视图"
        case .chapter3: return "布局与容器"
        case .chapter4: return "状态管理"
        case .chapter5: return "数据流与绑定"
        case .chapter6: return "列表与导航"
        case .chapter7: return "表单与用户输入"
        case .chapter8: return "动画基础"
        case .chapter9: return "高级动画"
        case .chapter10: return "绘图与形状"
        case .chapter11: return "视图修饰符"
        case .chapter12: return "视图组合与复用"
        case .chapter13: return "手势识别"
        case .chapter14: return "拖放操作"
        case .chapter15: return "系统集成"
        case .chapter16: return "场景与窗口"
        case .chapter17: return "生命周期"
        case .chapter18: return "网络请求与数据"
        case .chapter19: return "本地数据持久化"
        case .chapter20: return "Core Data 集成"
        case .chapter21: return "并发与异步"
        case .chapter22: return "自定义布局"
        case .chapter23: return "高级视觉效果"
        case .chapter24: return "辅助功能"
        case .chapter25: return "测试与调试"
        case .chapter26: return "多平台适配"
        case .chapter27: return "Widget 小组件"
        case .chapter28: return "App Clip 开发"
        case .chapter29: return "性能优化"
        case .chapter30: return "项目实战"
        }
    }

    var subtitle: String {
        switch self {
        case .chapter1: return "声明式语法、单一数据源、组合思维"
        case .chapter2: return "Text、Image、Button、Toggle、ProgressView"
        case .chapter3: return "VStack、HStack、ZStack、ScrollView"
        case .chapter4: return "@State、@StateObject、状态驱动 UI"
        case .chapter5: return "Binding、父子通信、单向数据流"
        case .chapter6: return "List、ForEach、NavigationLink"
        case .chapter7: return "TextField、Picker、Toggle、Stepper"
        case .chapter8: return "隐式动画、显式动画、过渡"
        case .chapter9: return "Animatable、GeometryEffect、自定义曲线"
        case .chapter10: return "Path、Shape、自定义图形"
        case .chapter11: return "系统修饰符、自定义 ViewModifier、条件修饰"
        case .chapter12: return "ViewBuilder、组件封装、卡片复用"
        case .chapter13: return "点击、长按、拖拽、组合手势"
        case .chapter14: return "draggable / dropDestination 实战"
        case .chapter15: return "UIViewRepresentable 与 UIKit 桥接"
        case .chapter16: return "scenePhase、WindowGroup、场景管理"
        case .chapter17: return "onAppear / onDisappear / 应用状态"
        case .chapter18: return "URLSession、加载态、错误态"
        case .chapter19: return "@AppStorage、UserDefaults、草稿保存"
        case .chapter20: return "内存版 Core Data 沙盒，增删改查"
        case .chapter21: return "Task、取消、异步流程"
        case .chapter22: return "Layout 协议、流式布局"
        case .chapter23: return "mask、clip、blur、shadow、blendMode"
        case .chapter24: return "VoiceOver、辅助标签、分组"
        case .chapter25: return "可测试 ViewModel、日志、辅助标识符"
        case .chapter26: return "紧凑 / 宽松布局适配思路"
        case .chapter27: return "时间线、尺寸适配、Widget 思维"
        case .chapter28: return "轻量入口、深链、受限能力"
        case .chapter29: return "列表、过滤、缓存、避免无效计算"
        case .chapter30: return "一个小型任务管理实战页"
        }
    }

    var icon: String {
        switch self {
        case .chapter1: return "sparkles"
        case .chapter2: return "square.text.square"
        case .chapter3: return "rectangle.3.group"
        case .chapter4: return "circle.hexagongrid"
        case .chapter5: return "arrow.triangle.branch"
        case .chapter6: return "list.bullet"
        case .chapter7: return "text.badge.plus"
        case .chapter8: return "play.circle"
        case .chapter9: return "wand.and.stars.inverse"
        case .chapter10: return "pencil.and.ruler"
        case .chapter11: return "paintbrush.pointed"
        case .chapter12: return "square.stack.3d.up"
        case .chapter13: return "hand.tap"
        case .chapter14: return "hand.draw"
        case .chapter15: return "link.circle"
        case .chapter16: return "rectangle.on.rectangle"
        case .chapter17: return "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .chapter18: return "network"
        case .chapter19: return "internaldrive"
        case .chapter20: return "cylinder.split.1x2"
        case .chapter21: return "bolt.horizontal"
        case .chapter22: return "square.grid.3x2"
        case .chapter23: return "wand.and.rays"
        case .chapter24: return "figure.wave.circle"
        case .chapter25: return "ladybug"
        case .chapter26: return "ipad.and.iphone"
        case .chapter27: return "rectangle.grid.2x2"
        case .chapter28: return "app.badge"
        case .chapter29: return "speedometer"
        case .chapter30: return "checklist"
        }
    }

    var tint: Color {
        switch self {
        case .chapter1: return .blue
        case .chapter2: return .orange
        case .chapter3: return .indigo
        case .chapter4: return .green
        case .chapter5: return .teal
        case .chapter6: return .pink
        case .chapter7: return .mint
        case .chapter8: return .purple
        case .chapter9: return .red
        case .chapter10: return .cyan
        case .chapter11: return .pink
        case .chapter12: return .orange
        case .chapter13: return .mint
        case .chapter14: return .green
        case .chapter15: return .blue
        case .chapter16: return .indigo
        case .chapter17: return .teal
        case .chapter18: return .cyan
        case .chapter19: return .brown
        case .chapter20: return .purple
        case .chapter21: return .red
        case .chapter22: return .blue
        case .chapter23: return .pink
        case .chapter24: return .green
        case .chapter25: return .orange
        case .chapter26: return .indigo
        case .chapter27: return .mint
        case .chapter28: return .purple
        case .chapter29: return .red
        case .chapter30: return .blue
        }
    }
}

private struct SwiftUIBookChapterRow: View {
    let chapter: SwiftUIBookChapter

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: chapter.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(chapter.tint.gradient, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text("第 \(chapter.rawValue) 章 · \(chapter.title)")
                    .font(.headline)

                Text(chapter.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

/// 每一章通用的外壳。
///
/// 统一把标题、章节号、简介、滚动布局固定下来，
/// 这样后面的章节实现只需要专注自己的 demo 内容。
struct BookChapterScaffold<Content: View>: View {
    let chapter: Int
    let title: String
    let introduction: String
    let content: Content

    init(
        chapter: Int,
        title: String,
        introduction: String,
        @ViewBuilder content: () -> Content
    ) {
        self.chapter = chapter
        self.title = title
        self.introduction = introduction
        self.content = content()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("第 \(chapter) 章 · \(title)")
                        .font(.largeTitle.bold())

                    Text(introduction)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 4)

                content
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                dismissKeyboard()
            },
            including: .gesture
        )
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("收起键盘") {
                    dismissKeyboard()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("第 \(chapter) 章")
    }

    /// 统一做一个“收起当前第一响应者”的兜底。
    ///
    /// 这样做的好处是：
    /// 1. 不需要每个章节都单独维护一套 `@FocusState`
    /// 2. 点空白和点键盘工具栏都能触发收起
    /// 3. 对 `TextField` / `TextEditor` / `SecureField` 都适用
    ///
    /// 如果你熟悉 UIKit / OC，可以把它理解成：
    /// - 主动给当前第一响应者发送 `resignFirstResponder`
    /// - 只是这里我们通过 `UIApplication` 往 responder 链发 action
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct BookDemoCard<Content: View>: View {
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct BookTipView: View {
    let title: String
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "lightbulb")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(points, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)

                    Text(point)
                        .font(.subheadline)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct MetricBadge: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .foregroundStyle(tint)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 第 1-10 章：基础篇
