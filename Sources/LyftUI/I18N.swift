import Foundation

private class BundleIdentifyingClass { }

private func __(_ key: String) -> String {
    return NSLocalizedString(key, bundle: Bundle.lyftSDKBundle ?? Bundle.main, comment: "")
}

/// Struct for managing localizable strings
struct I18N {

    /// Localizable strings related to the LyftButton
    struct LyftButton {
        static let RideETAFormat            = __("RIDE_ETA_FORMAT")
        static let CostEstimateRangeFormat  = __("COST_ESTIMATE_RANGE_FORMAT")
    }
}
