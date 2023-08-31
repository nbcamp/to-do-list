import UIKit

final class NewTaskViewController: TypedViewController<TaskTableView> {
    private var newGroup: TaskGroup
    private weak var group: TaskGroup?

    private var isToastOpened = false

    init(group: TaskGroup? = nil) {
        self.group = group
        self.newGroup = group?.toModel().toViewModel() ?? {
            let group = TaskGroup()
            group.uiColor = .random(in: .dark)
            return group
        }()
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.group = newGroup
        typedView.editable = true
        setupNavigation()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        newGroup.$color.subscribe(by: self, immediate: true) { host, _ in
            host.navigationItem.leftBarButtonItem?.tintColor = host.newGroup.uiColor
            host.navigationItem.rightBarButtonItem?.tintColor = host.newGroup.uiColor
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: group == nil)
    }

    @objc private func doneButtonTapped() {
        guard newGroup.image != nil else { showToast(message: "Choose an image that represents your tasks."); return }
        guard !newGroup.name.isEmpty else { showToast(message: "Fill out the name of the tasks"); return }
        guard !newGroup.tasks.isEmpty else { showToast(message: "Please create at least one task."); return }

        if let group {
            group.overwrite(newGroup)
        } else {
            TaskService.shared.add(group: newGroup)
        }
        navigationController?.popViewController(animated: group == nil)
    }

    private func showToast(message: String) {
        if isToastOpened { return }
        isToastOpened = true
        let toast = ToastView()
        toast.show(
            view: view,
            message: message,
            position: .init(x: view.center.x, y: view.safeAreaInsets.top),
            color: newGroup.uiColor ?? .black
        ) { [weak self] in self?.isToastOpened = false }
    }

    deinit { debugPrint(name, #function) }
}
