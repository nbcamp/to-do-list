import UIKit

final class ColorPickerViewController: UIColorPickerViewController {
    private var _delegate: ColorPickerViewControllerDelegate?

    init(initial: UIColor? = nil, title: String, alpha: Bool = false, completion: @escaping (UIColor?) -> Void) {
        super.init()

        self._delegate = ColorPickerViewControllerDelegate(completion: completion)
        self.selectedColor = initial ?? .clear
        self.title = title
        self.supportsAlpha = alpha
        self.delegate = _delegate
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

final class ColorPickerViewControllerDelegate: NSObject, UIColorPickerViewControllerDelegate {
    var completion: ((UIColor?) -> Void)?

    init(completion: ((UIColor?) -> Void)? = nil) {
        self.completion = completion
    }

    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        completion?(color)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        completion?(nil)
    }
}
