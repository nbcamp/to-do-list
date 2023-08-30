import UIKit

final class NewTaskView: UIView, RootView {
    weak var group: TaskGroup?

    private var padding: CGFloat = 20

    lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let header = NewTaskTableViewHeader()
        tableView.tableHeaderView = header
        tableView.register(
            NewTaskTableViewEditCell.self,
            forCellReuseIdentifier: NewTaskTableViewEditCell.identifier
        )
        tableView.register(
            NewTaskTableViewAddCell.self,
            forCellReuseIdentifier: NewTaskTableViewAddCell.identifier
        )
        return tableView
    }()

    func initializeUI() {
        debugPrint(name, #function)

        isUserInteractionEnabled = true
        backgroundColor = .systemBackground

        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
        ])
    }

    deinit { debugPrint(name, #function) }
}

extension NewTaskView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let header = tableView.tableHeaderView as? NewTaskTableViewHeader {
            header.group = group
        }
        return (group?.tasks.count ?? 0) + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewTaskTableViewAddCell.identifier, for: indexPath) as! NewTaskTableViewAddCell
            group?.$color.subscribe(by: cell, immediate: true) { [weak group] cell, _ in
                guard let color = group?.uiColor else { return }
                cell.color = color
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NewTaskTableViewEditCell.identifier, for: indexPath) as! NewTaskTableViewEditCell
        cell.task = group?.tasks[indexPath.row]
        return cell
    }
}

extension NewTaskView: UITableViewDelegate {}
