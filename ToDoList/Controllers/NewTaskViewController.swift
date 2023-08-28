import UIKit

final class NewTaskViewController: TypedViewController<NewTaskView> {
    private var task: Task = .init(name: "New Task", color: .random)

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        task.children.append(contentsOf: [
            .init(name: "New Task 1"),
            .init(name: "New Task 2"),
            .init(name: "New Task 3"),
        ])
    }

    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.title = "Accent Color"
        picker.supportsAlpha = false
//        picker.delegate = self
        picker.modalPresentationStyle = .popover
        present(picker, animated: true)
    }
}

extension NewTaskViewController: NewTaskViewDelegate {
    func numberOfSubtasks() -> Int {
        task.children.count
    }

    func prepare(_ header: TaskHeaderView) {
        header.title = task.name
        header.color = task.color
    }

    func prepare(_ cell: NewTaskTableViewCell, at indexPath: IndexPath) {
        cell.color = task.color
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(newSubtaskTapped)))
    }

    func prepare(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        let subtask = task.children[indexPath.row]
        cell.name = subtask.name
        cell.color = task.color
    }

    func didSelect(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        //
    }

    @objc private func newSubtaskTapped() {
        let alertController = UIAlertController(title: "Add Subtask", message: "What task to you want to add?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alertController.textFields?[0].text, text.isEmpty else { return }
            TaskService.shared.add(subtask: .init(name: text), to: self.task)
        }
        addAction.isEnabled = false
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        alertController.addTextField()
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alertController.textFields?.first,
            queue: .main
        ) { _ in
            guard let text = alertController.textFields?.first?.text else { return }
            addAction.isEnabled = !text.isEmpty
        }
        present(alertController, animated: true)
    }
}

extension NewTaskViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let _ = viewController.selectedColor
    }
}
