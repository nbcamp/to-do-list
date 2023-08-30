import Foundation

struct PushToNewTaskScreen: EventProtocol {
    let payload: Void = ()
}

struct PresentColorPicker: EventProtocol {
    let payload: Void = ()
}

struct FetchRandomImage: EventProtocol {
    let payload: Void = ()
}

struct CreateNewTask: EventProtocol {
    let payload: Void = ()
}

struct EditTaskName: EventProtocol {
    struct Payload {
        let task: Subtask
    }

    let payload: Payload
}

struct DeleteTask: EventProtocol {
    struct Payload {
        let task: Subtask
    }

    let payload: Payload
}
