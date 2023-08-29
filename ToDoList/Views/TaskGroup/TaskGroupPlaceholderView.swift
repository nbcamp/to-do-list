import UIKit

final class TaskGroupPlaceholderView: UIView, Identifier {
    var newTaskButtonTapped: ((UIView) -> Void)? {
        didSet { vStackView.addGestureAction(newTaskButtonTapped) }
    }

    private lazy var vStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            taskImageView,
            titleLabel,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10.0
        taskImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.3),
            taskImageView.heightAnchor.constraint(equalTo: taskImageView.widthAnchor, multiplier: 0.9),
        ])

        return stackView
    }()

    private lazy var taskImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray3
        imageView.image = .init(systemName: "plus.square")
        return imageView
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "Add New Task!"
        label.textColor = .systemGray3
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        addSubview(vStackView)
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}
