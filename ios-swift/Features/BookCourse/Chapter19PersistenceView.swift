import SwiftUI
import CoreData
import UIKit

struct Chapter19PersistenceView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 19,
            title: "本地数据持久化",
            introduction: "不是所有数据都要上数据库。偏设置类的小数据，`@AppStorage` 和 `UserDefaults` 已经很够用。关键是先分清“临时状态”和“应该跨启动保留的状态”。"
        ) {
            BookDemoCard(
                title: "1. @AppStorage：轻量级状态持久化",
                summary: "对应教材第一部分。适合主题色、昵称、开关这类轻量配置。"
            ) {
                AppStorageLearningDemo()
            }

            BookDemoCard(
                title: "2. UserDefaults：标准偏好存储",
                summary: "对应教材第二部分。这里我把核心方法和 SwiftUI 集成示例合在一个可运行卡片里。"
            ) {
                UserDefaultsLearningDemo()
            }

            BookDemoCard(
                title: "3. Core Data：对象图管理位置感",
                summary: "这一章不会直接深挖 Core Data 细节，但你要先知道它和前两种方案不是一个重量级。"
            ) {
                PersistenceArchitectureComparisonDemo()
            }

            BookDemoCard(
                title: "4. 方案对比与选择指南",
                summary: "对应教材最后的选择策略。实战里重点不是都用，而是选对层级。"
            ) {
                HStack {
                    MetricBadge(title: "轻量配置", value: "@AppStorage", tint: .brown)
                    MetricBadge(title: "简单键值", value: "UserDefaults", tint: .orange)
                    MetricBadge(title: "结构化数据", value: "Core Data", tint: .purple)
                }
            }

            BookTipView(
                title: "持久化注意事项",
                points: [
                    "轻量设置不要上重型数据库，避免过度设计。",
                    "临时输入和持久保存要分开，别每次敲一个字就把整个业务状态写盘。",
                    "一旦涉及列表、关系、查询条件，优先考虑结构化存储。"
                ]
            )
        }
    }
}

private struct AppStorageLearningDemo: View {
    @AppStorage("chapter19.nickname") private var nickname: String = "Swift 学徒"
    @AppStorage("chapter19.receiveTips") private var receiveTips = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("昵称", text: $nickname)
                .textFieldStyle(.roundedBorder)

            Toggle("接收学习提醒", isOn: $receiveTips)

            Text("当前值会自动跨启动保存：\(nickname) / \(receiveTips ? "开启提醒" : "关闭提醒")")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct UserDefaultsLearningDemo: View {
    @State private var draft = ""
    @State private var saveMessage = "尚未保存"

    private let draftKey = "chapter19.draft"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $draft)
                .frame(height: 110)
                .padding(8)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))

            HStack {
                Button("保存草稿") {
                    UserDefaults.standard.set(draft, forKey: draftKey)
                    saveMessage = "已保存到 UserDefaults"
                }
                .buttonStyle(.borderedProminent)

                Button("读取草稿") {
                    draft = UserDefaults.standard.string(forKey: draftKey) ?? ""
                    saveMessage = "已从 UserDefaults 读取"
                }
                .buttonStyle(.bordered)
            }

            Text(saveMessage)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("核心方法：`set(_:forKey:)` / `string(forKey:)`。如果你是 UIKit 背景，可以把它理解成最基础的本地键值仓库。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            draft = UserDefaults.standard.string(forKey: draftKey) ?? "这里写你的学习草稿，下次启动还能看到。"
        }
    }
}

private struct PersistenceArchitectureComparisonDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "配置开关", value: "@AppStorage", tint: .brown)
                MetricBadge(title: "简单草稿", value: "UserDefaults", tint: .orange)
                MetricBadge(title: "列表关系", value: "Core Data", tint: .purple)
            }

            Text("判断标准很简单：数据越结构化、查询越复杂、关联越多，就越应该往 Core Data 这样的方案走。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 第 20 章：Core Data
