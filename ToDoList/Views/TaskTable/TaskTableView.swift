import UIKit

final class TaskTableView: UIView, RootView {
    var editable = false {
        didSet { tableView.setEditing(editable, animated: true) }
    }

    weak var group: TaskGroup? {
        didSet { listenTaskGroupChanged(old: oldValue, new: group) }
    }

    private var padding: CGFloat = 20

    lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = TaskTableViewHeader()
        tableView.register(
            TaskTableViewCell.self,
            forCellReuseIdentifier: TaskTableViewCell.identifier
        )
        tableView.register(
            TaskTableViewAddCell.self,
            forCellReuseIdentifier: TaskTableViewAddCell.identifier
        )
        return tableView
    }()

    func initializeUI() {
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

    private func listenTaskGroupChanged(old oldGroup: TaskGroup?, new newGroup: TaskGroup?) {
        guard oldGroup !== newGroup, let newGroup else { return }
        newGroup.$tasks.subscribe(by: self, immediate: true) { host, tasks in
            if tasks.old.count < tasks.new.count {
                let indexPath = IndexPath(row: tasks.new.count - 1, section: 0)
                host.tableView.insertRows(at: [indexPath], with: .automatic)
                host.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            } else if tasks.old.count > tasks.new.count {
                let changes = Array(zip(tasks.old, tasks.new))
                let index = changes.firstIndex { $0.0 !== $0.1 } ?? tasks.old.count - 1
                let indexPath = IndexPath(row: index, section: 0)
                host.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension TaskTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let header = tableView.tableHeaderView as? TaskTableViewHeader {
            header.group = group
            header.editable = editable
        }
        return (group?.tasks.count ?? 0) + (editable ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if editable, indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewAddCell.identifier, for: indexPath) as! TaskTableViewAddCell
            cell.group = group
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        cell.task = group?.tasks[indexPath.row]
        cell.editable = editable
        return cell
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return editable && indexPath.row != group?.tasks.count
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        group?.tasks.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.row == group?.tasks.count ? sourceIndexPath : proposedDestinationIndexPath
    }
}

extension TaskTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
