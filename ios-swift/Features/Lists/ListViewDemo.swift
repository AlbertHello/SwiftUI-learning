//
//  ListViewDemo.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

struct ListViewDemo: View {
    // 状态变量，管理书籍数据
    @State private var books = sampleBooks

    var body: some View {
        // 1. 导航容器
        NavigationView {
            // 2. 列表
            List {
                // 3. 动态生成行
                ForEach(books) { book in
                    // 4. 导航链接：点击单元格跳转到详情页
                    NavigationLink(destination: BookDetailView(book: book)) {
                        // 单元格内容
                        HStack {
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if book.isFavorited {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete { indexSet in // 滑动删除
                    books.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("我的书库") // 设置导航栏标题
            .listStyle(InsetGroupedListStyle()) // 设置列表样式
        }
    }
}
