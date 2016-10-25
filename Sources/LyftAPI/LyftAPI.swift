import CoreLocation

private let kRequestTimeout = 20.0

/// Main abstraction for requests to the LyftAPI
public struct LyftAPI {
    /// This is the client in charge of handling all network operations.
    static let client: HTTPClient = {
        var configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = kRequestTimeout

        return HTTPClient(configuration: configuration)
    }()
}

extension LyftAPI {

    /// Get the ETA estimates from a specific position by ride kind.
    ///
    /// - parameter position:   The pickup position to get ETAs to.
    /// - parameter completion: A completion block that is called with either the ETAs or an error.
    public static func ETAs(to position: CLLocationCoordinate2D,
                            completion: @escaping (Result<[ETA], LyftAPIError>) -> Void)
    {
        let parameters = [
            "lat": position.latitude,
            "lng": position.longitude,
        ]

        self.client.request(.get, APIRoute.eta, parameters: parameters) { responseObject, status in
            let response = responseObject as? NSDictionary
            let error = LyftAPIError(response: response, status: status) ?? .UnknownError
            let estimates = [ETA](json: response?["eta_estimates"])
            completion(Result(value: estimates, failWith: error))
        }
    }

    /// Get the ride types for the current position.
    ///
    /// - parameter position:   The position where to get the ride types for.
    /// - parameter completion: A completion block called with the ride types at the position, or an error.
    public static func rideTypes(at position: CLLocationCoordinate2D,
                                 completion: @escaping (Result<[RideType], LyftAPIError>) -> Void)
    {
        let parameters = [
            "lat": position.latitude,
            "lng": position.longitude,
        ]

        self.client.request(.get, APIRoute.rideTypes, parameters: parameters) { responseObject, status in
            let response = responseObject as? NSDictionary
            let error = LyftAPIError(response: response, status: status) ?? .UnknownError
            let rideTypes = [RideType](json: response?["ride_types"])
            completion(Result(value: rideTypes, failWith: error))
        }
    }

    /// Get the cost estimates for a specific route.
    ///
    /// - parameter from:       The pickup position of the ride request.
    /// - parameter to:         The destination position of the ride request. If nil, the cost estimates
    ///                         will only include the prime time for the from position.
    /// - parameter rideKind:   The ride kind to retrieve information for, or nil for all ride kinds.
    /// - parameter completion: A closure to be called on completion (either on error or success).
    public static func costEstimates(from pickup: CLLocationCoordinate2D,
                                     to destination: CLLocationCoordinate2D? = nil, rideKind: RideKind? = nil,
                                     completion: @escaping (Result<[Cost], LyftAPIError>) -> Void)
    {
        var parameters: [String: Any] = [
            "start_lat": pickup.latitude,
            "start_lng": pickup.longitude,
        ]
        parameters["end_lat"] = destination?.latitude
        parameters["end_lng"] = destination?.longitude
        parameters["ride_type"] = rideKind?.rawValue

        self.client.request(.get, APIRoute.costEstimates, parameters: parameters) { responseObject, status in
            let response = responseObject as? NSDictionary
            let error = LyftAPIError(response: response, status: status) ?? .UnknownError
            let estimates = [Cost](json: response?["cost_estimates"])
            completion(Result(value: estimates, failWith: error))
        }
    }

    /// Get the nearby drivers around a specific position.
    ///
    /// - parameter position:   The position to fetch drivers around.
    /// - parameter completion: A completion block called with the nearby drivers, or an error.
    public static func drivers(near position: CLLocationCoordinate2D,
                               completion: @escaping (Result<NearbyDrivers, LyftAPIError>) -> Void)
    {
        let parameters = [
            "lat": position.latitude,
            "lng": position.longitude,
        ]

        self.client.request(.get, APIRoute.nearbyDrivers, parameters: parameters) { responseObject, status in
            let response = responseObject as? NSDictionary
            let error = LyftAPIError(response: response, status: status) ?? .UnknownError
            completion(Result(value: NearbyDrivers(json: response), failWith: error))
        }
    }
}
