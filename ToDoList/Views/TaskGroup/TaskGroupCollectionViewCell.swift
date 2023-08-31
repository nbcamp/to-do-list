import UIKit

final class TaskGroupCollectionViewCell: UICollectionViewCell, Identifier {
    weak var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

    private var margin: CGFloat { bounds.width * 0.1 }

    private lazy var vStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.progressView,
            self.titleLabel,
            self.subtitleLabel,
        ])
        stackView.axis = .vertical
        stackView.frame = bounds
        stackView.spacing = 5

        stackView.layoutMargins = .init(top: margin, left: margin, bottom: margin, right: margin)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private lazy var progressView = {
        let cell = CircularProgressViewCell()
        cell.size = bounds.width - (margin * 2)
        return cell
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: bounds.width / 7, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel = {
        let label = UILabel()
        label.text = "\(group?.tasks.count ?? 0) Tasks"
        label.font = .systemFont(ofSize: bounds.width / 12, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initializeUI() {
        debugPrint(name, #function)

        layer.cornerRadius = 20
        layer.masksToBounds = true

        addSubview(vStackView)
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.subscriber.on(\.$color, by: self) { [weak newGroup] host, _ in
            guard let color = newGroup?.uiColor else { return }
            host.progressView.color = color
        }
        newGroup.subscriber.on(\.$name, by: self) { host, name in
            host.titleLabel.text = name.new
        }
        newGroup.subscriber.on(\.$image, by: self) { [weak newGroup] host, _ in
            guard let image = newGroup?.uiImage else { return }
            host.progressView.image = image
            host.imageView.image = image
        }
        newGroup.subscriber.on(\.$tasks, by: self) { host, tasks in
            host.subtitleLabel.text = "\(tasks.new.count) Tasks"
            host.progressView.progressView.progress = host.group?.progress ?? 0.0
        }
    }

    deinit { debugPrint(name, #function) }
}
