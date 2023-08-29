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

    var imageTapped: ((UIView) -> Void)?

    lazy var progressView = {
        let progressView = CircularProgressView()
        progressView.delegate = self
        progressView.size = size
        progressView.color = color
        progressView.draw()
        return progressView
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFill
        imageView.transform = .init(scaleX: 0.5, y: 0.5)
        imageView.addGestureAction { [unowned self] view in self.imageTapped?(view) }
        return imageView
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        addSubview(progressView)
    }
}

extension CircularProgressViewCell: CircularProgressViewDelegate {
    func innerView(_ view: UIView) {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0),
        ])
    }
}
