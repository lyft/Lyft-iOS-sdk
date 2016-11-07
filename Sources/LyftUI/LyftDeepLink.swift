import Foundation
import CoreLocation
import UIKit

/// Collection of deep links into the main Lyft application
public struct LyftDeepLink {
    /// Prepares to request a ride with the given parameters
    ///
    /// - parameter kind:                   The kind of ride to create a request for
    /// - parameter pickup:                 The pickup position of the ride
    /// - parameter destination:            The destination position of the ride
    /// - parameter couponCode              A coupon code to be applied to the user
    public static func requestRide(kind: RideKind,
                                   from pickup: CLLocationCoordinate2D? = nil,
                                   to destination: CLLocationCoordinate2D? = nil,
                                   couponCode: String? = nil)
    {
        var parameters = ["id": kind.rawValue]

        if let pickup = pickup {
            parameters["pickup[latitude]"] = String(pickup.latitude)
            parameters["pickup[longitude]"] = String(pickup.longitude)
        }

        if let destination = destination {
            parameters["destination[latitude]"] = String(destination.latitude)
            parameters["destination[longitude]"] = String(destination.longitude)
        }

        parameters["partner"] = LyftConfiguration.developer?.clientId
        parameters["credits"] = couponCode

        self.launch(action: "ridetype", parameters: parameters)
    }

    private static func launch(action: String, parameters: [String: String]?) {
        var requestURLComponents = URLComponents()
        requestURLComponents.scheme = "lyft"
        requestURLComponents.host = action
        requestURLComponents.queryItems = parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let url = requestURLComponents.url else {
            return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success {
                    self.launchAppStore()
                }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    @available(iOS 10.0, *)
    private static func launchAppStore() {
        let signUp = LyftConfiguration.signUpIdentifier
        let id = LyftConfiguration.developer?.clientId ?? "unknown"
        let infoDictionary = Bundle.lyftSDKBundle?.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "?.?.?"
        let url = "https://www.lyft.com/signup/\(signUp)?clientId=\(id)&sdkName=iOS&sdkVersion=\(version)"
        if let signUpUrl = URL(string: url) {
            UIApplication.shared.open(signUpUrl, options: [:], completionHandler: nil)
        }
    }
}
