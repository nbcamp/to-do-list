import UIKit

final class CircularProgressView: UIView {
    private(set) var radius: CGFloat = 0
    private(set) var color: UIColor = .clear
    private(set) var lineWidth: CGFloat = 0.1

    private let circularLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func radius(_ radius: CGFloat) -> Self {
        self.radius = radius
        return self
    }

    func color(_ color: UIColor) -> Self {
        self.color = color
        return self
    }

    func lineWidth(_ lineWidth: CGFloat) -> Self {
        self.lineWidth = lineWidth
        return self
    }

    func draw() {
        frame.size = .init(width: radius * 2, height: radius * 2)

        let lineWidth = radius * 0.2
        let circularPath = UIBezierPath(
            arcCenter: .init(x: radius, y: radius),
            radius: radius - (lineWidth / 2),
            startAngle: CGFloat(-Double.pi / 2),
            endAngle: CGFloat(3 * Double.pi / 2),
            clockwise: true
        )

        circularLayer.path = circularPath.cgPath
        circularLayer.fillColor = UIColor.clear.cgColor
        circularLayer.lineCap = .round
        circularLayer.lineWidth = lineWidth
        circularLayer.strokeEnd = 1.0
        circularLayer.strokeColor = color.withAlphaComponent(0.3).cgColor
        layer.addSublayer(circularLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0.0
        progressLayer.strokeColor = color.cgColor
        layer.addSublayer(progressLayer)
    }

    func animate(
        progress: CGFloat,
        duration: TimeInterval = 1.0,
        timingFunction: CAMediaTimingFunction = .init(name: .easeInEaseOut)
    ) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.toValue = progress
        animation.fillMode = .forwards
        animation.timingFunction = timingFunction
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnimation")
    }
}
