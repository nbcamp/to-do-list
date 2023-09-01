import UIKit

final class TaskTableViewCell: UITableViewCell, Identifier {
    weak var task: Subtask? {
        didSet { listenTaskChanged(old: oldValue, new: task) }
    }

    var editable: Bool = false {
        didSet { editable ? enterEditMode() : exitEditMode() }
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

    private var _backgroundColor: UIColor {
        guard let color = task?.group.uiColor else { return .clear }
        return color.theme == .light ? .black.brightness(by: 0.2) : .lightGray.brightness(by: 0.23)
    }

    private lazy var containerView = {
        let view = UIView()
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
        stackView.backgroundColor = .clear
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

    private lazy var reorderBackground = {
        let backgroundView = UIImageView()
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.masksToBounds = true
        backgroundView.isHidden = true
        backgroundView.image = .init(systemName: "line.horizontal.3.circle.fill")
        backgroundView.tintColor = .systemBackground
        return backgroundView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.$name.unsubscribe(by: self)
        task?.$completed.unsubscribe(by: self)
        task?.group.$color.unsubscribe(by: self)
        task = nil
    }

    private func initializeUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(containerView)
        contentView.addSubview(reorderBackground)

        let spacing: CGFloat = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        reorderBackground.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: spacing),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -spacing),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            reorderBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.5),
            reorderBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reorderBackground.widthAnchor.constraint(equalToConstant: 35),
            reorderBackground.heightAnchor.constraint(equalToConstant: 35),
        ])
    }

    private func listenTaskChanged(old oldTask: Subtask?, new newTask: Subtask?) {
        guard oldTask !== newTask, let newTask else { return }
        newTask.$name.subscribe(by: self, immediate: true) { host, name in
            host.titleLabel.text = name.new
        }
        newTask.$completed.subscribe(by: self, immediate: true) { host, completed in
            UIView.animate(withDuration: 0.1) { [weak host] in
                guard let host else { return }
                host.hStackView.layer.opacity = completed.new ? 0.5 : 1.0
                host.markerView.image = .init(systemName: completed.new ? "checkmark.circle" : "circle")
                host.titleLabel.strikethrough(completed.new)
            }
        }
        newTask.group.$color.subscribe(by: self, immediate: true) { host, _ in
            guard let color = host.task?.group.uiColor else { return }
            host.markerView.tintColor = color
            host.titleLabel.textColor = color
            host.containerView.backgroundColor = host._backgroundColor
        }
    }

    private func enterEditMode() {
        state = .delete
        containerView.removeGestureAction()
        reorderBackground.isHidden = false
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
        reorderBackground.isHidden = true
        titleLabel.removeGestureAction()
        markerView.removeGestureAction()
        containerView.addGestureAction { _ in
            EventBus.shared.emit(CompleteTask(payload: .init(task: task)))
        }
    }
}
