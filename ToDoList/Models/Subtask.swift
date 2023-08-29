import Foundation

final class Subtask: DataModel {
    private(set) lazy var observer = Observer(target: self)

    let id: String
    @Observable var name: String
    @Observable var completed: Bool

    unowned let group: TaskGroup

    init(name: String = "", of group: TaskGroup) {
        self.id = UUID().uuidString
        self.name = name
        self.completed = false
        self.group = group
    }
}
