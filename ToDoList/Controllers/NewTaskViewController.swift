import UIKit

final class NewTaskViewController: UIViewController {
    private var padding: CGFloat = 20

    private lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = TaskHeaderView()
        tableView.register(
            TaskTableViewCell.self,
            forCellReuseIdentifier: TaskTableViewCell.identifier
        )
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    private func initializeUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        let safeArea = view.safeAreaLayoutGuide
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -padding),
        ])
    }

    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.title = "Accent Color"
        picker.supportsAlpha = false
        picker.delegate = self
        picker.modalPresentationStyle = .popover
        present(picker, animated: true)
    }
}

extension NewTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        return cell
    }
}

extension NewTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
            cell.completed.toggle()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewTaskViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let _ = viewController.selectedColor
    }
}
