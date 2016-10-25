import UIKit

/// Pre-made LyftButton style configuration.  Refer to the documentation for style previews.
/// Example to set a style:
///
/// ```
///     myLyftButton.style = .HotPink
/// ```
///
/// - mulberryDark:     Mulberry Dark style
/// - hotPink:          Hot Pink style
/// - mulberryLight:    Mulberry Light style
/// - multicolor:       Multicolor style
/// - launcher:         Launcher style
public enum LyftButtonStyle {
    case mulberryDark
    case hotPink
    case mulberryLight
    case multicolor
    case launcher

    // Lyft logo icon displayed in the button
    var icon: UIImage? {
        switch self {
            case .mulberryDark, .hotPink:
                return Asset.lyftLogoWhite.image()
            case .mulberryLight:
                return Asset.lyftLogoMulberry.image()
            case .multicolor:
                return Asset.lyftLogoPink.image()
            case .launcher:
                return Asset.lyftAppIconPink.image()
        }
    }

    /// The prime time image icon
    var primeTimeIcon: UIImage? {
        switch self {
            case .mulberryDark, .hotPink:
                return Asset.primeTimeWhite.image()
            case .mulberryLight, .launcher:
                return Asset.primeTimeMulberry.image()
            case .multicolor:
                return Asset.primeTimeCharcoal.image()
        }
    }

    /// Background color of the button
    var backgroundColor: UIColor {
        switch self {
            case .mulberryDark:
                return .lyftMulberry()
            case .hotPink:
                return .lyftPink()
            case .mulberryLight, .multicolor, .launcher:
                return .white
        }
    }

    /// Highlight color of the button
    var highlightedColor: UIColor {
        switch self {
            case .mulberryDark:
                return .lyftMulberryDark()
            case .hotPink:
                return .lyftPinkDark()
            case .mulberryLight, .multicolor, .launcher:
                return .lyftWhiteDark()
        }
    }

    /// Text color of the button
    var foregroundColor: UIColor {
        switch self {
            case .mulberryDark, .hotPink:
                return .white
            case .mulberryLight, .launcher:
                return .lyftMulberry()
            case .multicolor:
                return .lyftCharcoal()
        }
    }
}
