//
//  BookDetailView.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//
import SwiftUI

struct BookDetailView: View {
    let book: Book // 通过 NavigationLink 传递过来的数据

    var body: some View {
        VStack(spacing: 25) {
            Circle()
                .fill(Color("#FF9800").opacity(0.2))
                .frame(width: 150, height: 150)
                .overlay(
                    Text(String(book.title.prefix(1)))
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.orange)
                )

            Text(book.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("作者: ") + Text(book.author).fontWeight(.medium)
                .font(.title2)
                .foregroundColor(.blue)

            HStack {
                Label(book.isFavorited ? "已收藏" : "未收藏",
                       systemImage: book.isFavorited ? "star.fill" : "star")
                    .foregroundColor(book.isFavorited ? .yellow : .gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .navigationTitle("书籍详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
