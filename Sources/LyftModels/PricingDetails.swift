import Foundation

/// Pricing information related to a ride type
public struct PricingDetails {
    /// The initial charge for a ride. This is the fee applied before ride specific costs
    public let baseCharge: Money
    /// The charge amount if cancel penalty is involved
    public let cancelPenalty: Money
    /// The minimum price a ride with this ride type will cost
    public let costMinimum: Money
    /// The cost per mile during a ride
    public let costPerMile: Money
    /// The cost per minute during a ride
    public let costPerMinute: Money
    /// The trust and service fee
    public let trustAndServiceFee: Money
}

extension PricingDetails: JSONMappable {
    init?(json: NSDictionary) {
        let currency = json["currency"] as? String
        guard let baseCharge = Money(object: json["base_charge"], currencyCode: currency),
            let cancelPenalty = Money(object: json["cancel_penalty_amount"], currencyCode: currency),
            let costMinimum = Money(object: json["cost_minimum"], currencyCode: currency),
            let costPerMile = Money(object: json["cost_per_mile"], currencyCode: currency),
            let costPerMinute = Money(object: json["cost_per_minute"], currencyCode: currency),
            let trustAndServiceFee = Money(object: json["trust_and_service"], currencyCode: currency) else
        {
            return nil
        }

        self.baseCharge = baseCharge
        self.cancelPenalty = cancelPenalty
        self.costMinimum = costMinimum
        self.costPerMile = costPerMile
        self.costPerMinute = costPerMinute
        self.trustAndServiceFee = trustAndServiceFee
    }
}
