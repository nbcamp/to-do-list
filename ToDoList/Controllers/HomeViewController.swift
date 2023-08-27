import UIKit

final class HomeViewController: UIViewController {
    private let spacing: CGFloat = 15
    private let padding: CGFloat = 20
    private let columns = 2
    private var dropdownMenuView: DropdownMenuView?

    private var tasks: [Task] { TaskService.shared.tasks }

    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 10, left: padding, bottom: 10, right: padding)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(
            TaskListCollectionReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TaskListCollectionReusableHeader.identifier
        )
        collectionView.register(TaskCollectionViewCell.self, forCellWithReuseIdentifier: TaskCollectionViewCell.identifier)
        return collectionView
    }()

    private lazy var placeholderView = {
        let emptyView = TaskEmptyView()
        emptyView.isHidden = true
        return emptyView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    private func initializeUI() {
        view.backgroundColor = .systemGray6
        view.addSubview(collectionView)
        view.addSubview(placeholderView)

        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        placeholderView.isHidden = tasks.count > 0
        if placeholderView.isHidden {
            placeholderView.gestureRecognizers?.forEach(placeholderView.removeGestureRecognizer)
        } else {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeholderViewTapped))
            placeholderView.addGestureRecognizer(tapGesture)
        }

        return tasks.count
    }

    @objc private func placeholderViewTapped() {
        pushNewTaskViewController()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.identifier, for: indexPath) as! TaskCollectionViewCell
        let task = tasks[indexPath.item]
        cell.title = task.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskListCollectionReusableHeader.identifier, for: indexPath) as! TaskListCollectionReusableHeader
            header.onMenuTapped = { [weak self] target in
                guard let weakSelf = self else { return }

                if weakSelf.dropdownMenuView == nil {
                    weakSelf.setupMenu(target: target)
                }

                guard let dropdownMenuView = weakSelf.dropdownMenuView else { return }
                dropdownMenuView.opened.toggle()
            }
            return header
        default:
            fatalError("Unknown Element Kind")
        }
    }

    private func setupMenu(target: UIView) {
        let menus: [DropdownMenu] = [
            .init(icon: "plus.circle", title: "New Task", handler: { [weak self] in
                self?.pushNewTaskViewController()
            }),
            .init(icon: "pencil.circle", title: "Edit Tasks", handler: {}),
        ]
        dropdownMenuView = DropdownMenuView(menus, target: target)
        dropdownMenuView!.onSelected = { _ in self.dropdownMenuView?.opened = false }
        view.addSubview(dropdownMenuView!)
    }
    
    private func pushNewTaskViewController() {
        let vc = NewTaskViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate {}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = spacing * Double(columns - 1)
        let collectionViewSize = collectionView.frame.width - (totalSpacing + padding * 2)
        let columnWidth = collectionViewSize / Double(columns)
        return .init(width: columnWidth, height: columnWidth * 1.4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 100)
    }
}
