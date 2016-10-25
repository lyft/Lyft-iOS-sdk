import LyftSDK
import XCTest

private extension Money {
    init(amount: Decimal) {
        self.amount = amount
        self.currencyCode = "USD"
    }
}

final class MoneyTests: XCTestCase {

    func testEquality() {
        XCTAssert(Money(amount: 5) == Money(amount: 5))
        XCTAssertFalse(Money(amount: 5) == Money(amount: 5, currencyCode: "JPY"))
        XCTAssertFalse(Money(amount: 5) == Money(amount: 4))
    }

    func testGreaterThan() {
        XCTAssert(Money(amount: 5) > Money(amount: 4))
        XCTAssertFalse(Money(amount: 5) > Money(amount: 5))
        XCTAssertFalse(Money(amount: 5) > Money(amount: 6))
    }

    func testGreaterThanOrEqual() {
        XCTAssert(Money(amount: 5) >= Money(amount: 4))
        XCTAssert(Money(amount: 5) >= Money(amount: 5))
        XCTAssertFalse(Money(amount: 5) >= Money(amount: 6))
    }

    func testSmallerThan() {
        XCTAssert(Money(amount: 5) < Money(amount: 6))
        XCTAssertFalse(Money(amount: 5) < Money(amount: 5))
        XCTAssertFalse(Money(amount: 5) < Money(amount: 4))
    }

    func testSmallerThanOrEqual() {
        XCTAssert(Money(amount: 5) <= Money(amount: 6))
        XCTAssert(Money(amount: 5) <= Money(amount: 5))
        XCTAssertFalse(Money(amount: 5) <= Money(amount: 4))
    }

    func testAddMoneyValue() {
        XCTAssertEqual(Money(amount: 5) + Money(amount: 4), Money(amount: 9))

    }

    func testSubtractMoneyValue() {
        XCTAssertEqual(Money(amount: 5) - Money(amount: 4), Money(amount: 1))

    }

    func testMultipliesIntValue() {
        XCTAssertEqual(Money(amount: 5) * 2, Money(amount: 10))

    }

    func testDividesIntValue() {
        XCTAssertEqual(Money(amount: 5) / 2, Money(amount: 2.5))

    }

    func testCreatingNegativeValue() {
        XCTAssertEqual(-Money(amount: 5), Money(amount: -5))
    }
}
