import Foundation

struct TaskGroupModel: Codable {
    let id: String
    let name: String
    let image: Base64?
    let color: RGBA?
    let tasks: [SubtaskModel]
    let progress: Double

    init(from group: TaskGroup) {
        id = group.id
        name = group.name
        image = group.image
        color = group.color
        tasks = group.tasks.map(SubtaskModel.init)
        progress = group.progress
    }
}

extension TaskGroupModel {
    func toViewModel() -> TaskGroup? {
        let group = TaskGroup(
            id: id,
            name: name,
            image: image,
            color: color,
            progress: progress
        )
        group.tasks = tasks.compactMap { $0.toViewModel(group: group) }
        return group
    }
}
