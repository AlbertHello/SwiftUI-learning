import SwiftUI

/// Demo 首页。
///
/// 目的：
/// - 不再去 `ios_swiftApp.swift` 里反复注释/切换根页面
/// - 用一个可滚动的列表统一收纳所有 demo
/// - 点击 cell 后再进入对应的子页面
///
/// 如果你是 UIKit / Flutter 背景，可以把它理解成：
/// - UIKit: 一个“功能目录页”，cell 点击后 push 到不同 VC
/// - Flutter: 一个 `ListView` 首页，点 item 后 `Navigator.push(...)`
struct DemoHomeView: View {
    /// 首页现在直接按教材章节顺序展示 1-30 章。
    ///
    /// 这样做的好处是：
    /// - 学习路径和教材目录一一对应
    /// - 不再需要先进入“总入口”，再进入某一章
    /// - 你每天看教材看到哪一章，就直接点哪一章
    private var demos: [DemoItem] {
        let chapterItems = SwiftUIBookChapter.allCases.map { chapter in
            DemoItem(
                title: "第 \(chapter.rawValue) 章 · \(chapter.title)",
                subtitle: chapter.subtitle,
                icon: chapter.icon,
                tint: chapter.tint,
                destination: .chapter(chapter)
            )
        }

        return chapterItems + [
            DemoItem(
                title: "第 31 项 · 音视频采集 / 回放",
                subtitle: "摄像头预览、录制、AVPlayer 回放、硬解码播放",
                icon: "camera.viewfinder",
                tint: .blue,
                destination: .capturePlayback
            )
        ]
    }

    var body: some View {
        NavigationStack {
            List(demos) { demo in
                NavigationLink {
                    destinationView(for: demo.destination)
                } label: {
                    DemoRow(item: demo)
                }
            }
            .navigationTitle("SwiftUI 学习目录")
        }
    }

    /// 根据枚举值返回要跳转到的页面。
    ///
    /// 这里用 `@ViewBuilder` 的好处是：
    /// - 不同 case 可以返回不同类型的 View
    /// - 调用方仍然把它当成一个 `some View` 使用
    @ViewBuilder
    private func destinationView(for destination: DemoDestination) -> some View {
        switch destination {
        case let .chapter(chapter):
            chapterDestinationView(for: chapter)
        case .capturePlayback:
            ContentView()
        }
    }

    /// 首页现在直接跳章节，所以这里把章节枚举映射到具体页面。
    @ViewBuilder
    private func chapterDestinationView(for chapter: SwiftUIBookChapter) -> some View {
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

/// 首页里每个 demo 对应的一条数据。
private struct DemoItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: DemoDestination
}

/// 用枚举表达“点这个 cell 要去哪个页面”。
///
/// 这样比直接在数据结构里塞 View 更清晰：
/// - 数据层只描述“目标是谁”
/// - 真正创建页面的逻辑统一放在 `destinationView(for:)`
private enum DemoDestination {
    case chapter(SwiftUIBookChapter)
    case capturePlayback
}

/// 首页列表的一行 UI。
private struct DemoRow: View {
    let item: DemoItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(item.tint.gradient, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

//#Preview {
//    DemoHomeView()
//}
