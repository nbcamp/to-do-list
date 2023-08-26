import UIKit

final class ToDoListCollectionReusableHeader: UICollectionReusableView, Identifier {
    private lazy var hStackView = {
        let stackView = UIStackView(arrangedSubviews: [title, settingButton])
        stackView.axis = .horizontal
        stackView.frame = self.bounds
        return stackView
    }()
    
    private lazy var title = {
        let label = UILabel()
        label.text = "To Do List"
        label.font = .boldSystemFont(ofSize: 40)
        label.sizeToFit()
        return label
    }()
    
    private lazy var settingButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large)
        button.setImage(.init(systemName: "gearshape")!.withConfiguration(imageConfiguration), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func initializeUI() {
        addSubview(hStackView)
    }
}
