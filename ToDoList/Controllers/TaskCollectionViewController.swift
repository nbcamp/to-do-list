import UIKit

final class TaskCollectionViewController: TypedViewController<TaskCollectionView> {
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

extension TaskCollectionViewController: TaskCollectionViewDelegate {
    func numberOfTasks(_ view: TaskCollectionView) -> Int {
        groups.count
    }

    func prepare(_ cell: TaskCollectionViewCell, at indexPath: IndexPath) {
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
