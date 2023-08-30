import Foundation

struct SubtaskModel: Codable {
    let id: String
    let name: String
    let completed: Bool

    init(from subtask: Subtask) {
        id = subtask.id
        name = subtask.name
        completed = subtask.completed
    }
}

extension SubtaskModel {
    func toViewModel(group: TaskGroup) -> Subtask? {
        Subtask(
            id: id,
            name: name,
            completed: completed,
            of: group
        )
    }
}
