import UIKit

final class ToDoItemCollectionViewCell: UICollectionViewCell, Identifier {
    var title: String = "Task"
    var numberOfTasks: Int = 0
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
        let progressView = CircularProgressView()
        progressView.delegate = self

        let width = bounds.width - (margin * 2)
        progressView.size = width
        progressView.color = color
        progressView.draw()
        return progressView
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initializeUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 20
        layer.masksToBounds = true

        addSubview(vStackView)
        progressView.animate(progress: 0.6)
    }
}

extension ToDoItemCollectionViewCell: CircularProgressViewDelegate {
    func innerView(_ view: UIView) {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
        ])
    }
}
