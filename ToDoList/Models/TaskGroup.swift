import UIKit

final class TaskGroup: DataModel {
    private(set) lazy var observer = Observer(target: self)

    let id: String
    @Observable var name: String
    @Observable var image: UIImage
    @Observable var color: UIColor
    @Observable var tasks: [Subtask]

    var progress: Double { Double(tasks.filter { $0.completed }.count) / Double(tasks.count) }

    init(
        name: String = "",
        image: UIImage = .init(systemName: "hand.tap")!,
        color: UIColor = .random(in: .dark),
        tasks: [Subtask] = []
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.image = image
        self.color = color
        self.tasks = tasks
    }
}
