import UIKit

final class TaskGroup: ViewModel {
    let id: String
    @Publishable var name: String
    @Publishable var image: Base64?
    @Publishable var color: RGBA?
    @Publishable var tasks: [Subtask]
    @Publishable var progress: Double

    init(
        id: String = UUID().uuidString,
        name: String = "",
        image: Base64? = nil,
        color: RGBA? = nil,
        tasks: [Subtask] = [],
        progress: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.color = color
        self.tasks = tasks
        self.progress = progress ?? (tasks.count == 0 ? 0.0 : Double(tasks.filter { $0.completed }.count) / Double(tasks.count))
    }

    func sync() {
        progress = tasks.count == 0 ? 0 : Double(tasks.filter { $0.completed }.count) / Double(tasks.count)
    }
}

extension TaskGroup {
    func toModel() -> TaskGroupModel { .init(from: self) }
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
