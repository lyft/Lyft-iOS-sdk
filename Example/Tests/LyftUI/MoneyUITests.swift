@testable import LyftSDK
import XCTest

final class MoneyUITests: XCTestCase {

    func testItDisplaysDollarValue() {
        XCTAssertEqual(Money(amount: 5, currencyCode: "USD").formattedPrice(), "$5")
    }

    func testItDisplaysWithFractionDigits() {
        XCTAssertEqual(Money(amount: 5, currencyCode: "USD").formattedPrice(fractionDigits: 2), "$5.00")
    }

    func testItDisplaysCorrectCurrency() {
        XCTAssertEqual(Money(amount: 100, currencyCode: "JPY").formattedPrice(), "¥100")
    }
}
