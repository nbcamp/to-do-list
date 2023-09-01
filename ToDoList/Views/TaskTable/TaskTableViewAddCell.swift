import UIKit

final class TaskTableViewAddCell: UITableViewCell, Identifier {
    weak var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

    private var _textColor: UIColor {
        guard let color = group?.uiColor else { return .clear }
        return (color.isLight ? UIColor.black : UIColor.white).withAlphaComponent(0.8)
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
        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10.0

        return stackView
    }()

    private lazy var iconView = {
        let iconView = UIImageView(frame: .zero)
        iconView.image = .init(systemName: "plus.circle")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        return iconView
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "Add New Subtask"
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

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }

    private func initializeUI() {
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

        addGestureAction { [unowned self] _ in
            guard let group else { return }
            EventBus.shared.emit(CreateNewTask(payload: .init(group: group)))
        }
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.$color.subscribe(by: self, immediate: true) { host, _ in
            guard let color = host.group?.uiColor else { return }
            host.containerView.backgroundColor = color
            host.iconView.tintColor = host._textColor
            host.titleLabel.textColor = host._textColor
        }
    }
}
