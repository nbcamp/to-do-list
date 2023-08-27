import Foundation

final class TaskService {
    static let shared: TaskService = .init()
    private init() {}

    private(set) var tasks: [Task] = []

    func add(task: Task) {
        tasks.append(task)
    }
}
