/// A slightly more restrictive implementation of the Either monad. Result has 2 possible outcomes, either a
/// value `T` or an error `U`. They can be accessed using a `switch` statement with the `Success` or `Failure`
/// cases, or through the convenience properties to make them optional. You should use a `switch` statement
/// unless you only care about a single case.
public enum Result<T, U: Error> {
    case success(T)
    case failure(U)

    /// The value if the result is a `Success`, otherwise nil
    public var value: T? {
        switch self {
            case .success(let value):
                return value
            case .failure(_):
                return nil
        }
    }

    /// The error if the value is a `Failure`, otherwise nil
    public var error: U? {
        switch self {
            case .success(_):
                return nil
            case .failure(let error):
                return error
        }
    }

    /// Create a successful result case with the given value.
    ///
    /// - parameter value: The value to store.
    public init(value: T) {
        self = .success(value)
    }

    /// Create a failed result with the given error.
    ///
    /// - parameter error: The error to store with the failure case.
    public init(error: U) {
        self = .failure(error)
    }

    /// Create a result with the possible value, or error.
    ///
    /// - parameter value: The value to use with the successful case if it exists.
    /// - parameter error: The error closure to use as the failure case if the value doesn't exist.
    public init(value: T?, failWith error: @autoclosure () -> U) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error())
        }
    }
}
