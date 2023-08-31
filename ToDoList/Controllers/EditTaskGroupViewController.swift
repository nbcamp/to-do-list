import UIKit

final class EditTaskGroupViewController: TypedViewController<EditTaskGroupView> {
    private var groups: [TaskGroup] { TaskService.shared.groups }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typedView.groups = WeakArray(groups)
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
