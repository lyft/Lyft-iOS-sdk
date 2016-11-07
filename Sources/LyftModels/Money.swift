import Foundation

/// Represents an amount of money with its corresponding currency code
public struct Money {
    /// The amount of money represented. Based on the currencyCode used
    public let amount: Decimal
    /// The ISO 4217 currency code for the amount (e.g. USD)
    public let currencyCode: String

    /// Initialize a new instance of Money.
    ///
    /// - parameter amount:         The amount of money represented
    /// - parameter currencyCode:   The currency code of this money
    ///
    /// - returns: New instance of Money.
    public init(amount: Decimal, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    /// Create money objects from top level currency and cents.
    ///
    /// - parameter rawValue:   The raw value assumed to be the money amount
    /// - parameter currency:   The currency to use.
    ///
    /// - returns: A money object from the given currency and amount.
    init?(object: Any?, currencyCode: String?) {
        guard let amount = object as? Int, let currencyCode = currencyCode else {
            return nil
        }

        self = Money(amount: Decimal(amount) / 100, currencyCode: currencyCode)
    }
}

// MARK: - Operators overload

extension Money: Comparable {

    public static func == (left: Money, right: Money) -> Bool {
        return left.amount == right.amount && left.currencyCode == right.currencyCode
    }

    public static func >= (left: Money, right: Money) -> Bool {
        assert(left.currencyCode == right.currencyCode, "You cannot compare two different currencies")
        return left.amount >= right.amount
    }

    public static func <= (left: Money, right: Money) -> Bool {
        assert(left.currencyCode == right.currencyCode, "You cannot compare two different currencies")
        return left.amount <= right.amount
    }

    public static func > (left: Money, right: Money) -> Bool {
        assert(left.currencyCode == right.currencyCode, "You cannot compare two different currencies")
        return left.amount > right.amount
    }

    public static func < (left: Money, right: Money) -> Bool {
        assert(left.currencyCode == right.currencyCode, "You cannot compare two different currencies")
        return left.amount < right.amount
    }
}

public func + (left: Money, right: Money) -> Money {
    assert(left.currencyCode == right.currencyCode, "You cannot perform addition on two different currencies")

    let cents = left.amount + right.amount
    return Money(amount: cents, currencyCode: left.currencyCode)
}

public func - (left: Money, right: Money) -> Money {
    let assertMessage = "You cannot perform substraction on two different currencies"
    assert(left.currencyCode == right.currencyCode, assertMessage)

    let cents = left.amount - right.amount
    return Money(amount: cents, currencyCode: left.currencyCode)
}

public func * (left: Money, right: Decimal) -> Money {
    return Money(amount: left.amount * right, currencyCode: left.currencyCode)
}

public func / (left: Money, right: Decimal) -> Money {
    return Money(amount: left.amount / right, currencyCode: left.currencyCode)
}

public prefix func - (x: Money) -> Money {
    return Money(amount: -x.amount, currencyCode: x.currencyCode)
}
