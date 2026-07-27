import SwiftUI
import CoreData
import UIKit

struct Chapter20CoreDataView: View {
    var body: some View {
        BookChapterScaffold(
            chapter: 20,
            title: "Core Data 集成",
            introduction: "为了不改你现有工程结构，这里我做了一个“内存版 Core Data 沙盒”。它不落磁盘，但完整演示了建模、插入、查询、更新和删除流程。"
        ) {
            BookDemoCard(
                title: "1. @FetchRequest 位置感",
                summary: "对应教材第一部分。当前页没有直接用 `@FetchRequest` 属性包装器，而是先帮你建立“查询驱动 UI”的心智模型。"
            ) {
                FetchRequestConceptDemo()
            }

            BookDemoCard(
                title: "2. 动态过滤（Filtering）",
                summary: "对应教材里的动态谓词。这里我先用内存沙盒做一个“只看已完成 / 未完成”的过滤实验。"
            ) {
                CoreDataFilteringDemo()
            }

            BookDemoCard(
                title: "3. ManagedObjectContext 的使用",
                summary: "对应教材里的 Context 部分。你要重点理解：插入、修改、删除最后都得落到 Context 上。"
            ) {
                CoreDataContextConceptDemo()
            }

            BookDemoCard(
                title: "4. Core Data 内存沙盒",
                summary: "使用程序化模型创建一个任务实体，你可以增删改查，但退出 App 后不会保留。这样非常适合先学清 Core Data 基本链路。"
            ) {
                CoreDataSandboxDemo()
            }

            BookDemoCard(
                title: "5. 双向绑定与删除数据",
                summary: "对应教材里的 UI 更新章节。这里把切换完成状态和删除，直接当成最直观的双向更新示例。"
            ) {
                CoreDataBindingAndDeleteDemo()
            }

            BookDemoCard(
                title: "6. Core Data 链路图",
                summary: "教材里这一章的关键不是 API 名字多，而是链路要顺：Model -> Context -> Fetch / Save -> UI 更新。"
            ) {
                HStack {
                    MetricBadge(title: "模型", value: "Entity", tint: .purple)
                    MetricBadge(title: "上下文", value: "Context", tint: .blue)
                    MetricBadge(title: "查询", value: "Fetch", tint: .green)
                    MetricBadge(title: "持久化", value: "Save", tint: .orange)
                }
            }

            BookTipView(
                title: "Core Data 注意事项",
                points: [
                    "先理解上下文和实体关系，再去记具体 API。",
                    "任何修改如果不 `save()`，都只是内存里的暂存状态。",
                    "当数据结构复杂到需要查询、过滤、关联时，Core Data 才真正开始体现价值。"
                ]
            )
        }
    }
}

