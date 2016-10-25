import LyftSDK
import OHHTTPStubs
import CoreLocation
import XCTest

final class LyftAPITests: XCTestCase {

    private func data(responseFileName: String) -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: responseFileName, withExtension: "response")
        return url.flatMap { try? Data(contentsOf: $0) } ?? Data()
    }

    private func stubRequest(responseFileName: String, statusCode: Int32 = 200) {
        OHHTTPStubs.stubRequests(passingTest: { _ in true }) { _ in
            let data = self.data(responseFileName: responseFileName)
            return OHHTTPStubsResponse(data: data, statusCode: statusCode, headers: nil)
        }
    }

    private func stubError() {
        self.stubRequest(responseFileName: "Error", statusCode: 500)
    }

    private func validate(error: LyftAPIError?) {
        XCTAssertEqual(error?.reason, "generic_error")
        XCTAssertEqual(error?.message, "Error description")
        XCTAssertEqual(error?.status, .internalError)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testFetchingETA() {
        let expectation = self.expectation(description: "eta request response")
        self.stubRequest(responseFileName: "ETA")

        LyftAPI.ETAs(to: CLLocationCoordinate2D()) { result in
            let eta = result.value?.filter({ $0.rideKind == .Line }).first
            XCTAssertEqual(eta?.displayName, "Lyft Line")
            XCTAssertEqual(eta?.seconds, 120)
            XCTAssertEqual(eta?.minutes, 2)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testETAFailure() {
        self.stubError()
        let expectation = self.expectation(description: "eta request response")
        LyftAPI.ETAs(to: CLLocationCoordinate2D()) { result in
            self.validate(error: result.error)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testFetchingRideTypes() {
        let expectation = self.expectation(description: "ride types request response")
        self.stubRequest(responseFileName: "RideType")

        LyftAPI.rideTypes(at: CLLocationCoordinate2D()) { result in
            let rideType = result.value?.filter({ $0.kind == .Plus }).first
            let pricing = rideType?.pricingDetails

            XCTAssertEqual(rideType?.imageURL, "https://s3.amazonaws.com/api.lyft.com/assets/car_plus.png")
            XCTAssertEqual(rideType?.displayName, "Lyft Plus")
            XCTAssertEqual(rideType?.numberOfSeats, 6)

            XCTAssertEqual(pricing?.baseCharge, Money(amount: 3, currencyCode: "USD"))
            XCTAssertEqual(pricing?.costPerMile, Money(amount: 2, currencyCode: "USD"))
            XCTAssertEqual(pricing?.costPerMinute, Money(amount: 0.3, currencyCode: "USD"))
            XCTAssertEqual(pricing?.costMinimum, Money(amount: 7, currencyCode: "USD"))

            XCTAssertEqual(pricing?.trustAndServiceFee, Money(amount: 1.55, currencyCode: "USD"))
            XCTAssertEqual(pricing?.cancelPenalty, Money(amount: 5, currencyCode: "USD"))
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testRideTypesFailure() {
        let expectation = self.expectation(description: "ride types request response")
        self.stubError()
        LyftAPI.rideTypes(at: CLLocationCoordinate2D()) { result in
            self.validate(error: result.error)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testItFetchesRideCostEstimatesWithSingleLocation() {
        let expectation = self.expectation(description: "cost estimates request response")
        self.stubRequest(responseFileName: "CostSingleLocation")

        LyftAPI.costEstimates(from: CLLocationCoordinate2D()) { result in
            let cost = result.value?.filter({ $0.rideKind == .Plus }).first
            XCTAssertEqual(cost?.displayName, "Lyft Plus")
            XCTAssertEqual(cost?.primeTimePercentageText, "25%")
            XCTAssertNil(cost?.estimate)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testItFetchesRideCostEstimatesForARide() {
        let expectation = self.expectation(description: "cost estimates request response")
        self.stubRequest(responseFileName: "Cost")

        LyftAPI.costEstimates(from: CLLocationCoordinate2D(), to: CLLocationCoordinate2D())
        { result in
            let cost = result.value?.filter({ $0.rideKind == .Plus }).first
            XCTAssertEqual(cost?.displayName, "Lyft Plus")
            XCTAssertEqual(cost?.primeTimePercentageText, "25%")
            XCTAssertEqual(cost?.estimate?.distanceMiles, 3.29)
            XCTAssertEqual(cost?.estimate?.durationSeconds, 913)

            XCTAssertEqual(cost?.estimate?.minEstimate, Money(amount: 15.61, currencyCode: "USD"))
            XCTAssertEqual(cost?.estimate?.maxEstimate, Money(amount: 23.55, currencyCode: "USD"))

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testCostEstimatesFailure() {
        let expectation = self.expectation(description: "cost estimates request response")
        self.stubError()
        LyftAPI.drivers(near: CLLocationCoordinate2D()) { result in
            self.validate(error: result.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testItFetchesNearbyDrivers() {
        let expectation = self.expectation(description: "cost estimates request response")
        self.stubRequest(responseFileName: "NearbyDrivers")

        LyftAPI.drivers(near: CLLocationCoordinate2D()) { result in
            let nearbyDrivers = result.value?[.Line]
            XCTAssertEqual(nearbyDrivers?.count, 8)

            let position = nearbyDrivers?.first?.position
            XCTAssertEqual(position?.latitude, 37.7800523287)
            XCTAssertEqual(position?.longitude, -122.4560208615)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1) { _ in }
    }

    func testNearbyDriversFailure() {
        let expectation = self.expectation(description: "cost estimates request response")
        self.stubError()
        LyftAPI.drivers(near: CLLocationCoordinate2D()) { result in
            self.validate(error: result.error)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 1) { _ in }
    }
}
