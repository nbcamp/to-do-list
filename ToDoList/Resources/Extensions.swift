import UIKit

extension Float {
    static var one: Self { 1.0 }
}

extension CGFloat {
    static var one: Self { 1.0 }
}

extension UIImageView {
    func setImage(_ image: UIImage?, duration: Double = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}
