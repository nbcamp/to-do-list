import UIKit

final class TaskListCollectionReusableHeader: UICollectionReusableView, Identifier {
    var onMenuTapped: ((UIButton) -> Void)?

    private lazy var title = {
        let label = UILabel()
        label.text = "To Do List"
        label.font = .systemFont(ofSize: 40, weight: .black)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var button = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        button.setImage(.init(systemName: "gearshape")!.withConfiguration(imageConfiguration), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        addSubview(title)
        addSubview(button)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.widthAnchor.constraint(equalTo: button.heightAnchor, multiplier: 1.0),
        ])
    }

    @objc private func settingButtonTapped(_ sender: UIButton) {
        onMenuTapped?(sender)
    }
}
