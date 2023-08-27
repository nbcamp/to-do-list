import Foundation

final class Subtask: Identifiable {
    private static var _id = 1

    let id: Int
    let name: String
    var completed: Bool

    init(name: String) {
        self.id = Self._id
        self.name = name
        self.completed = Bool.random()
        Self._id += 1
    }
}
