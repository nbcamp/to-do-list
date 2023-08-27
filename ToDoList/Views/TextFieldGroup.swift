import UIKit

final class TextFieldGroup: UIView {
    var label: String = "Label" {
        didSet { titleLabel.text = label }
    }

    var placeholder: String = "" {
        didSet { textField.placeholder = placeholder }
    }

    weak var delegate: UITextFieldDelegate? {
        didSet { textField.delegate = delegate }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private lazy var container = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, wrapper])
        stackView.axis = .vertical
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        return stackView
    }()

    private lazy var titleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return label
    }()

    private lazy var wrapper = {
        let view = UIView()
        view.addSubview(textField)
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 12.0
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
        ])
        return view
    }()

    private lazy var textField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private func initializeUI() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 70.0).isActive = true

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalTo: widthAnchor),
            container.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}
