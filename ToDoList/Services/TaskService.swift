import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private(set) var groups: [TaskGroup] = []

    func add(group: TaskGroup) {
        groups.append(group)
    }

    func add(task: Subtask) {
        task.group.tasks.append(task)
    }

    func remove(task: Subtask) -> Int? {
        return task.group.tasks.remove(element: task)
    }
}
