import UIKit

/// The purpose of this class is to avoid creating UIImage instances using strings throughout the code.
/// Applications might extend this struct and add all the assets on the application, for example:
///
/// ```
/// extension Asset {
///     static let Car = Asset("car")
/// }
/// ```
/// ... and then you can get an instance of UIImage by doing: `Asset.Car.image()`.
class Asset {

    /// The string value of the asset name
    var rawValue: String

    /// Initialize an asset with a given asset name
    ///
    /// - parameter value:  The asset name for this asset
    ///
    /// - returns:  A newly constructed asset
    init(_ value: String) {
        self.rawValue = value
    }

    /// Creates an UIImage using the asset rawValue and given rendering mode.
    ///
    /// - returns: A new image object with the specified rendering mode.
    func image() -> UIImage?
    {
        return UIImage(named: self.rawValue, in: Bundle(for: type(of: self)), compatibleWith: nil )
    }
}

extension Asset {
    static let lyftLogoMulberry = Asset("Lyft Logo - Mulberry")
    static let lyftLogoPink = Asset("Lyft Logo - Pink")
    static let lyftLogoWhite = Asset("Lyft Logo - White")
    static let lyftAppIconPink = Asset("Lyft App Icon - Pink")
    static let primeTimeWhite = Asset("Prime Time - White")
    static let primeTimeCharcoal = Asset("Prime Time - Charcoal")
    static let primeTimeMulberry = Asset("Prime Time - Mulberry")
}