private struct FetchRequestConceptDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                MetricBadge(title: "输入", value: "Fetch 条件", tint: .blue)
                MetricBadge(title: "输出", value: "对象数组", tint: .green)
                MetricBadge(title: "结果", value: "驱动列表 UI", tint: .orange)
            }

            Text("你可以把 `@FetchRequest` 理解成：把数据库查询结果直接绑定到 SwiftUI 视图上。数据一变，界面跟着刷新。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct CoreDataFilteringDemo: View {
    @State private var filter: CoreDataFilter = .all

    private let samples: [CoreDataFilterSample] = [
        .init(identifier: "A001", title: "读懂 @FetchRequest", isDone: false),
        .init(identifier: "A002", title: "练习 Context", isDone: true),
        .init(identifier: "A003", title: "做删除实验", isDone: false)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("过滤", selection: $filter) {
                ForEach(CoreDataFilter.allCases, id: \.self) { item in
                    Text(item.title).tag(item)
                }
            }
            .pickerStyle(.segmented)

            ForEach(filteredSamples) { task in
                HStack {
                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isDone ? .green : .secondary)
                    Text(task.title)
                    Spacer()
                    Text(task.identifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var filteredSamples: [CoreDataFilterSample] {
        switch filter {
        case .all: return samples
        case .done: return samples.filter(\.isDone)
        case .todo: return samples.filter { !$0.isDone }
        }
    }
}

private struct CoreDataFilterSample: Identifiable {
    let id = UUID()
    let identifier: String
    let title: String
    let isDone: Bool
}

private enum CoreDataFilter: CaseIterable {
    case all
    case done
    case todo

    var title: String {
        switch self {
        case .all: return "全部"
        case .done: return "已完成"
        case .todo: return "未完成"
        }
    }
}

private struct CoreDataContextConceptDemo: View {
    var body: some View {
        HStack {
            MetricBadge(title: "插入", value: "insert", tint: .blue)
            MetricBadge(title: "更新", value: "edit", tint: .orange)
            MetricBadge(title: "删除", value: "delete", tint: .red)
            MetricBadge(title: "落盘", value: "save()", tint: .green)
        }
    }
}

private struct CoreDataBindingAndDeleteDemo: View {
    @State private var items: [(String, Bool)] = [
        ("第 20 章：练习双向绑定", false),
        ("第 20 章：练习删除", true)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack {
                    Button {
                        items[index].1.toggle()
                    } label: {
                        Image(systemName: item.1 ? "checkmark.square.fill" : "square")
                    }
                    .buttonStyle(.plain)

                    Text(item.0)
                        .strikethrough(item.1)

                    Spacer()

                    Button("删除") {
                        items.remove(at: index)
                    }
                    .foregroundStyle(.red)
                    .font(.footnote)
                }
            }
        }
    }
}

private struct CoreDataSandboxDemo: View {
    @StateObject private var sandbox = Chapter20CoreDataSandbox()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("输入任务名", text: $sandbox.inputTitle)
                    .textFieldStyle(.roundedBorder)

                Button("新增") {
                    sandbox.addTask()
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(sandbox.tasks) { task in
                HStack {
                    Button {
                        sandbox.toggleDone(id: task.id)
                    } label: {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(task.isDone ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .strikethrough(task.isDone)
                        Text(task.identifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button("删除", role: .destructive) {
                        sandbox.deleteTask(id: task.id)
                    }
                    .font(.footnote)
                }
                Divider()
            }
        }
    }
}

private struct Chapter20ManagedTask: Identifiable {
    let id: NSManagedObjectID
    let identifier: String
    let title: String
    let isDone: Bool
}

@MainActor
private final class Chapter20CoreDataSandbox: ObservableObject {
    @Published var tasks: [Chapter20ManagedTask] = []
    @Published var inputTitle = ""

    private let container: NSPersistentContainer

    init() {
        container = Chapter20CoreDataSandbox.makeContainer()
        seedIfNeeded()
        fetchTasks()
    }

    func addTask() {
        let trimmed = inputTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return }

        let object = NSEntityDescription.insertNewObject(forEntityName: "LearningTask", into: container.viewContext)
        object.setValue(UUID().uuidString.prefix(6).description, forKey: "identifier")
        object.setValue(trimmed, forKey: "title")
        object.setValue(false, forKey: "isDone")
        save()
        inputTitle = ""
    }

    func toggleDone(id: NSManagedObjectID) {
        guard let object = try? container.viewContext.existingObject(with: id) else { return }
        let current = object.value(forKey: "isDone") as? Bool ?? false
        object.setValue(!current, forKey: "isDone")
        save()
    }

    func deleteTask(id: NSManagedObjectID) {
        guard let object = try? container.viewContext.existingObject(with: id) else { return }
        container.viewContext.delete(object)
        save()
    }

    private func save() {
        do {
            try container.viewContext.save()
            fetchTasks()
        } catch {
            print("Chapter20CoreDataSandbox save error: \(error)")
        }
    }

    private func fetchTasks() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LearningTask")
        let results = (try? container.viewContext.fetch(request)) ?? []
        tasks = results.map {
            Chapter20ManagedTask(
                id: $0.objectID,
                identifier: $0.value(forKey: "identifier") as? String ?? "unknown",
                title: $0.value(forKey: "title") as? String ?? "未命名任务",
                isDone: $0.value(forKey: "isDone") as? Bool ?? false
            )
        }
    }

    private func seedIfNeeded() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "LearningTask")
        let count = (try? container.viewContext.count(for: request)) ?? 0
        guard count == 0 else { return }

        ["理解 Context", "练习 FetchRequest", "体验增删改查"].forEach { title in
            let object = NSEntityDescription.insertNewObject(forEntityName: "LearningTask", into: container.viewContext)
            object.setValue(UUID().uuidString.prefix(6).description, forKey: "identifier")
            object.setValue(title, forKey: "title")
            object.setValue(false, forKey: "isDone")
        }
        save()
    }

    private static func makeContainer() -> NSPersistentContainer {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "LearningTask"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let identifier = NSAttributeDescription()
        identifier.name = "identifier"
        identifier.attributeType = .stringAttributeType
        identifier.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        let isDone = NSAttributeDescription()
        isDone.name = "isDone"
        isDone.attributeType = .booleanAttributeType
        isDone.isOptional = false
        isDone.defaultValue = false

        entity.properties = [identifier, title, isDone]
        model.entities = [entity]

        let container = NSPersistentContainer(name: "Chapter20Model", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data in-memory store failed: \(error)")
            }
        }

        return container
    }
}

// MARK: - 第 21 章：并发与异步
