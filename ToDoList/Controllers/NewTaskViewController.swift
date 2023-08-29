import UIKit

final class NewTaskViewController: TypedViewController<NewTaskView> {
    private var task: TaskGroup = .init(name: "", color: .random())

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        setupNavigation()
        task.children.append(contentsOf: [
            .init(name: "New Task 1"),
            .init(name: "New Task 2"),
            .init(name: "New Task 3"),
        ])
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension NewTaskViewController: NewTaskViewDelegate {
    func numberOfSubtasks() -> Int {
        task.children.count
    }

    func prepare(_ header: TaskHeaderView) {
        header.title = task.name
        header.color = task.color
        header.colorButtonTapped = { [unowned self] _ in
            self.presentColorPicker()
        }
        task.$color.subscribe { color in
            header.color = color
        }
    }

    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = task.color
        picker.title = "Accent Color"
        picker.supportsAlpha = false
        picker.delegate = self
        picker.modalPresentationStyle = .popover
        present(picker, animated: true)
    }

    func prepare(_ cell: NewTaskTableViewCell, at indexPath: IndexPath) {
        cell.color = task.color
        cell.addAction(promptNewSubtask)
        task.$color.subscribe { color in
            cell.color = color
        }
    }

    private func promptNewSubtask(_ view: UIView) {
        let alertController = UIAlertController(title: "Add New Task", message: "What task to you want to add?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            TaskService.shared.add(subtask: .init(name: text), to: self.task)
            let indexPath = IndexPath(row: self.task.children.count - 1, section: 0)
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

    func prepare(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        let subtask = task.children[indexPath.row]
        cell.name = subtask.name
        cell.color = task.color
        cell.taskNameTapped = { [unowned self] view in
            guard let view = view as? UILabel, let text = view.text else { return }
            self.promptEditTaskName(text) { result in
                subtask.name = result
                cell.name = result
            }
        }
        task.$color.subscribe { color in
            cell.color = color
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

    func didSelect(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        //
    }

    func willDelete(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete Subtask", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            TaskService.shared.remove(subtask: self.task.children[indexPath.item], of: self.task)
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
        task.color = color
    }
}
