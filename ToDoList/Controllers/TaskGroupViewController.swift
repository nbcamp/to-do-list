import UIKit

final class TaskGroupViewController: TypedViewController<TaskGroupView> {
    private var groups: [TaskGroup] { TaskService.shared.groups }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typedView.groups = WeakArray(groups)
        typedView.collectionView.reloadData()
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
