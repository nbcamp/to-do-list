import UIKit

final class NewTaskViewController: TypedViewController<NewTaskView> {
    private let originImage: UIImage = .init(systemName: "hand.tap")!
    private var group: TaskGroup = .init()
    private var isToastOpened = false
    private let eventBus = EventBus.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        typedView.group = group
        setupNavigation()
        initializeEvents()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func doneButtonTapped() {
        guard group.image != originImage else { showToast(message: "Choose an image that represents your tasks."); return }
        guard !group.name.isEmpty else { showToast(message: "Fill out the name of the tasks"); return }
        guard !group.tasks.isEmpty else { showToast(message: "Please create at least one task."); return }

        TaskService.shared.add(group: group)
        navigationController?.popViewController(animated: true)
    }

    private func showToast(message: String) {
        if isToastOpened { return }
        isToastOpened = true
        let toast = ToastView()
        toast.show(view: view, message: message, position: .init(x: view.center.x, y: view.safeAreaInsets.top), color: group.color) { [weak self] in
            self?.isToastOpened = false
        }
    }

    deinit { debugPrint(name, #function) }
}

extension NewTaskViewController {
    private func initializeEvents() {
        eventBus.on(PresentColorPicker.self, by: self) { host, _ in
            host.presentColorPicker()
        }
        eventBus.on(FetchRandomImage.self, by: self) { host, _ in
            host.withRandomAnimal { [weak host] animal in
                guard let animal else { return }
                DispatchQueue.global().async {
                    guard let url = URL(string: animal.url),
                          let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data)
                    else { return }
                    DispatchQueue.main.async {
                        host?.group.image = image
                    }
                }
            }
        }
        eventBus.on(CreateNewTask.self, by: self) { host, _ in
            host.promptCreateNewTask()
        }
        eventBus.on(EditTaskName.self, by: self) { host, payload in
            host.promptEditTaskName(task: payload.task)
        }
        eventBus.on(DeleteTask.self, by: self) { host, payload in
            host.promptDeleteTask(task: payload.task)
        }
    }

    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = group.color
        picker.title = "Accent Color"
        picker.supportsAlpha = false
        picker.delegate = self
        picker.modalPresentationStyle = .popover
        present(picker, animated: true)
    }

    private func withRandomAnimal(completion: @escaping (Animal?) -> Void) {
        APIService.config.baseUrl = [
            "https://api.thecatapi.com/v1",
            "https://api.thedogapi.com/v1",
        ][Int.random(in: 0 ... 1)]
        let apiKey = (Bundle.main.object(forInfoDictionaryKey: "Secrets") as? [String: String])?["THE_DOG_API_KEY"] ?? ""
        APIService.shared.fetch(url: "/images/search", model: [Animal].self, queryItems: [.init(name: "api_key", value: apiKey)]) { result in
            switch result {
            case .success(let animals):
                if let animal = animals.first {
                    completion(animal)
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }

    private func promptCreateNewTask() {
        let alertController = UIAlertController(title: "Add New Task", message: "What task to you want to add?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            TaskService.shared.add(task: .init(name: text, of: group))
            let indexPath = IndexPath(row: group.tasks.count - 1, section: 0)
            self.typedView.tableView.insertRows(at: [indexPath], with: .automatic)
            self.typedView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
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
        present(alertController, animated: true)
    }

    private func promptEditTaskName(task: Subtask) {
        let alertController = UIAlertController(title: "Edit Task Name", message: "Fill in the name of the task you want to edit.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            task.name = text
        }
        confirmAction.isEnabled = false
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        alertController.addTextField { $0.text = task.name }
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alertController.textFields?.first,
            queue: .main
        ) { _ in
            guard let text = alertController.textFields?.first?.text else { return }
            confirmAction.isEnabled = !text.isEmpty
        }
        present(alertController, animated: true)
    }

    private func promptDeleteTask(task: Subtask) {
        let alertController = UIAlertController(title: "Delete Subtask", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            guard let index = TaskService.shared.remove(task: task) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            self.typedView.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.typedView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
}

extension NewTaskViewController: NewTaskViewDelegate {
    func numberOfSubtasks() -> Int {
        group.tasks.count
    }

    func prepare(_ header: NewTaskTableViewHeader) {
        header.group = group
    }

    func prepare(_ cell: NewTaskTableViewAddCell, at indexPath: IndexPath) {
        group.$color.observe(by: cell, immediate: true) { cell, color in
            cell.color = color
        }
    }

    func prepare(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath) {
        cell.task = group.tasks[indexPath.row]
    }
}

extension NewTaskViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        group.color = viewController.selectedColor
    }
}
