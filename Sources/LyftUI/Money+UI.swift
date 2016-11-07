import Foundation

private let kFormatErrorRepresentation = "ERR"

extension Money {

    /// The price with the appropriate formatting for the current market.
    ///
    /// - parameter fractionDigits: The number of digits to include in the string
    ///
    /// - returns: A String representing the price.
    func formattedPrice(fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = fractionDigits
        formatter.numberStyle = .currency
        formatter.currencyCode = self.currencyCode
        return formatter.string(from: self.amount as NSDecimalNumber) ?? kFormatErrorRepresentation
    }
}
