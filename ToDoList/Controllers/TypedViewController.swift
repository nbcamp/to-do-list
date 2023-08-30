import UIKit

class TypedViewController<View: UIView>: UIViewController where View: RootView {
    var typedView: View { view as! View }

    override func loadView() {
        view = View()
        typedView.initializeUI()
    }
}
