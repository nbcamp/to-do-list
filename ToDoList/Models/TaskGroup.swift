import UIKit

final class TaskGroup: DataModel {
    private static var _id = 1

    let id: Int
    var name: String

    @ObservableProperty
    var color: UIColor = .clear

    var children: [Subtask]
    var progress: Double { Double(children.filter { $0.completed }.count) / Double(children.count) }

    init(name: String, color: UIColor, subtasks: [Subtask] = []) {
        self.id = Self._id
        self.name = name
        self.color = color
        self.children = subtasks
        Self._id += 1
    }
}
