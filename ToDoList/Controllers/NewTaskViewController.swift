import UIKit

final class NewTaskViewController: TypedViewController<TaskTableView> {
    var animated = false
    private var group = {
        let group = TaskGroup()
        group.uiColor = .random(in: .dark)
        return group
    }()

    private var isUpdateMode = false

    init(group: TaskGroup? = nil, animated: Bool = false) {
        self.animated = animated
        self.group = group ?? {
            let group = TaskGroup()
            group.uiColor = .random(in: .dark)
            return group
        }()
        isUpdateMode = group != nil
        super.init()
    }

    private var isToastOpened = false

    override func viewDidLoad() {
        super.viewDidLoad()
        typedView.group = group
        typedView.editable = true
        setupNavigation()
    }

    private func setupNavigation() {
        navigationItem.hidesBackButton = isUpdateMode
        navigationItem.leftBarButtonItem = isUpdateMode ? .none : .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: animated)
    }

    @objc private func doneButtonTapped() {
        guard group.image != nil else { showToast(message: "Choose an image that represents your tasks."); return }
        guard !group.name.isEmpty else { showToast(message: "Fill out the name of the tasks"); return }
        guard !group.tasks.isEmpty else { showToast(message: "Please create at least one task."); return }
        if isUpdateMode {
            EventBus.shared.emit(UpdateTaskGroup(payload: .init(group: group, completion: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: self.animated)
            })))
        } else {
            EventBus.shared.emit(CreateNewTaskGroup(payload: .init(group: group, completion: { [weak self] in
                guard let self else { return }
                self.navigationController?.popViewController(animated: self.animated)
            })))
        }
    }

    private func showToast(message: String) {
        if isToastOpened { return }
        isToastOpened = true
        let toast = ToastView()
        toast.show(
            view: view,
            message: message,
            position: .init(x: view.center.x, y: view.safeAreaInsets.top),
            color: group.uiColor ?? .black
        ) { [weak self] in self?.isToastOpened = false }
    }
}
