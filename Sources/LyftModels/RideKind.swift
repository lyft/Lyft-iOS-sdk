/// A kind of ride offered by the Lyft platform in a given area. May include special promotional ride types.
public struct RideKind: RawRepresentable, Hashable {
    /// The string value of the actual ride kind. For example "lyft_line".
    public var rawValue: String

    private init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Convenience initializer for creating a RideKind from server responses
    ///
    /// - parameter object: An untyped object likely from a json server response
    ///
    /// - returns:  A RideKind if one can be created, or nil
    init?(object: Any?) {
        if let rawValue = object as? String {
            self = RideKind(rawValue: rawValue)
        } else {
            return nil
        }
    }

    // MARK: - Hashable conformance

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue.hashValue)
    }

    // MARK: - Ride Kinds

    /// Standard lyft ride kind
    public static let Standard = RideKind("lyft")
    /// Lyft Line ride kind
    public static let Line = RideKind("lyft_line")
    /// Lyft plus ride kind
    public static let Plus = RideKind("lyft_plus")
    /// Lux ride kind
    public static let Lux = RideKind("lyft_premier")
    /// Lux Black ride kind
    public static let LuxBlack = RideKind("lyft_lux")
    /// Lux Black XL ride kind
    public static let LuxBlackXL = RideKind("lyft_luxsuv")
}
