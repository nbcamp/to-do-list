import Foundation

final class Task: Identifiable {
    private static var _id = 1

    let id: Int
    let name: String
    let children: [Subtask]
    var completes: Double { Double(children.filter { $0.completed }.count) / Double(children.count) }

    init(name: String) {
        self.id = Self._id
        self.name = name
        self.children = []
        Self._id += 1
    }
}
