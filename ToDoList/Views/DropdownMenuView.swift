import UIKit

struct DropdownMenu {
    let icon: String
    let title: String
    let handler: () -> Void
}

final class DropdownMenuView: UIView {
    var opened: Bool = false {
        didSet { opened ? appear() : disappear() }
    }

    var onSelected: ((DropdownMenu) -> Void)?

    private var menus: [DropdownMenu]
    private var target: UIView
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = .zero
        return tableView
    }()

    init(_ menus: [DropdownMenu], target: UIView) {
        self.menus = menus
        self.target = target
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

        addSubview(tableView)

        let targetFrame = target.convert(target.bounds, to: self)
        frame = .init(
            x: targetFrame.origin.x + targetFrame.width - 150,
            y: targetFrame.origin.y + targetFrame.height + 5,
            width: 150,
            height: CGFloat(menus.count * 45)
        )
        tableView.frame = bounds
    }

    private func appear() {
        layer.opacity = .zero
        transform = .init(translationX: 0, y: -5.0)
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = .one
            self.transform = .identity
        }
    }

    private func disappear() {
        UIView.animate(withDuration: 0.2) {
            self.layer.opacity = .zero
            self.transform = .init(translationX: 0, y: -5.0)
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
        menu.handler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
