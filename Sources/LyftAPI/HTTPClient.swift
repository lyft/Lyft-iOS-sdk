import Foundation

private let kErrorMap: [Int: ResponseType] = [
    400: .badRequest,
    401: .unauthorized,
    403: .forbidden,
    404: .notFound,
    408: .requestTimeOut,
    409: .conflict,
    410: .gone,
    422: .unprocessable,
    426: .upgradeRequired,
    500: .internalError,
    502: .badGateway,
    503: .serviceUnavailable,
    504: .gatewayTimeOut,
    NSURLErrorCancelled: .canceled,
    NSURLErrorTimedOut: .clientTimeOut,
    NSURLErrorNotConnectedToInternet: .notConnected,
]

/// An interface defining a value that can be requested as a URL.
protocol Routable {
    /// The url used to construct an HTTP request
    var url: URL { get }
    /// A dictionary of key, values to append to the HTTP request headers. Authentication should be included.
    var extraHTTPHeaders: [String: String] { get }
}

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
enum HTTPMethod: String {
    case options, get, head, post, put, patch, delete, trace, connect
}

/// The HTTP response type. The type of this enum is defined by the HTTP Status code or NSURLError
///
/// - succeed:              The request was successfully executed and doesn't need further processing.
/// - badRequest:           The request failed because of a client error
/// - unauthorized:         The request failed because the user is not logged in.
/// - upgradeRequired:      The request failed because the app needs to be upgraded.
/// - forbidden:            The request failed because the user does not have appropriate persmissions.
/// - gone:                 The request failed because the resource is no longer available.
/// - canceled:             The request was canceled by the client.
/// - unprocessable:        The request failed because an error on the information we sent.
/// - notFound:             The request failed because the requested resource wasn't found on the server.
/// - unknownError:         The request failed with an unknown error that shouldn't be retried.
/// - clientTimeOut:        The request failed because there was no response before timeout
/// - notConnected:         The request failed because the user is not connected to the internet
/// - conflict:             The request failed due to a conflict in the request
/// - internalError:        The request failed due to an unexpected condition on the server
/// - badGateway:           The request failed because the server recieved an invalid response from upstream
/// - serviceUnavailable:   The request failed because the server is temporarily unavailable.
/// - requestTimeOut:       The request failed because the client did not produce a request within the time
///                         that the server was prepared to wait
/// - gatewayTimeOut:       The request failed because the server was acting as a gateway or proxy and did not
///                         recieve a response in time
public enum ResponseType {
    case succeed
    case badRequest, unauthorized, upgradeRequired, forbidden, gone
    case canceled, unprocessable, notFound, unknownError, clientTimeOut, notConnected
    case conflict, internalError, badGateway, serviceUnavailable, requestTimeOut, gatewayTimeOut

    /// The response type for a given HTTP code.
    ///
    /// - parameter code: The HTTP code.
    ///
    /// - returns: The response code meaning.
    init(fromCode code: Int) {
        if code >= 200 && code < 300 {
            self = .succeed
            return
        }

        self = kErrorMap[code] ?? .unknownError
    }
}

/// Manages request sessions
final class HTTPClient {

    private let session: URLSession

    /// Initializes a new instance of HTTPClient
    ///
    /// - parameter configuration: Configuration to be used in conjunction with the underlying URLSession
    ///
    /// - returns: New instance of HTTPClient.
    required init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.session = URLSession(configuration: configuration)
    }

    /// Creates and queue a network request for a given endpoint.
    ///
    /// The right hande side of the `Result` type created from this should probably be some sort of network
    /// error.
    ///
    /// - parameter method:      The HTTP method used in this request (POST, GET, PUT).
    /// - parameter route:       The API endPoint path. Example: /user/123/.
    /// - parameter parameters:  Are going to be sent to the server either as a JSON (post) or GET parameters.
    /// - parameter completion:  A closure that is called when the request is completed (either success or
    ///                          failure).
    func request(_ method: HTTPMethod, _ route: Routable, parameters: [String: Any]? = nil,
                 completion: @escaping (Any?, ResponseType) -> Void)
    {
        let request = self.urlRequest(method: method, route: route, parameters: parameters)
        let dataTask = self.session.dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            let status = ResponseType(fromCode: statusCode)

            let JSON = try? JSONSerialization.jsonObject(with: data ?? Data(), options: [])
            DispatchQueue.main.async {
                completion(JSON, status)
            }
        }

        dataTask.resume()
    }

    private func urlRequest(method: HTTPMethod, route: Routable,
                            parameters: [String: Any]? = nil) -> URLRequest
    {
        var request = URLRequest(url: route.url)
        request.httpMethod = method.rawValue

        for (key, value) in route.extraHTTPHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let info = Bundle(for: type(of: self)).infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        request.setValue("lyft-mobile-sdk:ios::\(version)", forHTTPHeaderField: "User-Agent")

        return lyftURLEncodedInURL(request: request, parameters: parameters).0
    }
}
