import Foundation

private func components(forKey key: String, value: Any) -> [URLQueryItem] {
    switch value {
        case let array as [Any]:
            return array.map { URLQueryItem(name: key, value: String(describing: $0)) }

        default:
            return [URLQueryItem(name: key, value: String(describing: value))]
    }
}

/// Encodes given parameters on the request URL by URL-encoding the values and keys. Arrays are supported in
/// the form of `foo=bar&foo=baz`.
///
/// - parameter request:    The request to have parameters applied.
/// - parameter parameters: The parameters to apply.
///
/// - returns: A tuple containing the constructed request and the error that occurred during parameter
///            encoding, if any.
func lyftURLEncodedInURL(request: URLRequest, parameters: [String: Any]?) -> (URLRequest, NSError?) {
    guard let parameters = parameters else {
        return (request, nil)
    }

    var mutableURLRequest = request
    let queryItems = parameters
        .sorted { $0.0 < $1.0 }
        .flatMap { components(forKey: $0, value: $1) }

    var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = (urlComponents?.queryItems ?? []) + queryItems
    mutableURLRequest.url = urlComponents?.url
    return (mutableURLRequest, nil)
}
