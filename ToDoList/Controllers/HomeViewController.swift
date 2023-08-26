import UIKit

final class HomeViewController: UIViewController {
    private let spacing: CGFloat = 10
    private let padding: CGFloat = 20
    private let columns = 2
    
    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ToDoListCollectionReusableHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ToDoListCollectionReusableHeader.identifier
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
    }

    private func initializeUI() {
        title = "Main"
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemGreen
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ToDoListCollectionReusableHeader.identifier, for: indexPath)
            return header
        default:
            fatalError("Unknown Element Kind")
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = spacing * Double(columns - 1)
        let collectionViewSize = collectionView.frame.width - (totalSpacing + padding * 2)
        let columnWidth = collectionViewSize / Double(columns)
        return .init(width: columnWidth, height: columnWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .init(width: collectionView.bounds.width, height: 100)
    }
}
