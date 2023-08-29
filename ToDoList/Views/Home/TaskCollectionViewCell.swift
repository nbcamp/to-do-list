import UIKit

final class TaskCollectionViewCell: UICollectionViewCell, Identifier {
    var group: TaskGroup? {
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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        addSubview(vStackView)
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.observer.on(\.$color, by: self) { (self, color) in
            self.progressView.color = color
        }
        newGroup.observer.on(\.$name, by: self) { (self, name) in
            self.titleLabel.text = name
        }
        newGroup.observer.on(\.$image, by: self) { (self, image) in
            self.progressView.image = image
            self.imageView.image = image
        }
        newGroup.observer.on(\.$tasks, by: self) { (self, tasks) in
            self.subtitleLabel.text = "\(tasks.count) Tasks"
            self.progressView.progressView.progress = self.group?.progress ?? 0.0
        }
    }
}
