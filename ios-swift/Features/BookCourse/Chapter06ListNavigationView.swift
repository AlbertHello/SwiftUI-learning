import SwiftUI
import CoreData
import UIKit

struct Chapter6ListNavigationView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 6,
            title: "列表与导航",
            introduction: "你前面已经有一个完整的 List demo 了，这一章我把它纳入课程路径里，同时再放一个轻量版导航列表，方便你把教材和现有工程对应起来。"
        ) {
            BookDemoCard(
                title: "1. 核心组件总览",
                summary: "对应教材里的 `List / ForEach / NavigationLink` 组件详解。"
            ) {
                HStack {
                    MetricBadge(title: "列表容器", value: "List", tint: .blue)
                    MetricBadge(title: "批量渲染", value: "ForEach", tint: .green)
                    MetricBadge(title: "导航跳转", value: "NavigationLink", tint: .orange)
                }
            }

            BookDemoCard(
                title: "2. 轻量图书列表示例",
                summary: "演示 `List + ForEach + NavigationLink` 的最小闭环。"
            ) {
                Chapter6MiniListDemo()
            }

            BookDemoCard(
                title: "3. 完整列表学习页",
                summary: "如果你想继续看更完整的列表交互，可以进入我们前面做过的 List Demo。"
            ) {
                NavigationLink("打开完整 List Demo") {
                    ListViewDemo()
                }
                .buttonStyle(.borderedProminent)
            }

            BookDemoCard(
                title: "4. 动手挑战：添加新书 + 收藏切换",
                summary: "这是教材第 6 章最后的动手挑战：新增图书，并切换收藏状态。"
            ) {
                Chapter6BookChallengeDemo()
            }

            BookTipView(
                title: "第 6 章最佳实践",
                points: [
                    "长列表和导航是业务开发高频场景，这一章值得多练。",
                    "模型最好先具备稳定标识，后面删除、收藏、跳转都更顺。",
                    "列表页负责展示摘要，详情页再承载更完整信息。"
                ]
            )
        }
    }
}

private struct Chapter6MiniListDemo: View {
    private let books = [
        "SwiftUI 入门",
        "iOS 布局练习",
        "动画设计思路"
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(books, id: \.self) { book in
                NavigationLink {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(book)
                            .font(.largeTitle.bold())
                        Text("这里是最小化详情页，帮助你理解点击一行后进入下一个页面的导航流程。")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("图书详情")
                } label: {
                    HStack {
                        Image(systemName: "book.closed")
                            .foregroundStyle(.pink)
                        Text(book)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                }
                if book != books.last {
                    Divider()
                }
            }
        }
    }
}

private struct Chapter6BookChallengeItem: Identifiable {
    let id = UUID()
    let title: String
    var isFavorite: Bool
}

private struct Chapter6BookChallengeDemo: View {
    @State private var newBookTitle = ""
    @State private var books: [Chapter6BookChallengeItem] = [
        Chapter6BookChallengeItem(title: "SwiftUI 从入门到进阶", isFavorite: true),
        Chapter6BookChallengeItem(title: "布局与动画实战", isFavorite: false),
        Chapter6BookChallengeItem(title: "状态管理手册", isFavorite: false)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("输入新书名称", text: $newBookTitle)
                    .textFieldStyle(.roundedBorder)

                Button("添加") {
                    addBook()
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(books) { book in
                HStack {
                    Image(systemName: "book.closed")
                        .foregroundStyle(.pink)

                    Text(book.title)

                    Spacer()

                    Button {
                        toggleFavorite(id: book.id)
                    } label: {
                        Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(book.isFavorite ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                }
                Divider()
            }
        }
    }

    private func addBook() {
        let trimmed = newBookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }
        books.insert(Chapter6BookChallengeItem(title: trimmed, isFavorite: false), at: 0)
        newBookTitle = ""
    }

    private func toggleFavorite(id: UUID) {
        guard let index = books.firstIndex(where: { $0.id == id }) else { return }
        books[index].isFavorite.toggle()
    }
}
