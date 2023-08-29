import UIKit

final class NewTaskTableViewAddCell: UITableViewCell, Identifier {
    var color: UIColor = .label {
        didSet {
            containerView.backgroundColor = color
            iconView.tintColor = _textColor
            titleLabel.textColor = _textColor
        }
    }

    private var _textColor: UIColor {
        .init(
            light: .black.withAlphaComponent(0.8),
            dark: .white.withAlphaComponent(0.8),
            for: color
        )
    }

    private lazy var containerView = {
        let view = UIView()
        view.backgroundColor = color
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
        iconView.tintColor = _textColor
        iconView.image = .init(systemName: "plus.circle")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        return iconView
    }()

    private lazy var titleLabel = {
        let label = UIExtendedLabel()
        label.text = "Add New Subtask"
        label.textColor = _textColor
        label.font = .systemFont(ofSize: 20, weight: .semibold)
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
