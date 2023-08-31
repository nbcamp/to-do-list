import UIKit

final class TaskGroupCollectionViewHeader: UICollectionReusableView, Identifier {
    var onMenuTapped: ((UIView) -> Void)? {
        didSet { if let onMenuTapped { settingButton.addGestureAction(onMenuTapped) } }
    }

    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "To Do List"
        label.font = .systemFont(ofSize: 40, weight: .black)
        label.sizeToFit()
        return label
    }()

    private lazy var settingButton = {
        let button = UIImageView()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        button.image = .init(systemName: "gearshape")?.withConfiguration(imageConfiguration)
        button.contentMode = .scaleAspectFit
        button.tintColor = .label
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initializeUI() {
        addSubview(titleLabel)
        addSubview(settingButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        settingButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            settingButton.widthAnchor.constraint(equalTo: settingButton.heightAnchor, multiplier: .one),
        ])
    }
}
