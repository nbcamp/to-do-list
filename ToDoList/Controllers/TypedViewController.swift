import UIKit

class TypedViewController<View: UIView>: UIViewController where View: RootView {
    var typedView: View { view as! View }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = View()
        typedView.initializeUI()
    }
}
