import UIKit

final class NewTaskViewController: TypedViewController<NewTaskView> {
    private let originImage: UIImage = .init(systemName: "hand.tap")!
    private var group: TaskGroup = .init()
    private var isToastOpened = false

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        typedView.group = group
        setupNavigation()
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

        TaskService.shared.add(task: group)
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
}

extension NewTaskViewController: NewTaskViewDelegate {
    func numberOfSubtasks() -> Int {
        group.tasks.count
    }

    func prepare(_ header: NewTaskTableViewHeader) {
        header.group = group
        header.colorButtonTapped = { [unowned self] _ in
            self.presentColorPicker()
        }
        header.imageTapped = { [unowned self] view in
            self.withRandomAnimal { animal in
                guard let animal, let view = view as? UIImageView else { return }
                view.load(url: URL(string: animal.url)!) { image in
                    guard let image else { return }
                    self.group.image = image
                }
            }
        }
        header.titleDidEndEditing = { [unowned self] textField in
            self.group.name = textField.text ?? ""
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

    func prepare(_ cell: NewTaskTableViewAddCell, at indexPath: IndexPath) {
        cell.addGestureAction(promptNewSubtask)
        group.$color.observe(by: self, immediate: true) { (_, color) in
            cell.color = color
        }
    }

    private func promptNewSubtask(_ view: UIView) {
        let alertController = UIAlertController(title: "Add New Task", message: "What task to you want to add?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            TaskService.shared.add(subtask: .init(name: text, of: group))
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

    func prepare(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath) {
        let subtask = group.tasks[indexPath.row]
        cell.task = subtask
        cell.taskNameTapped = { [unowned self] view in
            guard let view = view as? UILabel, let text = view.text else { return }
            self.promptEditTaskName(text) { result in
                subtask.name = result
            }
        }
    }

    private func promptEditTaskName(_ originText: String, completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: "Edit Task Name", message: "Fill in the name of the task you want to edit.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            completion(text)
        }
        confirmAction.isEnabled = false
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        alertController.addTextField { $0.text = originText }
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

    func didSelect(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath) {
        // do nothing
    }

    func willDelete(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete Subtask", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            TaskService.shared.remove(subtask: self.group.tasks[indexPath.row], of: self.group)
            self.typedView.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.typedView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
}

extension NewTaskViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        group.color = color
    }
}
