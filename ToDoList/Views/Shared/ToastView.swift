import UIKit

final class ToastView: UILabel {    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        initializeUI()
    }

    func show(view: UIView, message: String, duration: TimeInterval = 2, position: CGPoint? = nil, color: UIColor = .label, completion: (() -> Void)? = nil) {
        view.addSubview(self)
        text = message
        alpha = .zero
        center = position ?? view.center
        layer.borderColor = color.cgColor
        let translating = CGAffineTransform(translationX: 0, y: -10)
        let scaling = CGAffineTransform(scaleX: 0.9, y: 0.9)
        transform = scaling.concatenating(translating)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) { [weak self] in
            self?.alpha = .one
            self?.transform = .identity
        }
        UIView.animate(withDuration: 0.2, delay: duration, options: .curveEaseIn) { [weak self] in
            self?.alpha = .zero
            self?.transform = scaling.concatenating(translating)
        } completion: { [weak self] _ in
            self?.removeFromSuperview()
            completion?()
        }
    }

    private func initializeUI() {
        frame = .init(x: 0, y: 0, width: 300, height: 35)
        backgroundColor = .white
        textColor = .black
        textAlignment = .center
        font = UIFont.systemFont(ofSize: 14.0)
        layer.cornerRadius = 10
        clipsToBounds = true
        layer.borderWidth = 2.0
        alpha = .zero
    }
}
