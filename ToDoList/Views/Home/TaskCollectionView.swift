import UIKit

protocol TaskCollectionViewDelegate: AnyObject {
    func numberOfTasks(_ view: TaskCollectionView) -> Int
    func prepare(_ cell: TaskCollectionViewCell, at indexPath: IndexPath)
    func placeholderViewTapped(_ view: UIView)
    func newTaskMenuTapped()
    func editTasksMenuTapped()
}

final class TaskCollectionView: UIView {
    weak var delegate: TaskCollectionViewDelegate?

    private let spacing: CGFloat = 15
    private let padding: CGFloat = 20
    private let columns = 2
    private var dropdownMenuView: DropdownMenuView?

    lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let collectionView = UICollectionView(frame: superview?.bounds ?? .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
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

extension TaskCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfTasks = delegate?.numberOfTasks(self) ?? 0
        placeholderView.isHidden = numberOfTasks > 0
        if placeholderView.isHidden {
            placeholderView.gestureRecognizers?.forEach(placeholderView.removeGestureRecognizer)
        } else {
            placeholderView.addAction { [unowned self] view in self.delegate?.placeholderViewTapped(view) }
        }
        return numberOfTasks
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
            header.onMenuTapped = { [unowned self] target in
                if self.dropdownMenuView == nil {
                    self.setupMenu(target: target)
                }
                guard let dropdownMenuView = self.dropdownMenuView else { return }
                dropdownMenuView.opened.toggle()
            }
            return header
        default:
            fatalError("Unknown Element Kind")
        }
    }

    private func setupMenu(target: UIView) {
        let menus: [DropdownMenu] = [
            .init(icon: "plus.circle", title: "New Task", handler: { [unowned self] _ in self.delegate?.newTaskMenuTapped() }),
            .init(icon: "pencil.circle", title: "Edit Tasks", handler: { [unowned self] _ in self.delegate?.editTasksMenuTapped() }),
        ]
        dropdownMenuView = DropdownMenuView(menus, on: target, root: self, delegate: self)
        dropdownMenuView?.onSelected = { [unowned self] _ in
            self.dropdownMenuView?.opened = false
            self.dropdownMenuView = nil
        }
        addSubview(dropdownMenuView!)
    }
}

extension TaskCollectionView: UICollectionViewDelegate {}

extension TaskCollectionView: UICollectionViewDelegateFlowLayout {
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

extension TaskCollectionView: DropdownMenuDelegate {
    func initialize(_ view: DropdownMenuView) {
        guard let target = view.relativeView else { return }
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
