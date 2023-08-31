import UIKit

final class EditTaskGroupView: UIView, RootView {
    var groups: WeakArray<TaskGroup>?

    private lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "cell"
        )
        return tableView
    }()

    func initializeUI() {
        backgroundColor = .systemBackground

        addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension EditTaskGroupView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        groups?[section]?.name
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let tasks = groups?[section]?.tasks else { return nil }
        let progress = Double(tasks.filter { $0.completed }.count) / Double(tasks.count)
        return "\(Int(progress * 100.0))% Completed"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        groups?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups?[section]?.tasks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = groups?[indexPath.section]?.tasks[indexPath.row]
        cell.textLabel?.text = task?.name
        return cell
    }
}

extension EditTaskGroupView: UITableViewDelegate {}
