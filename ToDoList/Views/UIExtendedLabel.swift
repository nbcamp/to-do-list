import UIKit

class UIExtendedLabel: UILabel {
    var strikethrough: Bool = false {
        didSet { updateStrikethrough() }
    }

    override var text: String? {
        didSet { updateStrikethrough() }
    }

    private func updateStrikethrough() {
        guard let text else { return }
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
            value: strikethrough ? NSUnderlineStyle.single.rawValue : [] as [Any],
            range: NSMakeRange(0, attributedText.length)
        )
        self.attributedText = attributedText
    }
}
