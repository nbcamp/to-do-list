import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private(set) var tasks: [TaskGroup] = []

    func add(task: TaskGroup) {
        tasks.append(task)
    }

    func add(subtask: Subtask) {
        subtask.group.tasks.append(subtask)
    }

    func remove(subtask: Subtask, of task: TaskGroup) {
        task.tasks.remove(element: subtask)
    }
}
