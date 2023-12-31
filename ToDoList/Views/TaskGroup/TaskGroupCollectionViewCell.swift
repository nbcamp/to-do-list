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

    override func prepareForReuse() {
        super.prepareForReuse()
        group?.$color.unsubscribe(by: self)
        group?.$name.unsubscribe(by: self)
        group?.$image.unsubscribe(by: self)
        group?.$tasks.unsubscribe(by: self)
        group?.$progress.unsubscribe(by: self)
        group = nil
    }

    private func initializeUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        addSubview(vStackView)
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.$color.subscribe(by: self, immediate: true) { host, _ in
            guard let color = host.group?.uiColor else { return }
            host.progressView.color = color
        }
        newGroup.$name.subscribe(by: self, immediate: true) { host, name in
            host.titleLabel.text = name.new
        }
        newGroup.$image.subscribe(by: self, immediate: true) { host, _ in
            guard let image = host.group?.uiImage else { return }
            host.progressView.image = image
            host.imageView.image = image
        }
        newGroup.$tasks.subscribe(by: self, immediate: true) { host, tasks in
            host.subtitleLabel.text = "\(tasks.new.count) Tasks"
        }
        newGroup.$progress.subscribe(by: self, immediate: true) { host, progress in
            host.progressView.progress = progress.new
        }
    }
}
