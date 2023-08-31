import UIKit

final class DetailTaskViewController: TypedViewController<TaskTableView> {
    weak var group: TaskGroup?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typedView.group = group
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        group?.$color.subscribe(by: self, immediate: true) { host, _ in
            host.navigationItem.leftBarButtonItem?.tintColor = host.group?.uiColor
            host.navigationItem.rightBarButtonItem?.tintColor = host.group?.uiColor
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let group else { return }
        let vc = NewTaskViewController(group: group) { [unowned self] group in
            typedView.group = group
        }
        navigationController?.pushViewController(vc, animated: false)
    }
}
