import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private lazy var key = String(describing: Self.self)
    var storage: Storage? {
        didSet { load() }
    }

    private(set) var groups: [TaskGroup] = []

    func add(group: TaskGroup) {
        defer { save() }
        groups.append(group)
    }

    func add(task: Subtask) {
        defer { task.group.sync(); save() }
        task.group.tasks.append(task)
    }

    func remove(task: Subtask) -> Int? {
        defer { task.group.sync(); save() }
        return task.group.tasks.remove(element: task)
    }

    func complete(task: Subtask) {
        defer { task.group.sync(); save() }
        task.completed.toggle()
    }

    private func save() {
        storage?.save(groups.map { $0.toModel() }, forKey: key)
    }

    private func load() {
        guard let models: [TaskGroupModel] = storage?.load(forKey: key) else { return }
        groups = models.compactMap { $0.toViewModel() }
    }
}
