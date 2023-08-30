import UIKit

final class TaskGroupView: UIView, RootView {
    var groups: [TaskGroup]?

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
            TaskGroupCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TaskGroupCollectionViewHeader.identifier
        )
        collectionView.register(
            TaskGroupCollectionViewCell.self,
            forCellWithReuseIdentifier: TaskGroupCollectionViewCell.identifier
        )
        return collectionView
    }()

    private lazy var placeholderView = {
        let emptyView = TaskGroupPlaceholderView()
        emptyView.isHidden = true
        return emptyView
    }()

    func initializeUI() {
        debugPrint(name, #function)

        backgroundColor = .systemBackground
        addSubview(collectionView)
        addSubview(placeholderView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),

            placeholderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    deinit { debugPrint(name, #function) }
}

extension TaskGroupView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = groups?.count ?? 0
        placeholderView.isHidden = count > 0
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskGroupCollectionViewCell.identifier, for: indexPath) as! TaskGroupCollectionViewCell
        cell.group = groups?[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TaskGroupCollectionViewHeader.identifier, for: indexPath) as! TaskGroupCollectionViewHeader
            header.onMenuTapped = { [unowned self] target in
                if dropdownMenuView == nil {
                    setupMenu(target: target)
                }
                guard let dropdownMenuView else { return }
                dropdownMenuView.opened.toggle()
            }
            return header
        default:
            fatalError("Unknown Element Kind")
        }
    }

    private func setupMenu(target: UIView) {
        let menus: [DropdownMenu] = [
            .init(icon: "plus.circle", title: "New Task", handler: { _ in
                EventBus.shared.emit(PushToNewTaskScreen())
            }),
            .init(icon: "pencil.circle", title: "Edit Tasks", handler: { _ in }),
        ]
        dropdownMenuView = DropdownMenuView(menus, on: target, root: self, delegate: self)
        dropdownMenuView?.onSelected = { [unowned self] _ in
            dropdownMenuView?.opened = false
        }
        addSubview(dropdownMenuView!)
    }
}

extension TaskGroupView: UICollectionViewDelegate {}

extension TaskGroupView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = spacing * Double(columns - 1)
        let collectionViewSize = collectionView.frame.width - (totalSpacing + padding * 2)
        let columnWidth = collectionViewSize / Double(columns)
        return .init(width: columnWidth, height: columnWidth * 1.4)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.bounds.width, height: 100)
    }
}

extension TaskGroupView: DropdownMenuDelegate {
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
