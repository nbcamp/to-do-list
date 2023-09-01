import UIKit

final class DetailTaskViewController: TypedViewController<TaskTableView> {
    weak var group: TaskGroup?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()

        EventBus.shared.on(UpdateTaskGroup.self, by: self) { host, payload in
            host.group = payload.group
            host.typedView.tableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typedView.group = group
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let group else { return }
        let vc = NewTaskViewController(group: group)
        navigationController?.pushViewController(vc, animated: false)
    }

    deinit { EventBus.shared.reset(self) }
}
