import Foundation

/// Represents the estimated time in seconds it will take for the nearest driver to reach the specified
/// location for a given ride type
public struct ETA {
    /// Display name for the ride kind
    public let displayName: String
    /// Seconds estimation for the nearest driver to reach a given location
    /// The ride type represented by this ETA
    public let rideKind: RideKind
    /// Seconds estimation for the nearest driver to reach a given location
    public let seconds: Int
    /// Minutes estimation for the nearest driver to reach a given location
    public var minutes: Int {
        return max(self.seconds / 60, 1)
    }
}

extension ETA: JSONMappable {
    init?(json: NSDictionary) {
        guard let displayName = json["display_name"] as? String,
            let rideKind = (json["ride_type"] as? String).map({ RideKind(rawValue: $0) }),
            let seconds = json["eta_seconds"] as? Int else
        {
            return nil
        }

        self.displayName = displayName
        self.rideKind = rideKind
        self.seconds = seconds
    }
}
