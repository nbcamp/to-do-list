import UIKit

final class TaskGroupViewController: TypedViewController<TaskGroupView> {
    private var groups: [TaskGroup] { TaskService.shared.groups }
    private let eventBus = EventBus.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.delegate = self
        initializeEvents()
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

    deinit {
        print(name, #function)
        eventBus.reset(self)
    }
}

extension TaskGroupViewController {
    private func initializeEvents() {
        eventBus.on(PushToNewTaskScreen.self, by: self) { host, _ in
            host.pushNewTaskViewController()
        }
    }

    @objc private func pushNewTaskViewController() {
        let vc = NewTaskViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension TaskGroupViewController: TaskGroupViewDelegate {
    func numberOfTasks(_ view: TaskGroupView) -> Int {
        groups.count
    }

    func prepare(_ cell: TaskGroupCollectionViewCell, at indexPath: IndexPath) {
        cell.group = groups[indexPath.item]
    }
}
