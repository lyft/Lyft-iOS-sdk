import UIKit

private struct Color {
    static let charcoal = 0x333347
    static let hotPink = 0xFF00BF
    static let hotPinkDark = 0xCF00B2
    static let mulberry = 0x352384
    static let mulberryDark = 0x2A025D
    static let whiteDark = 0xF3F3F5
}

extension UIColor {

    /// Creates an instance of UIColor based on an RGB value.
    ///
    /// - parameter rgbValue: The Integer representation of the RGB value: Example: 0xFF0000.
    /// - parameter alpha:    The desired alpha for the color.
    convenience init(rgbValue: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Creates an UIImage from a color instance. This is useful for button backgrounds.
    ///
    /// - parameter width:  The desired width for the image.
    /// - parameter height: The desired height for the image.
    ///
    /// - returns: A UIImage containing only the instance color.
    func toImage(width: CGFloat = 2, height: CGFloat = 2) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)

        defer { UIGraphicsEndImageContext() }

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(self.cgColor)
            context.fill(rect)
        }

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    /// Lyft brand charcoal color
    static func lyftCharcoal() -> UIColor {
        return UIColor(rgbValue: Color.charcoal)
    }

    /// Lyft brand pink color
    static func lyftPink() -> UIColor {
        return UIColor(rgbValue: Color.hotPink)
    }

    /// Lyft brand dark pink color
    static func lyftPinkDark() -> UIColor {
        return UIColor(rgbValue: Color.hotPinkDark)
    }

    /// Lyft brand mulberry color
    static func lyftMulberry() -> UIColor {
        return UIColor(rgbValue: Color.mulberry)
    }

    /// Lyft brand dark mulberry color
    static func lyftMulberryDark() -> UIColor {
        return UIColor(rgbValue: Color.mulberryDark)
    }

    /// Lyft brand dark white color
    static func lyftWhiteDark() -> UIColor {
        return UIColor(rgbValue: Color.whiteDark)
    }
}
