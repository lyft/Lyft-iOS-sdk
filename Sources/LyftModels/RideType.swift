import Foundation

/// The details of a ride type offered by the Lyft platform
public struct RideType {
    /// The unique ride type key
    public let kind: RideKind
    /// A human readable description of the ride type
    public let displayName: String
    /// Icon representing this ride type
    public let imageURL: String?
    /// The number of passengers a car can fit
    public let numberOfSeats: Int
    /// Pricing information related to this ride type
    public let pricingDetails: PricingDetails
}

extension RideType: JSONMappable {
    init?(json: NSDictionary) {
        guard let rideKind = RideKind(object: json["ride_type"]),
            let displayName = json["display_name"] as? String,
            let numberOfSeats = json["seats"] as? Int,
            let pricingDetails = PricingDetails(json: json["pricing_details"])  else
        {
            return nil
        }

        self.kind = rideKind
        self.displayName = displayName
        self.numberOfSeats = numberOfSeats
        self.pricingDetails = pricingDetails
        self.imageURL = json["image_url"] as? String
    }
}
