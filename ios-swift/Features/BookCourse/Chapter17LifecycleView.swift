import SwiftUI
import CoreData
import UIKit

struct Chapter17LifecycleView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 17,
            title: "生命周期",
            introduction: "SwiftUI 没有和 UIKit 一模一样的一套 `viewDidLoad / viewWillAppear`。但你仍然可以用 `onAppear / onDisappear / scenePhase` 观察页面和应用的生命过程。"
        ) {
            BookDemoCard(
                title: "1. onAppear / onDisappear 日志页",
                summary: "切换子视图、退到后台、回到前台时，观察日志变化。这个 demo 很适合你真机调试时继续扩展。"
            ) {
                LifecycleLoggingDemo()
            }

            BookDemoCard(
                title: "2. App 协议与应用生命周期",
                summary: "对应教材里的 `App` 协议部分：应用级事件更偏入口与场景维度，而不是某个单独页面。"
            ) {
                AppLifecycleConceptDemo()
            }

            BookDemoCard(
                title: "3. UIApplicationDelegateAdaptor 位置感",
                summary: "对应教材里的 UIKit 兼容方案。这里先让你建立桥接意识：老能力还在，但入口放到 SwiftUI App 体系里。"
            ) {
                UIApplicationAdaptorConceptDemo()
            }

            BookDemoCard(
                title: "4. 示例：安全的网络请求与清理",
                summary: "对应教材里的清理示例：页面离开后，任务应该被取消，而不是继续偷偷跑。"
            ) {
                SafeRequestCleanupDemo()
            }

            BookTipView(
                title: "生命周期注意事项",
                points: [
                    "不要默认 `onAppear` 只调用一次，列表复用、条件渲染都可能让它多次触发。",
                    "长任务和资源释放要放在合适时机，不要只靠某一个生命周期点。",
                    "真机调试时，日志是理解生命周期最直接的办法。"
                ]
            )
        }
    }
}

private struct AppLifecycleConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "页面级", value: "onAppear", tint: .teal)
            MetricBadge(title: "应用级", value: "App / Scene", tint: .orange)
            MetricBadge(title: "全局状态", value: "scenePhase", tint: .indigo)
        }
    }
}

private struct UIApplicationAdaptorConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SwiftUI App 仍然可以桥接传统 AppDelegate 能力。")
                .font(.headline)
            Text("常见场景：推送注册、第三方 SDK 初始化、系统回调转发。也就是说，SwiftUI 不是把 UIKit 生命周期彻底抹掉，而是把它包进新的入口结构里。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct SafeRequestCleanupDemo: View {
    @State private var showLoader = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("展示请求页面", isOn: $showLoader.animation())

            if showLoader {
                NetworkCleanupChildView()
            }
        }
    }
}

private struct NetworkCleanupChildView: View {
    @State private var status = "任务未开始"
    @State private var runningTask: Task<Void, Never>?

    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.orange.opacity(0.14))
            .frame(height: 120)
            .overlay {
                VStack(spacing: 8) {
                    Text("模拟网络请求中")
                        .font(.headline)
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .onAppear {
                runningTask = Task {
                    for step in 1...5 {
                        try? await Task.sleep(for: .milliseconds(400))
                        guard Task.isCancelled == false else { return }
                        await MainActor.run {
                            status = "已执行到第 \(step) 步"
                        }
                    }
                    await MainActor.run {
                        status = "请求完成"
                    }
                }
            }
            .onDisappear {
                runningTask?.cancel()
                status = "页面消失，请求已取消"
            }
    }
}

private struct LifecycleLoggingDemo: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showChild = false
    @State private var logs: [String] = ["页面初始化完成"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("展示子视图", isOn: $showChild.animation())

            if showChild {
                LifecycleChildDemo {
                    appendLog("子视图 onAppear")
                } onDisappearAction: {
                    appendLog("子视图 onDisappear")
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                        Text(log)
                            .font(.footnote.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 150)
            .padding(10)
            .background(Color.black.opacity(0.88), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.green)
        }
        .onAppear {
            appendLog("父视图 onAppear")
        }
        .onDisappear {
            appendLog("父视图 onDisappear")
        }
        .onChange(of: scenePhase) { _, newValue in
            appendLog("scenePhase -> \(String(describing: newValue))")
        }
    }

    private func appendLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let line = "[\(formatter.string(from: Date()))] \(message)"
        print("LifecycleLoggingDemo: \(line)")
        logs.insert(line, at: 0)
    }
}

private struct LifecycleChildDemo: View {
    let onAppearAction: () -> Void
    let onDisappearAction: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.teal.opacity(0.18))
            .frame(height: 80)
            .overlay {
                Text("子视图已经挂载到层级中")
                    .font(.headline)
            }
            .onAppear(perform: onAppearAction)
            .onDisappear(perform: onDisappearAction)
    }
}

// MARK: - 第 18 章：网络
