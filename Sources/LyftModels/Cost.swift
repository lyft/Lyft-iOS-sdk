import Foundation

/// Cost and detail estimations for a pickup and destination
public struct RideCostEstimate {
    /// Maximum estimated cost
    public let maxEstimate: Money
    /// Minimum estimated cost
    public let minEstimate: Money
    /// Duration in seconds
    public let durationSeconds: Int
    /// Distance in miles
    public let distanceMiles: Double
}

extension RideCostEstimate: JSONMappable {
    init?(json: NSDictionary) {
        let currency = json["currency"] as? String
        guard let durationSeconds = json["estimated_duration_seconds"] as? Int,
            let distanceMiles = json["estimated_distance_miles"] as? Double,
            let minEstimate = Money(object: json["estimated_cost_cents_min"], currencyCode: currency),
            let maxEstimate = Money(object: json["estimated_cost_cents_max"], currencyCode: currency) else
        {
            return nil
        }

        self.durationSeconds = durationSeconds
        self.distanceMiles = distanceMiles
        self.minEstimate = minEstimate
        self.maxEstimate = maxEstimate
    }
}

/// Cost estimation for a ride
public struct Cost {
    /// The unique ride type key
    public let rideKind: RideKind
    /// A human readable description of the ride type
    public let displayName: String
    /// A human readable prime time percentage text
    public let primeTimePercentageText: String
    /// The estimated costs and information. Requires have a destination in the request.
    public let estimate: RideCostEstimate?
}

extension Cost: JSONMappable {
    init?(json: NSDictionary) {
        guard let rideKind = RideKind(object: json["ride_type"]),
            let primeTimePercentageText = json["primetime_percentage"] as? String,
            let displayName = json["display_name"] as? String else
        {
            return nil
        }

        self.rideKind = rideKind
        self.primeTimePercentageText = primeTimePercentageText
        self.displayName = displayName
        self.estimate = RideCostEstimate(json: json)
    }
}
