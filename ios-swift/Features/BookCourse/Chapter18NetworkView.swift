import SwiftUI
import CoreData
import UIKit
import Combine

struct Chapter18NetworkView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 18,
            title: "网络请求与数据",
            introduction: "网络章节最重要的不是把接口打通，而是把“加载中、成功、失败、重试”这几种状态建模清楚。"
        ) {
            BookDemoCard(
                title: "1. 技术栈拆解：URLSession / Combine / SwiftUI",
                summary: "对应教材里的核心技术栈总览。先把三者在网络页面里的职责分清，再去写请求代码。"
            ) {
                Chapter18StackOverviewDemo()
            }

            BookDemoCard(
                title: "2. Model / Service / ViewModel / View",
                summary: "对应教材里的架构流程图。一个健康的网络页面，不应该把所有逻辑都堆在 View 里。"
            ) {
                Chapter18ArchitectureFlowDemo()
            }

            BookDemoCard(
                title: "3. URLSession 拉取远程文章",
                summary: "点按钮后请求一个公开 JSON 接口，体验状态驱动 UI 的典型写法。"
            ) {
                NetworkLoadingDemo()
            }

            BookDemoCard(
                title: "4. Combine 操作符速查表",
                summary: "教材里会顺带提 Combine。即使你后面主力用 async/await，这几个概念也值得认识。"
            ) {
                CombineCheatSheetDemo()
            }

            BookDemoCard(
                title: "5. 状态建模清单",
                summary: "网络页不要只关心“成功”，真正可用的页面至少要覆盖：未开始、加载中、成功、失败、重试。"
            ) {
                HStack {
                    MetricBadge(title: "初始", value: "idle", tint: .gray)
                    MetricBadge(title: "加载", value: "loading", tint: .blue)
                    MetricBadge(title: "成功", value: "loaded", tint: .green)
                    MetricBadge(title: "失败", value: "error", tint: .red)
                }
            }

            BookTipView(
                title: "网络章节注意事项",
                points: [
                    "网络层、ViewModel、View 最好分层，不要把请求直接塞满页面 body。",
                    "错误态和重试入口要设计清楚，否则页面只能在成功路径下工作。",
                    "如果请求会被重复触发，要考虑取消、幂等和旧结果覆盖新结果的问题。"
                ]
            )
        }
    }
}

private struct Chapter18StackOverviewDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "请求发起", value: "URLSession", tint: .blue)
            MetricBadge(title: "数据流处理", value: "Combine", tint: .purple)
            MetricBadge(title: "界面展示", value: "SwiftUI", tint: .green)
        }
    }
}

private struct Chapter18ArchitectureFlowDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "Model", value: "解码结构", tint: .teal)
                MetricBadge(title: "Service", value: "请求封装", tint: .blue)
                MetricBadge(title: "ViewModel", value: "状态控制", tint: .orange)
                MetricBadge(title: "View", value: "渲染界面", tint: .green)
            }

            Text("你后面写任何网络页，都尽量按这条链组织。这样调试和替换实现都会轻松很多。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct CombineCheatSheetDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("`map`：把上游数据转成另一种结构", systemImage: "arrow.right")
            Label("`decode`：把 JSON Data 解码成模型", systemImage: "arrow.right")
            Label("`debounce`：搜索场景里降低请求频率", systemImage: "arrow.right")
            Label("`receive(on:)`：把结果切回主线程更新 UI", systemImage: "arrow.right")
        }
        .font(.subheadline)
    }
}

private struct NetworkLoadingDemo: View {
    @StateObject private var viewModel = Chapter18PostListViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("加载文章") {
                    Task {
                        await viewModel.loadPosts()
                    }
                }
                .buttonStyle(.borderedProminent)

                if viewModel.isLoading {
                    ProgressView()
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            ForEach(viewModel.posts) { post in
                VStack(alignment: .leading, spacing: 6) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)

                Divider()
            }
        }
    }
}

private struct Chapter18Post: Decodable, Identifiable {
    let id: Int
    let title: String
    let body: String
}

@MainActor
private final class Chapter18PostListViewModel: ObservableObject {
    @Published var posts: [Chapter18Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=5")!
            let (data, _) = try await URLSession.shared.data(from: url)
            posts = try JSONDecoder().decode([Chapter18Post].self, from: data)
        } catch {
            errorMessage = "请求失败：\(error.localizedDescription)"
        }
    }
}

// MARK: - 第 19 章：本地持久化
