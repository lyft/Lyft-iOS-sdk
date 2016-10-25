import UIKit

/// Button that exposes convenience methods for colors
class Button: UIButton {

    /// Set the Button's highlightedColor from IB
    @IBInspectable var highlightedColor: UIColor? {
        didSet { self.updateStateColors() }
    }

    private func updateStateColors() {
        if let highlightedColor = self.highlightedColor {
            self.setBackgroundImage(highlightedColor.toImage(), for: .highlighted)
        } else {
            self.setBackgroundImage(nil, for: .highlighted)
        }
    }
}
