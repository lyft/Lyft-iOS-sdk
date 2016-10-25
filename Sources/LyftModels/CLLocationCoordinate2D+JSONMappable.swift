import CoreLocation

extension CLLocationCoordinate2D: JSONMappable {

    init?(json: NSDictionary) {
        guard let latitude = json["lat"] as? Double, let longitude = json["lng"] as? Double else {
            return nil
        }

        self = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
