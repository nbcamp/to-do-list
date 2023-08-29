import UIKit

final class TaskGroupViewController: TypedViewController<TaskGroupView> {
    private var groups: [TaskGroup] { TaskService.shared.tasks }

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typedView.collectionView.reloadData()
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension TaskGroupViewController: TaskGroupViewDelegate {
    func numberOfTasks(_ view: TaskGroupView) -> Int {
        groups.count
    }

    func prepare(_ cell: TaskGroupCollectionViewCell, at indexPath: IndexPath) {
        cell.group = groups[indexPath.item]
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
