import UIKit

final class EditTaskGroupViewCell: UITableViewCell, Identifier {
    weak var task: Subtask? {
        didSet { listenTaskChanged(old: oldValue, new: task) }
    }

    private var _backgroundColor: UIColor {
        guard let color = task?.group.uiColor else { return .clear }
        return color.theme == .light ? .black.brightness(by: 0.2) : .lightGray.brightness(by: 0.23)
    }

    private lazy var containerView = {
        let containerView = UIStackView(arrangedSubviews: [
            titleLabel,
        ])
        containerView.axis = .horizontal
        containerView.spacing = 10
        containerView.layer.cornerRadius = 5
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = .init(top: 5, left: 10, bottom: 5, right: 10)

        return containerView
    }()

    private lazy var titleLabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16)
        return titleLabel
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        task?.$name.unsubscribe(by: self)
        task?.group.$color.unsubscribe(by: self)
        task = nil
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func initializeUI() {
        addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    private func listenTaskChanged(old oldTask: Subtask?, new newTask: Subtask?) {
        guard oldTask !== newTask, let newTask else { return }
        newTask.$name.subscribe(by: self, immediate: true) { host, name in
            host.titleLabel.text = name.new
        }
        newTask.$completed.subscribe(by: self, immediate: true) { host, completed in
            host.titleLabel.strikethrough(completed.new)
            host.titleLabel.layer.opacity = completed.new ? 0.6 : 1.0
        }
        newTask.group.$color.subscribe(by: self, immediate: true) { host, color in
            guard let color = host.task?.group.uiColor else { return }
            host.titleLabel.textColor = color
            host.containerView.backgroundColor = host._backgroundColor
        }
    }
}
