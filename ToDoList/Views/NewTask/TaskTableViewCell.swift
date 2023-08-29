import UIKit

final class TaskTableViewCell: UITableViewCell, Identifier {
    var completed = false {
        didSet {
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let weakSelf = self else { return }
                let completed = weakSelf.completed
                weakSelf.hStackView.layer.opacity = completed ? 0.5 : 1.0
                weakSelf.iconView.image = .init(systemName: completed ? "checkmark.circle" : "circle")
                weakSelf.titleLabel.strikethrough = completed
            }
        }
    }

    var name: String = "Task Name" {
        didSet { titleLabel.text = name }
    }

    var color: UIColor = .label {
        didSet {
            iconView.tintColor = color
            titleLabel.textColor = color
            containerView.backgroundColor = _backgroundColor
        }
    }

    private var _backgroundColor: UIColor {
        .init(
            light: .black.withAlphaComponent(0.8),
            dark: .black.withAlphaComponent(0.1),
            for: color
        )
    }

    var deleteButtonTapped: ((UIView) -> Void)?
    var taskNameTapped: ((UIView) -> Void)?

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
        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10.0
        return stackView
    }()

    private lazy var iconView = {
        let iconView = UIImageView(frame: .zero)
        iconView.tintColor = color
        iconView.image = .init(systemName: "multiply.circle")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        iconView.addAction { [unowned self] view in self.deleteButtonTapped?(view) }
        return iconView
    }()

    private lazy var titleLabel = {
        let label = UIExtendedLabel()
        label.text = name
        label.textColor = color
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.addAction { [unowned self] view in self.taskNameTapped?(view) }
        return label
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
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
    }
}
