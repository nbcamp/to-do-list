import UIKit

protocol NewTaskViewDelegate: AnyObject {
    func numberOfSubtasks() -> Int
    func prepare(_ header: TaskHeaderView)
    func prepare(_ cell: TaskTableViewCell, at indexPath: IndexPath)
    func didSelect(_ cell: TaskTableViewCell, at indexPath: IndexPath)
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
        return delegate?.numberOfSubtasks() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifier, for: indexPath) as! TaskTableViewCell
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

