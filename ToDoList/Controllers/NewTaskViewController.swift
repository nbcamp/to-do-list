import UIKit

final class NewTaskViewController: TypedViewController<NewTaskView> {
    private var task: Task = .init(name: "New Task", color: .random)

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        typedView.addGestureRecognizer(.init(target: self, action: #selector(tapped)))
        task.children.append(contentsOf: [
            .init(name: "New Task 1"),
            .init(name: "New Task 2"),
            .init(name: "New Task 3"),
        ])
    }
    
    @objc private func tapped() {
        print("Tapped")
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

    func prepare(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        //
    }

    func didSelect(_ cell: TaskTableViewCell, at indexPath: IndexPath) {
        //
    }
}

extension NewTaskViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let _ = viewController.selectedColor
    }
}
