import Foundation

/// Represents an object that can be created from a json object
protocol JSONMappable {

    /// Creates an instance from a dictionary
    ///
    /// - parameter json:   A NSDictionary of key object pairs originating from JSON
    ///
    /// - returns:  An instance of this object if one can be created, or nil otherwise
    init?(json: NSDictionary)

    /// Creates an instance from an untyped json object
    ///
    /// - parameter json:   The untyped json object to initialize this object with
    ///
    /// - returns:  An instance of this object if one can be created, or nil otherwise
    init?(json: Any?)
}

extension JSONMappable {
    init?(json: Any?) {
        if let json = json as? NSDictionary {
            self.init(json: json)
        } else {
            return nil
        }
    }
}

extension Array where Element: JSONMappable {

    /// Convenience initializer for creating an array of mappable items
    ///
    /// - parameter json:   The json object representing the array of mappable items
    ///
    /// - returns:  An array of mapped items if one can be created, or nil otherwise
    init?(json: Any?) {
        if let json = json as? [NSDictionary], json.count > 0 {
            self = json.flatMap { Element(json: $0) }
        } else {
            return nil
        }
    }
}
