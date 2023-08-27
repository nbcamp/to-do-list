import UIKit

protocol TaskListViewDelegate: AnyObject {
    func numberOfTasks(_ view: TaskListView) -> Int
    func prepare(_ cell: TaskCollectionViewCell, at indexPath: IndexPath)
    func placeholderViewTapped()
    func newTaskMenuTapped()
    func editTasksMenuTapped()
}

final class TaskListView: UIView {
    weak var delegate: TaskListViewDelegate?

    private let spacing: CGFloat = 15
    private let padding: CGFloat = 20
    private let columns = 2
    private var dropdownMenuView: DropdownMenuView?

    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let collectionView = UICollectionView(frame: superview?.bounds ?? .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 10, left: padding, bottom: 10, right: padding)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TaskListCollectionReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TaskListCollectionReusableHeader.identifier
        )
        collectionView.register(
            TaskCollectionViewCell.self,
            forCellWithReuseIdentifier: TaskCollectionViewCell.identifier
        )
        return collectionView
    }()

    private lazy var placeholderView = {
        let emptyView = TaskEmptyView()
        emptyView.isHidden = true
        return emptyView
    }()

    init(delegate: TaskListViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    private func initializeUI() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        addSubview(placeholderView)

        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
}

extension TaskListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfTasks = delegate?.numberOfTasks(self) ?? 0
        placeholderView.isHidden = numberOfTasks > 0
        if placeholderView.isHidden {
            placeholderView.gestureRecognizers?.forEach(placeholderView.removeGestureRecognizer)
        } else {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(placeholderViewTapped))
            placeholderView.addGestureRecognizer(tapGesture)
        }
        return numberOfTasks
    }

    @objc private func placeholderViewTapped() {
        delegate?.placeholderViewTapped()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.identifier, for: indexPath) as! TaskCollectionViewCell
        delegate?.prepare(cell, at: indexPath)
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
            .init(icon: "plus.circle", title: "New Task", handler: { _ in self.delegate?.newTaskMenuTapped() }),
            .init(icon: "pencil.circle", title: "Edit Tasks", handler: { _ in self.delegate?.editTasksMenuTapped() }),
        ]
        dropdownMenuView = DropdownMenuView(menus, on: target, delegate: self)
        dropdownMenuView?.onSelected = { _ in
            self.dropdownMenuView?.opened = false
            self.dropdownMenuView = nil
        }
        addSubview(dropdownMenuView!)
    }
}

extension TaskListView: UICollectionViewDelegate {}

extension TaskListView: UICollectionViewDelegateFlowLayout {
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

extension TaskListView: DropdownMenuDelegate {
    func initialize(_ view: DropdownMenuView) {
        guard let target = view.relative else { return }
        view.layer.anchorPoint = .init(x: 1, y: 0)
        let targetFrame = target.convert(target.bounds, to: view)
        view.frame = .init(
            x: targetFrame.origin.x + targetFrame.width - 150,
            y: targetFrame.origin.y + targetFrame.height + 5,
            width: 150,
            height: CGFloat(view.menus.count * 45)
        )
    }
}
