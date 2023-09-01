import UIKit

final class EditTaskGroupView: UIView, RootView {
    private var groups: [TaskGroup] { TaskService.shared.groups }

    private lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = 60
        tableView.register(
            EditTaskGroupViewCell.self,
            forCellReuseIdentifier: EditTaskGroupViewCell.identifier
        )
        return tableView
    }()

    private lazy var placeholderLabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "It's Empty Here..."
        placeholderLabel.textColor = .systemGray2
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 24, weight: .heavy)
        placeholderLabel.sizeToFit()
        placeholderLabel.isHidden = true
        return placeholderLabel
    }()

    func initializeUI() {
        backgroundColor = .systemBackground

        addSubview(tableView)
        addSubview(placeholderLabel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        if groups.isEmpty {
            placeholderLabel.isHidden = false
        }
    }
}

extension EditTaskGroupView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = EditTaskGroupViewSectionHeader()
        headerView.group = groups[section]
        headerView.onDeleted = { [weak self] group in
            EventBus.shared.emit(DeleteTaskGroup(payload: .init(group: group) { index in
                guard let index else { return }
                let indexSet = IndexSet(integer: index)
                tableView.deleteSections(indexSet, with: .automatic)
                if let groups = self?.groups, groups.isEmpty {
                    self?.placeholderLabel.isHidden = false
                }
            }))
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = EditTaskGroupViewSectionFooter()
        footerView.group = groups[section]
        return footerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditTaskGroupViewCell.identifier, for: indexPath) as! EditTaskGroupViewCell
        cell.task = groups[indexPath.section].tasks[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension EditTaskGroupView: UITableViewDelegate {}
