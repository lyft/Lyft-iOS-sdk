import Foundation

/// Generic error struct. It contains the message returned by the server and the reason for the error. When
/// `isUnprocessable` == false it means that the server returned an status code other than 422.
public struct LyftAPIError: Error {
    /// The human readable error message from the server
    public let message: String?
    /// The error reason from the server
    public let reason: String
    /// The response status from the server
    public let status: ResponseType?

    /// Generic unknown error
    static let UnknownError = LyftAPIError("unknown")

    /// Initialize a new instance of LyftAPIError.
    ///
    /// - parameter reason:     The error reason from the server
    /// - parameter message:    The error message from the server
    ///
    /// - returns: New instance of LyftAPIError.
    init(_ reason: String, message: String? = nil) {
        self.reason = reason
        self.message = message
        self.status = nil
    }

    /// Parses the error type from the server response and returns the instance that represents the first
    /// error.
    ///
    /// - parameter response:           The NSDictionary created from a JSON response.
    /// - parameter status:             The type defined by the status code (see the ResponseType enum for
    ///
    /// - returns: The newly created LyftAPIError instance representing the first error found.
    init?(response: NSDictionary?, status: ResponseType) {
        self.status = status

        if status == .succeed {
            return nil
        }

        self.reason = response?["error"] as? String ?? LyftAPIError.UnknownError.reason
        self.message = response?["error_description"] as? String
    }
}
