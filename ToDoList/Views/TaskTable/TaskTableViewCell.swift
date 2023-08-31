import UIKit

final class TaskTableViewCell: UITableViewCell, Identifier {
    weak var task: Subtask? {
        didSet { listenTaskChanged(old: oldValue, new: task) }
    }

    enum MarkerState: String {
        case complete = "checkmark.circle"
        case incomplete = "circle"
        case delete = "multiply.circle"

        var image: UIImage { .init(systemName: rawValue)! }
    }

    private var state: MarkerState = .incomplete {
        didSet { markerView.image = state.image }
    }

    var editable: Bool = false {
        didSet { editable ? enterEditMode() : exitEditMode() }
    }

    private var _backgroundColor: UIColor {
        .init(
            light: .black.withAlphaComponent(0.8),
            dark: .black.withAlphaComponent(0.1),
            for: task?.group.uiColor ?? .systemBackground
        )
    }

    private lazy var containerView = {
        let view = UIView()
        view.backgroundColor = _backgroundColor
        view.layer.cornerRadius = 10.0
        view.layer.masksToBounds = true
        view.addSubview(hStackView)
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            hStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            hStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        return view
    }()

    private lazy var hStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            markerView,
            titleLabel,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 10.0
        return stackView
    }()

    private lazy var markerView = {
        let iconView = UIImageView(frame: .zero)
        iconView.image = .init(systemName: "checkmark.circle")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        return iconView
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initializeUI() {
        debugPrint(name, #function)

        selectionStyle = .none
        contentView.addSubview(containerView)

        let spacing: CGFloat = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    private func listenTaskChanged(old oldTask: Subtask?, new newTask: Subtask?) {
        guard oldTask !== newTask, let newTask else { return }
        newTask.$name.subscribe(by: self) { host, name in
            host.titleLabel.text = name.new
        }
        newTask.$completed.subscribe(by: self) { host, completed in
            UIView.animate(withDuration: 0.1) { [weak host] in
                guard let host else { return }
                host.hStackView.layer.opacity = completed.new ? 0.5 : 1.0
                host.markerView.image = .init(systemName: completed.new ? "checkmark.circle" : "circle")
                host.titleLabel.strikethrough(completed.new)
            }
        }
        newTask.group.$color.subscribe(by: self) { [weak newTask] host, _ in
            guard let color = newTask?.group.uiColor else { return }
            host.markerView.tintColor = color
            host.titleLabel.textColor = color
            host.containerView.backgroundColor = host._backgroundColor
        }
    }

    private func enterEditMode() {
        state = .delete
        containerView.removeGestureAction()
        titleLabel.addGestureAction(stop: false) { [unowned self] _ in
            guard let task else { return }
            EventBus.shared.emit(EditTaskName(payload: .init(task: task)))
        }
        markerView.addGestureAction { [unowned self] _ in
            guard let task else { return }
            EventBus.shared.emit(DeleteTask(payload: .init(task: task)))
        }
    }

    private func exitEditMode() {
        guard let task else { return }
        state = task.completed ? .complete : .incomplete
        titleLabel.removeGestureAction()
        markerView.removeGestureAction()
        containerView.addGestureAction { _ in
            TaskService.shared.complete(task: task)
        }
    }

    deinit { debugPrint(name, #function) }
}
