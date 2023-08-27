import UIKit

final class HomeViewController: UIViewController {
    private let spacing: CGFloat = 15
    private let padding: CGFloat = 20
    private let columns = 2
    private var dropdownMenuView: DropdownMenuView?

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
            ToDoListCollectionReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ToDoListCollectionReusableHeader.identifier
        )
        collectionView.register(ToDoItemCollectionViewCell.self, forCellWithReuseIdentifier: ToDoItemCollectionViewCell.identifier)
        return collectionView
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
        view.backgroundColor = .systemGray5
        view.addSubview(collectionView)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoItemCollectionViewCell.identifier, for: indexPath) as! ToDoItemCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ToDoListCollectionReusableHeader.identifier, for: indexPath) as! ToDoListCollectionReusableHeader
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
                guard let weakSelf = self else { return }
                let vc = NewTaskViewController()
                weakSelf.navigationController?.pushViewController(vc, animated: true)
                
            }),
            .init(icon: "pencil.circle", title: "Edit Tasks", handler: { }),
        ]
        dropdownMenuView = DropdownMenuView(menus, target: target)
        dropdownMenuView!.onSelected = { _ in self.dropdownMenuView?.opened = false }
        view.addSubview(dropdownMenuView!)
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
