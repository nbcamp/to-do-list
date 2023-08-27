import UIKit

final class TaskHeaderView: UIView {
    var title: String = "Task"
    var numberOfTasks: Int = 0
    var color: UIColor = .label
    var image: UIImage = .init(systemName: "play")!

    private var margin: CGFloat { bounds.width * 0.1 }

    private lazy var vStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.progressView,
            self.labelStackView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 30

        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
        ])
        return stackView
    }()

    private lazy var progressView = {
        let progressView = CircularProgressView()
        progressView.delegate = self

        let size: CGFloat = 180
        progressView.size = size
        progressView.color = color
        progressView.lineWidth = 0.15
        progressView.draw()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor).isActive = true
        return progressView
    }()

    private lazy var labelStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = self.title
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel = {
        let label = UILabel()
        label.text = "\(numberOfTasks) Tasks"
        label.font = .systemFont(ofSize: 16, weight: .bold)
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
        frame.size.height = 350
        addSubview(vStackView)

        vStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
        ])
    }
}

extension TaskHeaderView: CircularProgressViewDelegate {
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
