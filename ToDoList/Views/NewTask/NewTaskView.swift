import UIKit

protocol NewTaskViewDelegate: AnyObject {
    func numberOfSubtasks() -> Int
    func prepare(_ header: TaskHeaderView)
    func prepare(_ cell: TaskTableViewCell, at indexPath: IndexPath)
    func prepare(_ cell: NewTaskTableViewCell, at indexPath: IndexPath)
    func didSelect(_ cell: TaskTableViewCell, at indexPath: IndexPath)
    func willDelete(_ cell: TaskTableViewCell, at indexPath: IndexPath)
}

final class NewTaskView: UIView {
    weak var delegate: NewTaskViewDelegate?

    private var padding: CGFloat = 20

    lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let header = TaskHeaderView()
        delegate?.prepare(header)
        tableView.tableHeaderView = header
        tableView.register(
            TaskTableViewCell.self,
            forCellReuseIdentifier: TaskTableViewCell.identifier
        )
        tableView.register(
            NewTaskTableViewCell.self,
            forCellReuseIdentifier: NewTaskTableViewCell.identifier
        )
        return tableView
    }()

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
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
}

extension NewTaskView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfSubtasks = delegate?.numberOfSubtasks() ?? 0
        (tableView.tableHeaderView as! TaskHeaderView).numberOfTasks = numberOfSubtasks
        return numberOfSubtasks + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewTaskTableViewCell.identifier, for: indexPath) as! NewTaskTableViewCell
            delegate?.prepare(cell, at: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
        cell.deleteButtonTapped = { [unowned self] _ in self.delegate?.willDelete(cell, at: indexPath) }
        delegate?.prepare(cell, at: indexPath)
        return cell
    }
}

extension NewTaskView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell {
            delegate?.didSelect(cell, at: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}