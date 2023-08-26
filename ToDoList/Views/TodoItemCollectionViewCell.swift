import UIKit

final class TodoItemCollectionViewCell: UICollectionViewCell, Identifier {
    private lazy var progressView = {
        let progressView = CircularProgressView()
        progressView.radius(50).color(.systemTeal).draw()
        return progressView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initializeUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true

        addSubview(progressView)
        progressView.center = .init(x: bounds.width / 2, y: bounds.height / 2)
        progressView.animate(progress: 0.6)
    }
}
