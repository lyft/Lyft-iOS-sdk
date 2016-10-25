@testable import LyftSDK
import OHHTTPStubs
import XCTest

extension String: Routable {
    public var url: URL {
        return URL(string: "https://test.com")!
    }

    public var extraHTTPHeaders: [String: String] {
        return [:]
    }
}

final class HTTPClientTests: XCTestCase {

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func testSendingParametersUsingURLEncoding() {
        let expectation = self.expectation(description: "response closure is called")

        OHHTTPStubs.stubRequests(passingTest: { _ in true }) { request in
            XCTAssertEqual(request.url?.query, "foo=bar")
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }

        HTTPClient().request(.get, "", parameters: ["foo": "bar"]) { _, type in
            XCTAssertEqual(type, .succeed)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 2) { _ in }
    }

    func testRequestsThat404() {
        let expectation = self.expectation(description: "response closure is called")
        OHHTTPStubs.stubRequests(passingTest: { _ in true }) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
        }

        HTTPClient().request(.get, "") { _, type in
            XCTAssertEqual(type, .notFound)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 2) { _ in }
    }
}
