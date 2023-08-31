import UIKit

final class TaskGroup: ViewModel {
    private(set) lazy var subscriber = Subscriber(source: self)

    let id: String
    @Publishable var name: String
    @Publishable var image: Base64?
    @Publishable var color: RGBA?
    @Publishable var tasks: [Subtask]

    var progress: Double { Double(tasks.filter { $0.completed }.count) / Double(tasks.count) }

    init(
        id: String = UUID().uuidString,
        name: String = "",
        image: Base64? = "",
        color: RGBA? = .init(red: 0, green: 0, blue: 0, alpha: 0),
        tasks: [Subtask] = []
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.color = color
        self.tasks = tasks
    }
}

extension TaskGroup {
    func toModel() -> TaskGroupModel { .init(from: self) }
    
    func overwrite(_ other: TaskGroup) {
        self.name = other.name
        self.image = other.image
        self.color = other.color
        self.tasks = other.tasks
    }
}

extension TaskGroup {
    var uiImage: UIImage? {
        get { image != nil ? .init(base64: image!) : nil }
        set { image = newValue?.base64 }
    }

    var uiColor: UIColor? {
        get { color != nil ? .init(rgba: color!) : nil }
        set { color = newValue?.rgba }
    }
}
