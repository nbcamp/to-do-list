import UIKit

class TypedViewController<View: UIView>: UIViewController {
    var typedView: View { view as! View }

    override func loadView() {
        view = View()
    }
}
