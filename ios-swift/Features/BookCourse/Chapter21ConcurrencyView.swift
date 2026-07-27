import SwiftUI
import CoreData
import UIKit

struct Chapter21ConcurrencyView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 21,
            title: "并发与异步",
            introduction: "Swift 并发这一章的重点，是让耗时任务别堵 UI，同时学会正确取消不再需要的任务。"
        ) {
            BookDemoCard(
                title: "1. async / await 入门",
                summary: "对应教材的核心概念解析。先感受“像同步代码一样写异步流程”的可读性。"
            ) {
                AsyncAwaitConceptDemo()
            }

            BookDemoCard(
                title: "2. 可取消的异步任务",
                summary: "开启一个模拟下载任务，中途可以取消，观察状态和日志变化。"
            ) {
                ConcurrencyTaskDemo()
            }

            BookDemoCard(
                title: "3. Task / .task 对比",
                summary: "教材里这几个词经常一起出现。你可以先这样记：创建任务、绑定视图生命周期、回主线程更新 UI。"
            ) {
                TaskVsDotTaskDemo()
            }

            BookDemoCard(
                title: "4. 综合示例：异步图片加载",
                summary: "对应教材最后的综合示例。这里用 `AsyncImage` 做一个最直观的异步资源加载页。"
            ) {
                AsyncImageLearningDemo()
            }

            BookTipView(
                title: "并发章节注意事项",
                points: [
                    "耗时任务不要阻塞主线程，UI 更新再回到主线程。",
                    "视图销毁后仍在跑的任务，要考虑取消。",
                    "异步代码最怕状态覆盖，尤其是多次点击触发多个请求时。"
                ]
            )
        }
    }
}

private struct AsyncAwaitConceptDemo: View {
    @State private var result = "点击按钮开始等待异步结果"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button("模拟 await 流程") {
                Task {
                    result = "第 1 步：发起任务"
                    try? await Task.sleep(for: .milliseconds(500))
                    result = "第 2 步：等待返回"
                    try? await Task.sleep(for: .milliseconds(500))
                    result = "第 3 步：拿到结果并更新 UI"
                }
            }
            .buttonStyle(.borderedProminent)

            Text(result)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ConcurrencyTaskDemo: View {
    @State private var progress: Double = 0
    @State private var status = "尚未开始"
    @State private var runningTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: progress)

            Text(status)
                .font(.subheadline)

            HStack {
                Button("开始任务") {
                    startTask()
                }
                .buttonStyle(.borderedProminent)

                Button("取消任务") {
                    runningTask?.cancel()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func startTask() {
        runningTask?.cancel()
        progress = 0
        status = "任务执行中..."

        runningTask = Task {
            do {
                for step in 1...10 {
                    try Task.checkCancellation()
                    try await Task.sleep(for: .milliseconds(250))
                    await MainActor.run {
                        progress = Double(step) / 10
                        status = "执行到第 \(step) 步"
                    }
                }
                await MainActor.run {
                    status = "任务完成"
                }
            } catch is CancellationError {
                await MainActor.run {
                    status = "任务已取消"
                }
            } catch {
                await MainActor.run {
                    status = "任务失败：\(error.localizedDescription)"
                }
            }
        }
    }
}

private struct TaskVsDotTaskDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "手动启动", value: "Task {}", tint: .red)
            MetricBadge(title: "随视图", value: ".task", tint: .blue)
            MetricBadge(title: "更新 UI", value: "MainActor", tint: .green)
        }
    }
}

private struct AsyncImageLearningDemo: View {
    private let imageURL = URL(string: "https://picsum.photos/600/320")!

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView("图片加载中...")
                    .frame(maxWidth: .infinity, minHeight: 180)
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            case .failure:
                ContentUnavailableView("加载失败", systemImage: "wifi.exclamationmark")
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - 第 22 章：自定义布局
