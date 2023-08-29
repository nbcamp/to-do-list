import UIKit

final class TaskCollectionViewController: TypedViewController<TaskCollectionView> {
    private var tasks: [TaskGroup] { TaskService.shared.tasks }

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension TaskCollectionViewController: TaskCollectionViewDelegate {
    func numberOfTasks(_ view: TaskCollectionView) -> Int {
        tasks.count
    }

    func prepare(_ cell: TaskCollectionViewCell, at indexPath: IndexPath) {
        let task = tasks[indexPath.item]
        cell.title = task.name
        cell.color = task.color
        cell.numberOfTasks = task.children.count
        cell.progress = task.progress
    }

    func placeholderViewTapped(_ view: UIView) {
        pushNewTaskViewController()
    }

    func newTaskMenuTapped() {
        pushNewTaskViewController()
    }

    func editTasksMenuTapped() {
        //
    }

    private func pushNewTaskViewController() {
        let vc = NewTaskViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
