import UIKit

final class NewTaskViewController: TypedViewController<TaskTableView> {
    var done: ((TaskGroup) -> Void)?
    var animated = false
    private var group = {
        let group = TaskGroup()
        group.uiColor = .random(in: .dark)
        return group
    }()

    init(
        group: TaskGroup? = nil,
        animated: Bool = false,
        done: ((TaskGroup) -> Void)? = nil
    ) {
        self.done = done
        self.animated = animated
        self.group = group ?? { // TODO: 참조 타입 불러오는 문제 수정
            let group = TaskGroup()
            group.uiColor = .random(in: .dark)
            return group
        }()
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
        navigationItem.leftBarButtonItem = .init(image: .init(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = .init(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        group.$color.subscribe(by: self, immediate: true) { host, _ in
            host.navigationItem.leftBarButtonItem?.tintColor = host.group.uiColor
            host.navigationItem.rightBarButtonItem?.tintColor = host.group.uiColor
        }
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: animated)
    }

    @objc private func doneButtonTapped() {
        guard group.image != nil else { showToast(message: "Choose an image that represents your tasks."); return }
        guard !group.name.isEmpty else { showToast(message: "Fill out the name of the tasks"); return }
        guard !group.tasks.isEmpty else { showToast(message: "Please create at least one task."); return }
        navigationController?.popViewController(animated: animated)
        done?(group)
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
