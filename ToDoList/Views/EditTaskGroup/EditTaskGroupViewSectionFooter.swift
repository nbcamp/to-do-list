import UIKit

final class EditTaskGroupViewSectionFooter: UIView {
    weak var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

    private lazy var containerView = {
        let containerView = UIStackView(arrangedSubviews: [
            footerLabel,
        ])
        containerView.axis = .horizontal
        containerView.spacing = 10
        containerView.layer.cornerRadius = 10
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = .init(top: 5, left: 10, bottom: 5, right: 10)

        return containerView
    }()

    private lazy var footerLabel = {
        let footerLabel = UILabel()
        footerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        footerLabel.textColor = .systemGray
        footerLabel.textAlignment = .right
        return footerLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func initializeUI() {
        addSubview(containerView)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.$progress.subscribe(by: self) { host, progress in
            host.footerLabel.text = "\(Int(progress.new * 100.0))% Completed"
        }
    }
}
