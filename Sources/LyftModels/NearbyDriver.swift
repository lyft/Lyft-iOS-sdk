import CoreLocation

/// Locations of drivers near a location by ride type
public struct NearbyDrivers {
    /// Nearby drivers organized by ride kind
    let driversByKind: [RideKind: [NearbyDriver]]

    /// Subscript returns the nearby cars for a given ride kind
    ///
    /// - parameter kind:   The ride kind to get the nearby cars for
    ///
    /// - returns:  The cars nearby a position for a give ride kind
    public subscript(kind: RideKind) -> [NearbyDriver]? {
        return self.driversByKind[kind]
    }
}

extension NearbyDrivers: JSONMappable {
    init?(json: NSDictionary) {
        guard let objects = json["nearby_drivers"] as? [NSDictionary] else {
            return nil
        }

        var dictionary = [RideKind: [NearbyDriver]]()
        for object in objects {
            if let kind = RideKind(object: object["ride_type"]),
                let cars = [NearbyDriver](json: object["drivers"])
            {
                dictionary[kind] = cars
            } else {
                return nil
            }
        }

        self.driversByKind = dictionary
    }
}

/// Representation of a driver nearby a position
public struct NearbyDriver {
    /// The positions of a driver in ascending order
    public let recentPositions: [CLLocationCoordinate2D]
    /// The most recent position of the driver
    public var position: CLLocationCoordinate2D? { return self.recentPositions.last }
}

extension NearbyDriver: JSONMappable {
    init?(json: NSDictionary) {
        if let locations = [CLLocationCoordinate2D](json: json["locations"]) {
            self.recentPositions = locations
        } else {
            return nil
        }
    }
}
