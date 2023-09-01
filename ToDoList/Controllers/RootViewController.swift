import UIKit

final class RootViewController: UINavigationController {
    private let eventBus = EventBus.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        initializeEvents()
    }

    private func setupNavigation() {
        let rootVC = TaskGroupViewController()
        setViewControllers([rootVC], animated: true)
    }

    deinit { eventBus.reset(self) }
}

extension RootViewController {
    private func initializeEvents() {
        eventBus.on(PushToNewTaskScreen.self, by: self) { host, _ in
            let vc = NewTaskViewController(animated: true)
            host.pushViewController(vc, animated: true)
        }

        eventBus.on(PushToEditTaskGroupScreen.self, by: self) { host, _ in
            let vc = EditTaskGroupViewController()
            host.pushViewController(vc, animated: true)
        }

        eventBus.on(PushToDetailTaskScreen.self, by: self) { host, payload in
            let vc = DetailTaskViewController()
            vc.group = payload.group
            host.pushViewController(vc, animated: true)
        }

        eventBus.on(PresentColorPicker.self, by: self) { host, payload in
            let picker = ColorPickerViewController(initial: payload.group.uiColor, title: "Accent Color") { color in
                guard let color else { return }
                payload.group.uiColor = color
            }
            picker.modalPresentationStyle = .popover
            host.present(picker, animated: true)
        }

        eventBus.on(FetchRandomImage.self, by: self) { host, payload in
            host.withRandomAnimal { animal in
                guard let animal else { return payload.completion() }
                DispatchQueue.global().async {
                    guard let url = URL(string: animal.url),
                          let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data)
                    else { return }
                    DispatchQueue.main.async {
                        payload.group.uiImage = image
                        payload.completion()
                    }
                }
            }
        }

        eventBus.on(CreateNewTaskGroup.self, by: self) { _, payload in
            TaskService.shared.add(group: payload.group)
            payload.completion()
        }

        eventBus.on(UpdateTaskGroup.self, by: self) { _, payload in
            payload.completion()
        }

        eventBus.on(DeleteTaskGroup.self, by: self) { host, payload in
            let alertController = UIAlertController(title: "Delete Task Group", message: "Are you sure you want to delete this task group?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                let index = TaskService.shared.remove(group: payload.group)
                payload.completion(index)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            host.present(alertController, animated: true)
        }

        eventBus.on(CreateNewTask.self, by: self) { host, payload in
            let alertController = UIAlertController(title: "Add New Task", message: "What task to you want to add?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            let confirmAction = UIAlertAction(title: "Add", style: .default) { _ in
                guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
                TaskService.shared.add(task: .init(name: text, of: payload.group))
            }
            confirmAction.isEnabled = false
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            alertController.addTextField()
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: alertController.textFields?.first,
                queue: .main
            ) { _ in
                guard let text = alertController.textFields?.first?.text else { return }
                confirmAction.isEnabled = !text.isEmpty
            }
            host.present(alertController, animated: true)
        }

        eventBus.on(EditTaskName.self, by: self) { host, payload in
            let alertController = UIAlertController(title: "Edit Task Name", message: "Fill in the name of the task you want to edit.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
                payload.task.name = text
            }
            confirmAction.isEnabled = false
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            alertController.addTextField { $0.text = payload.task.name }
            NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: alertController.textFields?.first,
                queue: .main
            ) { _ in
                guard let text = alertController.textFields?.first?.text else { return }
                confirmAction.isEnabled = !text.isEmpty
            }
            host.present(alertController, animated: true)
        }

        eventBus.on(DeleteTask.self, by: self) { host, payload in
            let alertController = UIAlertController(title: "Delete Subtask", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                _ = TaskService.shared.remove(task: payload.task)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            host.present(alertController, animated: true)
        }

        eventBus.on(CompleteTask.self, by: self) { _, payload in
            TaskService.shared.complete(task: payload.task)
        }
    }

    private func withRandomAnimal(completion: @escaping (AnimalModel?) -> Void) {
        APIService.config.baseUrl = [
            "https://api.thecatapi.com/v1",
            "https://api.thedogapi.com/v1",
        ][Int.random(in: 0 ... 1)]
        let apiKey = (Bundle.main.object(forInfoDictionaryKey: "Secrets") as? [String: String])?["THE_DOG_API_KEY"] ?? ""
        APIService.shared.fetch(
            url: "/images/search",
            model: [AnimalModel].self,
            queryItems: [.init(name: "api_key", value: apiKey)]
        ) { result in
            switch result {
            case .success(let animals):
                if let animal = animals.first {
                    completion(animal)
                }
            case .failure(let error):
                debugPrint(error)
                completion(nil)
            }
        }
    }
}
