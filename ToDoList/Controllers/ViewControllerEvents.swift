import Foundation

struct PushToNewTaskScreen: EventProtocol {
    let payload: Void = ()
}

struct PushToEditTaskGroupScreen: EventProtocol {
    let payload: Void = ()
}

struct PushToDetailTaskScreen: EventProtocol {
    struct Payload {
        let group: TaskGroup
    }

    let payload: Payload
}

struct PresentColorPicker: EventProtocol {
    struct Payload {
        let group: TaskGroup
    }

    let payload: Payload
}

struct FetchRandomImage: EventProtocol {
    struct Payload {
        let group: TaskGroup
    }

    let payload: Payload
}

struct CreateNewTask: EventProtocol {
    struct Payload {
        let group: TaskGroup
    }

    let payload: Payload
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
