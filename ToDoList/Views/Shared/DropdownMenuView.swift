import UIKit

@objc protocol DropdownMenuDelegate {
    @objc optional func initialize(_ view: DropdownMenuView)
}

final class DropdownMenu {
    let icon: String
    let title: String
    let handler: ((DropdownMenu) -> Void)?

    init(icon: String, title: String, handler: ((DropdownMenu) -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.handler = handler
    }
}

final class DropdownMenuView: UIView {
    var opened: Bool = false {
        didSet { opened ? appear() : disappear() }
    }

    var onSelected: ((DropdownMenu) -> Void)?
    weak var delegate: DropdownMenuDelegate?
    private(set) weak var relative: UIView?

    private(set) var menus: [DropdownMenu]
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        return tableView
    }()

    init(_ menus: [DropdownMenu], on target: UIView, delegate: DropdownMenuDelegate? = nil) {
        self.menus = menus
        self.relative = target
        self.delegate = delegate
        super.init(frame: .zero)
        initializeUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initializeUI() {
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor

        delegate?.initialize?(self)

        addSubview(tableView)
        tableView.frame = bounds
    }

    private func appear() {
        layer.opacity = .zero
        transform = .init(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = .one
            self.transform = .identity
        }
    }

    private func disappear() {
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = .zero
            self.transform = .init(scaleX: 0.5, y: 0.5)
        }
    }
}

extension DropdownMenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let menu = menus[indexPath.row]
        cell.imageView?.tintColor = .label
        cell.imageView?.image = .init(systemName: menu.icon)
        cell.textLabel?.text = menu.title
        return cell
    }
}

extension DropdownMenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = menus[indexPath.row]
        onSelected?(menu)
        menu.handler?(menu)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
