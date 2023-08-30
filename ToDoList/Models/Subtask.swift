import Foundation

final class Subtask: DataModel {
    private(set) lazy var subscriber = Subscriber(target: self)

    let id: String
    @Publishable var name: String
    @Publishable var completed: Bool

    unowned let group: TaskGroup

    init(name: String = "", of group: TaskGroup) {
        self.id = UUID().uuidString
        self.name = name
        self.completed = false
        self.group = group
    }
}
