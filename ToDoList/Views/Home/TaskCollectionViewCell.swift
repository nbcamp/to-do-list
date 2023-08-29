import UIKit

final class TaskCollectionViewCell: UICollectionViewCell, Identifier {
    var title: String = "Task"
    var numberOfTasks: Int = 0
    var progress: Double = 0
    var color: UIColor = .label
    var image: UIImage = .init(systemName: "play")!

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
        cell.color = color
        cell.image = image
        return cell
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = self.title
        label.font = .systemFont(ofSize: bounds.width / 7, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel = {
        let label = UILabel()
        label.text = "\(numberOfTasks) Tasks"
        label.font = .systemFont(ofSize: bounds.width / 12, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = color
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
        progressView.progressView.progress = progress
    }
}
