import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private(set) var tasks: [Task] = [
        .init(name: "Reading", color: .systemPink, subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Interview", color: .systemTeal, subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Research", color: .systemBrown, subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Report", color: .systemRed, subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
        .init(name: "Writing", color: .systemBlue, subtasks: (1...Int.random(in: 1...100)).map { .init(name: "Task \($0)") }),
    ]

    func add(task: Task) {
        tasks.append(task)
    }

    func add(subtask: Subtask, to task: Task) {
        task.children.append(subtask)
    }

    func remove(subtask: Subtask, of task: Task) {
        task.children.remove(element: subtask)
    }
}
