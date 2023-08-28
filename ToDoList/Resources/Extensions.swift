import UIKit

extension Array where Element: Equatable {
    @discardableResult
    mutating func remove(element: Element) -> Int {
        var count = 0
        while let index = firstIndex(of: element) {
            self.remove(at: index)
            count += 1
        }
        return count
    }
}

extension Array {
    mutating func remove(where predicate: (Element) throws -> Bool) rethrows {
        var indexesToRemove = [Int]()

        for (index, element) in self.enumerated() {
            if try predicate(element) {
                indexesToRemove.append(index)
            }
        }

        for index in indexesToRemove.reversed() {
            self.remove(at: index)
        }
    }
}

extension Float {
    static var one: Self { 1.0 }
}

extension CGFloat {
    static var one: Self { 1.0 }
}

extension UIView {
    private enum AssociatedKeys {
        static var gestureRecognizerKey = "GESTURE_RECOGNIZER_KEY"
    }

    func addAction(_ action: ((UIView) -> Void)?, with Recognizer: UIGestureRecognizer.Type = UITapGestureRecognizer.self) {
        guard let action else { return }
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedKeys.gestureRecognizerKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let gestureRecognizer = Recognizer.init(target: self, action: #selector(self._executeAction))
        addGestureRecognizer(gestureRecognizer)
    }

    @objc private func _executeAction() {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.gestureRecognizerKey) as? (UIView) -> Void {
            action(self)
        }
    }
}

extension UIImageView {
    func setImage(_ image: UIImage?, duration: Double = 0.3) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        guard #available(iOS 13.0, *) else { self.init(cgColor: light.cgColor); return }
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }

    convenience init(light: UIColor, dark: UIColor, for relative: UIColor) {
        let (_light, _dark) = relative.isLight ? (light, dark) : (dark, light)
        self.init(light: _light, dark: _dark)
    }

    static var random: UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }

    var isLight: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let brightness = (red * 299 + green * 587 + blue * 114) / 1000

        return brightness > 0.5
    }
}

extension UIScrollView {
    func scrollToView(_ view: UIView, animated: Bool) {
        let target = self.convert(frame.origin, to: view)
        self.scrollRectToVisible(.init(x: 0, y: target.y, width: 1, height: frame.height), animated: animated)
    }
}
