//
//  Book.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

// 遵循 Identifiable 协议，便于 ForEach 使用
struct Book: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var isFavorited: Bool = false
}

// 准备示例数据
let sampleBooks = [
    Book(title: "SwiftUI 编程入门", author: "张三", isFavorited: true),
    Book(title: "深入浅出 iOS 设计", author: "李四"),
    Book(title: "算法之美", author: "王五"),
    Book(title: "移动应用测试", author: "赵六")
]
