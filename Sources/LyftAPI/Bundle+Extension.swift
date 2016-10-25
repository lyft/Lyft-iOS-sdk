import Foundation

private class BundleIdentifyingClass { }

extension Bundle {
    /// Represents the bundle for the lyft SDK
    static var lyftSDKBundle: Bundle? {
        return Bundle(for: BundleIdentifyingClass.self)
    }
}
