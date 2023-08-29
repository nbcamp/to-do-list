import UIKit

final class TaskHeaderView: UIView {
    var title: String = "" {
        didSet { titleTextField.text = title }
    }

    var numberOfTasks: Int = 0 {
        didSet { subtitleLabel.text = "\(numberOfTasks) Tasks" }
    }

    var color: UIColor = .label {
        didSet {
            imageView.tintColor = color
            progressView.color = color
            colorButton.backgroundColor = color
        }
    }

    var image: UIImage = .init(systemName: "hand.tap")! {
        didSet { imageView.image = image }
    }

    var colorButtonTapped: ((UIView) -> Void)?
    var imageTapped: ((UIView) -> Void)?

    private var margin: CGFloat { bounds.width * 0.1 }

    private lazy var vStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.progressView,
            self.labelStackView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 30

        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            progressView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),
        ])
        return stackView
    }()

    private lazy var progressView = {
        let cell = CircularProgressViewCell()
        cell.size = 180
        cell.color = color
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        return cell
    }()

    private lazy var colorButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = color
        button.layer.cornerRadius = 10.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.addGestureAction { [unowned self] view in self.colorButtonTapped?(view) }
        return button
    }()

    private lazy var labelStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            colorButton,
            titleTextField,
            subtitleLabel,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5.0
        return stackView
    }()

    private lazy var titleTextField = {
        let textField = UITextField()
        textField.text = title
        textField.placeholder = "Enter Task Name"
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = .systemFont(ofSize: 30, weight: .heavy)
        textField.textAlignment = .center
        return textField
    }()

    private lazy var subtitleLabel = {
        let label = UILabel()
        label.text = "\(numberOfTasks) Tasks"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    private lazy var imageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = color
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        endEditing(true)
    }

    private func initializeUI() {
        frame.size.height = 400
        addSubview(vStackView)

        progressView.imageTapped = imageTapped
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
        ])
    }
}

extension TaskHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
}
