import UIKit

protocol DebugViewDelegate: AnyObject {
    func initialize(group: TaskGroup)
}

final class DebugView: UIView, RootView {
    weak var delegate: DebugViewDelegate?

    var group: TaskGroup? {
        didSet {
            if let group {
                delegate?.initialize(group: group)
            }
        }
    }

    lazy var titleLabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        return label
    }()

    func initializeUI() {
        backgroundColor = .systemBackground
        addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func updateTitleLabel(text: String?) {
        titleLabel.text = text
        titleLabel.sizeToFit()
    }
}

final class DebugViewController: TypedViewController<DebugView> {
    var group: TaskGroup?

    override func viewDidLoad() {
        print("[\(name)] \(#function)")
        super.viewDidLoad()
        typedView.delegate = self
        typedView.initializeUI()
        typedView.group = group
    }

    deinit {
        print("[\(name)] \(#function)")
    }
}

extension DebugViewController: DebugViewDelegate {
    func initialize(group: TaskGroup) {
        group.subscriber.on(\.$name, by: self, immediate: false) { host, name in
            host.typedView.updateTitleLabel(text: name.new)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.group?.name = "Name Changed"
        }
    }
}
