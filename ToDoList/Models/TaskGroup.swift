import UIKit

final class TaskGroup: DataModel {
    private(set) lazy var subscriber = Subscriber(target: self)

    let id: String
    @Publishable var name: String
    @Publishable var image: UIImage
    @Publishable var color: UIColor
    @Publishable var tasks: [Subtask]

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
