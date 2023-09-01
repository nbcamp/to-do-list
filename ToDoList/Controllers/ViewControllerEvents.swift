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
        let completion: () -> Void
    }

    let payload: Payload
}

struct CreateNewTaskGroup: EventProtocol {
    struct Payload {
        let group: TaskGroup
        let completion: () -> Void
    }

    let payload: Payload
}

struct UpdateTaskGroup: EventProtocol {
    struct Payload {
        let group: TaskGroup
        let completion: () -> Void
    }

    let payload: Payload
}

struct DeleteTaskGroup: EventProtocol {
    struct Payload {
        let group: TaskGroup
        let completion: (Int?) -> Void
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

struct CompleteTask: EventProtocol {
    struct Payload {
        let task: Subtask
    }
    
    let payload: Payload
}

struct SwapTwoTasks: EventProtocol {
    struct Payload {
        let aTaskIndex: Int
        let bTaskIndex: Int
        let group: TaskGroup
    }

    let payload: Payload
}
