import UIKit

extension Array where Element: Equatable {
    @discardableResult
    mutating func removeAll(element: Element) -> Int {
        var count = 0
        while let index = firstIndex(of: element) {
            self.remove(at: index)
            count += 1
        }
        return count
    }

    @discardableResult
    mutating func remove(element: Element) -> Int? {
        if let index = firstIndex(of: element) {
            self.remove(at: index)
            return index
        }
        return nil
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
    var name: String { String(describing: type(of: self)) }

    private enum AssociatedKeys {
        static var uiGestureRecognizerKey = "UI_GESTURE_RECOGNIZER_KEY"
        static var uiGestureInstanceKey = "UI_GESTURE_INSTANCE_KEY"
    }

    func addGestureAction(with recognizer: UIGestureRecognizer.Type = UITapGestureRecognizer.self, stop: Bool = true, _ action: @escaping (UIView) -> Void) {
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &AssociatedKeys.uiGestureRecognizerKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let gestureRecognizer = recognizer.init(target: self, action: #selector(self._executeAction))
        objc_setAssociatedObject(self, &AssociatedKeys.uiGestureInstanceKey, gestureRecognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        gestureRecognizer.cancelsTouchesInView = stop
        addGestureRecognizer(gestureRecognizer)
    }
    
    func removeGestureAction() {
        guard let gestureRecognizer = objc_getAssociatedObject(self, &AssociatedKeys.uiGestureInstanceKey) as? UIGestureRecognizer else { return }
        removeGestureRecognizer(gestureRecognizer)        
        objc_setAssociatedObject(self, &AssociatedKeys.uiGestureInstanceKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(self, &AssociatedKeys.uiGestureRecognizerKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc private func _executeAction() {
        if let action = objc_getAssociatedObject(self, &AssociatedKeys.uiGestureRecognizerKey) as? (UIView) -> Void {
            action(self)
        }
    }
}

extension UIView {
    static func instantiateFromNib<T: UIView>() -> T? {
        let nib = UINib(nibName: String(describing: self), bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? T
    }
}

extension UIViewController {
    var name: String { String(describing: type(of: self)) }
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

typealias Base64 = String

extension UIImage {
    var base64: Base64? { pngData()?.base64EncodedString() }

    convenience init?(base64: Base64) {
        guard let data = Data(base64Encoded: base64) else { return nil }
        self.init(data: data)
    }
}

struct RGBA: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
}

extension UIColor {
    var rgba: RGBA? {
        var color: RGBA = .init(red: 0, green: 0, blue: 0, alpha: 0)
        return getRed(&color.red, green: &color.green, blue: &color.blue, alpha: &color.alpha) ? color : nil
    }

    convenience init(rgba: RGBA) {
        self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }

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
        var color: RGBA = .init(red: 0, green: 0, blue: 0, alpha: 0)
        getRed(&color.red, green: &color.green, blue: &color.blue, alpha: &color.alpha)
        let brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000
        return brightness > 0.5
    }

    var isDark: Bool { !self.isLight }
}

extension UILabel {
    func strikethrough(_ enabled: Bool) {
        guard let text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: enabled ? NSUnderlineStyle.single.rawValue : [] as [Any],
            range: NSMakeRange(0, attributedText.length)
        )
        self.attributedText = attributedText
    }
}

extension UIScrollView {
    func scrollToView(_ view: UIView, animated: Bool) {
        let target = self.convert(frame.origin, to: view)
        self.scrollRectToVisible(.init(x: 0, y: target.y, width: 1, height: frame.height), animated: animated)
    }
}
