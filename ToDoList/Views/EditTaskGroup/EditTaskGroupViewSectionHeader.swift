import UIKit

final class EditTaskGroupViewSectionHeader: UIView {
    weak var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

    var onDeleted: ((TaskGroup) -> Void)? {
        didSet {
            deleteIcon.removeGestureAction()
            deleteIcon.addGestureAction { [weak self] _ in
                if let group = self?.group { self?.onDeleted?(group) }
            }
        }
    }

    private var _textColor: UIColor {
        guard let color = group?.uiColor else { return .clear }
        return (color.isLight ? UIColor.black : UIColor.white).withAlphaComponent(0.8)
    }

    private lazy var containerView = {
        let containerView = UIStackView(arrangedSubviews: [
            imageView,
            headerLabel,
            deleteIcon,
        ])
        containerView.axis = .horizontal
        containerView.spacing = 10
        containerView.layer.cornerRadius = 10
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            deleteIcon.widthAnchor.constraint(equalToConstant: 30),
            deleteIcon.heightAnchor.constraint(equalTo: deleteIcon.widthAnchor),

        ])

        return containerView
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        return imageView
    }()

    private lazy var deleteIcon = {
        let deleteIcon = UIImageView()
        deleteIcon.transform = .init(scaleX: 0.6, y: 0.6)
        deleteIcon.image = .init(systemName: "trash.fill")
        return deleteIcon
    }()

    private lazy var headerLabel = {
        let headerLabel = UILabel()
        headerLabel.font = .systemFont(ofSize: 20, weight: .bold)
        return headerLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func initializeUI() {
        addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.$image.subscribe(by: self) { host, _ in
            guard let image = host.group?.uiImage else { return }
            host.imageView.image = image
        }
        newGroup.$color.subscribe(by: self) { host, _ in
            guard let color = host.group?.uiColor else { return }
            host.containerView.backgroundColor = color
            host.deleteIcon.tintColor = host._textColor
            host.headerLabel.textColor = host._textColor
            host.imageView.layer.borderColor = host._textColor.cgColor
        }
        newGroup.$name.subscribe(by: self) { host, name in
            host.headerLabel.text = name.new
        }
    }
}
