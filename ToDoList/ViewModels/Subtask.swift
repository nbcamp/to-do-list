import Foundation

final class Subtask: ViewModel {
    let id: String
    @Publishable var name: String
    @Publishable var completed: Bool
    unowned var group: TaskGroup

    init(
        id: String = UUID().uuidString,
        name: String = "",
        completed: Bool = false,
        of group: TaskGroup
    ) {
        self.id = id
        self.name = name
        self.completed = completed
        self.group = group
    }
}

extension Subtask {
    func model() -> SubtaskModel { .init(from: self) }
}
