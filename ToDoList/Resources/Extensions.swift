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

    func addGestureAction(_ action: ((UIView) -> Void)?, with recognizer: UIGestureRecognizer.Type = UITapGestureRecognizer.self) {
        guard let action else { return }
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedKeys.gestureRecognizerKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let gestureRecognizer = recognizer.init(target: self, action: #selector(self._executeAction))
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

    func load(url: URL, completion: ((UIImage?) -> Void)? = nil) {
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url) else { completion?(nil); return }
            guard let image = UIImage(data: data) else { completion?(nil); return }
            DispatchQueue.main.async {
                self?.image = image
                completion?(image)
            }
        }
    }
}

extension UIColor {
    typealias RGBA = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)

    convenience init(light: UIColor, dark: UIColor) {
        guard #available(iOS 13.0, *) else { self.init(cgColor: light.cgColor); return }
        self.init(dynamicProvider: { $0.userInterfaceStyle == .dark ? dark : light })
    }

    convenience init(light: UIColor, dark: UIColor, for relative: UIColor) {
        let (_light, _dark) = relative.isLight ? (light, dark) : (dark, light)
        self.init(light: _light, dark: _dark)
    }

    static func random(alpha: CGFloat = .one) -> UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: alpha
        )
    }

    enum ColorStyle {
        case light
        case dark

        func validate(_ color: UIColor) -> Bool {
            switch self {
            case .light:
                return color.isLight
            case .dark:
                return color.isDark
            }
        }
    }

    static func random(in style: ColorStyle, alpha: CGFloat = .one) -> UIColor {
        var color: UIColor
        repeat {
            color = UIColor.random(alpha: alpha)
        } while !style.validate(color)
        return color
    }

    var isLight: Bool {
        var color: RGBA = (0, 0, 0, 0)
        getRed(&color.r, green: &color.g, blue: &color.b, alpha: &color.a)
        let brightness = (color.r * 299 + color.g * 587 + color.b * 114) / 1000
        return brightness > 0.5
    }

    var isDark: Bool { !self.isLight }
}

extension UIScrollView {
    func scrollToView(_ view: UIView, animated: Bool) {
        let target = self.convert(frame.origin, to: view)
        self.scrollRectToVisible(.init(x: 0, y: target.y, width: 1, height: frame.height), animated: animated)
    }
}
