import UIKit

final class NewTaskTableViewHeader: UIView {
    var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

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
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalTo: cell.widthAnchor).isActive = true
        return cell
    }()

    private lazy var colorButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10.0
        button.setTitle("Choose Color", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.titleEdgeInsets = .zero
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 120).isActive = true
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
        textField.placeholder = "Enter Task Name"
        textField.returnKeyType = .done
        textField.delegate = self
        textField.font = .systemFont(ofSize: 30, weight: .heavy)
        textField.textAlignment = .center
        return textField
    }()

    private lazy var subtitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismissKeyboard()
    }

    private func dismissKeyboard() {
        endEditing(true)
    }

    private func initializeUI() {
        debugPrint(name, #function)

        frame.size.height = 400
        addSubview(vStackView)

        vStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
        ])

        colorButton.addGestureAction { _ in
            EventBus.shared.emit(PresentColorPicker())
        }
        progressView.addGestureAction { _ in
            EventBus.shared.emit(FetchRandomImage())
        }
    }

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.subscriber.on(\.$name, by: self) { host, name in
            host.titleTextField.text = name
        }
        newGroup.subscriber.on(\.$tasks, by: self) { host, tasks in
            host.subtitleLabel.text = "\(tasks.count) Tasks"
        }
        newGroup.subscriber.on(\.$color, by: self) { host, color in
            host.progressView.color = color
            host.colorButton.backgroundColor = color
            host.colorButton.tintColor = .init(light: .black, dark: .white, for: color)
        }
        newGroup.subscriber.on(\.$image, by: self, immediate: false) { host, image in
            host.progressView.image = image
        }
    }

    deinit { debugPrint(name, #function) }
}

extension NewTaskTableViewHeader: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        group?.name = textField.text ?? ""
    }
}
