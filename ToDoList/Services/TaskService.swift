import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private(set) var tasks: [TaskGroup] = [
        .init(name: "Reading", color: .random(in: .dark), subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Interview", color: .random(in: .dark), subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Research", color: .random(in: .dark), subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Report", color: .random(in: .light), subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Writing", color: .random(in: .light), subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
    ]

    func add(task: TaskGroup) {
        tasks.append(task)
    }

    func add(subtask: Subtask, to task: TaskGroup) {
        task.children.append(subtask)
    }

    func remove(subtask: Subtask, of task: TaskGroup) {
        task.children.remove(element: subtask)
    }
}
