import UIKit

final class CircularProgressViewCell: UIView {
    var size: CGFloat = .zero {
        didSet {
            progressView.size = size
            progressView.draw()
        }
    }

    var color: UIColor = .label {
        didSet {
            imageView.tintColor = color
            progressView.color = color
            progressView.draw()
        }
    }

    var image: UIImage = .init(systemName: "hand.tap")! {
        didSet {
            imageView.transform = .init(scaleX: 1.05, y: 1.05)
            imageView.image = image
        }
    }

    var progress: Double = 0.0 {
        didSet { progressView.progress = progress }
    }

    var loading: Bool = false {
        didSet {
            loading
                ? loadingIndicatorView.startAnimating()
                : loadingIndicatorView.stopAnimating()
        }
    }

    private lazy var progressView = {
        let progressView = CircularProgressView()
        progressView.delegate = self
        progressView.size = size
        progressView.color = color
        progressView.draw()
        return progressView
    }()

    private lazy var loadingIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.transform = .init(scaleX: 1.5, y: 1.5)
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = .black.withAlphaComponent(0.2)
        indicator.color = .white.withAlphaComponent(0.8)
        indicator.isUserInteractionEnabled = true
        indicator.addGestureAction(stop: true) { _ in }
        return indicator
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFill
        imageView.transform = .init(scaleX: 0.5, y: 0.5)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initializeUI() {
        addSubview(progressView)
    }
}

extension CircularProgressViewCell: CircularProgressViewDelegate {
    func innerView(_ view: UIView) {
        view.addSubview(imageView)
        view.addSubview(loadingIndicatorView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0),

            loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            loadingIndicatorView.heightAnchor.constraint(equalTo: loadingIndicatorView.widthAnchor),
        ])
    }
}
