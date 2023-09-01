import UIKit

final class EditTaskGroupViewController: TypedViewController<EditTaskGroupView> {
    private var groups: [TaskGroup] { TaskService.shared.groups }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .label
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
