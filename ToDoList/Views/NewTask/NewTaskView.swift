import UIKit

protocol NewTaskViewDelegate: AnyObject {
    func numberOfSubtasks() -> Int
    func prepare(_ header: NewTaskTableViewHeader)
    func prepare(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath)
    func prepare(_ cell: NewTaskTableViewAddCell, at indexPath: IndexPath)
    func didSelect(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath)
    func willDelete(_ cell: NewTaskTableViewEditCell, at indexPath: IndexPath)
}

final class NewTaskView: UIView {
    var group: TaskGroup?
    weak var delegate: NewTaskViewDelegate?

    private var padding: CGFloat = 20

    lazy var tableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        let header = NewTaskTableViewHeader()
        header.group = group
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
        delegate?.prepare(tableView.tableHeaderView as! NewTaskTableViewHeader)
        return numberOfSubtasks + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewTaskTableViewAddCell.identifier, for: indexPath) as! NewTaskTableViewAddCell
            delegate?.prepare(cell, at: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NewTaskTableViewEditCell.identifier, for: indexPath) as! NewTaskTableViewEditCell
        cell.deleteButtonTapped = { [unowned self] _ in self.delegate?.willDelete(cell, at: indexPath) }
        delegate?.prepare(cell, at: indexPath)
        return cell
    }
}

extension NewTaskView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NewTaskTableViewEditCell {
            delegate?.didSelect(cell, at: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
