import UIKit

final class TaskListCollectionReusableHeader: UICollectionReusableView, Identifier {
    var onMenuTapped: ((UIView) -> Void)?

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "To Do List"
        label.font = .systemFont(ofSize: 40, weight: .black)
        label.sizeToFit()
        return label
    }()

    private lazy var button = {
        let button = UIImageView()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        button.image = .init(systemName: "gearshape")?.withConfiguration(imageConfiguration)
        button.contentMode = .scaleAspectFit
        button.tintColor = .label
        button.addAction { [unowned self] view in self.onMenuTapped?(view) }
        return button
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        addSubview(titleLabel)
        addSubview(button)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: .one),
        ])
    }
}
