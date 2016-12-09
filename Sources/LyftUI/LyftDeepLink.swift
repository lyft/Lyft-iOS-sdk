import Foundation
import CoreLocation
import UIKit

/// Designates the kind of deeplinking to perform
///
/// - native:   Launches the native Lyft app if available
/// - web:      Launches a safari view controller without leaving the app, enabling ride request function
public enum LyftDeepLinkBehavior {
    case native
    case web

    fileprivate var baseUrl: URL? {
        switch self {
            case .native:
                return URL(string: "lyft://")

            case .web:
                return URL(string: "https://ride.lyft.com/")
        }
    }
}

/// Collection of deep links into the main Lyft application
public struct LyftDeepLink {

    /// Prepares to request a ride with the given parameters
    ///
    /// - parameter behavior:       The deep linking mode to use for this deep link
    /// - parameter kind:           The kind of ride to create a request for
    /// - parameter pickup:         The pickup position of the ride
    /// - parameter destination:    The destination position of the ride
    /// - parameter couponCode:     A coupon code to be applied to the user
    public static func requestRide(using behavior: LyftDeepLinkBehavior = .native, kind: RideKind = .Standard,
                                   from pickup: CLLocationCoordinate2D? = nil,
                                   to destination: CLLocationCoordinate2D? = nil,
                                   couponCode: String? = nil)
    {
        let action: String
        var parameters = [String: Any]()
        parameters["partner"] = LyftConfiguration.developer?.clientId
        parameters["credits"] = couponCode

        switch behavior {
            case .native:
                action = "ridetype"
                parameters["id"] = kind.rawValue
                parameters["pickup[latitude]"] = pickup.map { $0.latitude }
                parameters["pickup[longitude]"] = pickup.map { $0.longitude }
                parameters["destination[latitude]"] = destination.map { $0.latitude }
                parameters["destination[longitude]"] = destination.map { $0.longitude }

            case .web:
                action = "request"
                parameters["ride_type"] = kind.rawValue
                parameters["pickup"] = pickup.map { "@\($0.latitude),\($0.longitude)" }
                parameters["destination"] = destination.map { "@\($0.latitude),\($0.longitude)" }
        }

        self.launch(using: behavior, action: action, parameters: parameters)
    }

    private static func launch(using behavior: LyftDeepLinkBehavior, action: String,
                               parameters: [String: Any])
    {
        guard let originalUrl = behavior.baseUrl.flatMap({ URL(string: action, relativeTo: $0) }) else {
            return
        }

        let request = lyftURLEncodedInURL(request: URLRequest(url: originalUrl), parameters: parameters).0
        guard let url = request.url else {
            return
        }

        switch behavior {
            case .native:
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:]) { success in
                        if !success {
                            self.launchAppStore()
                        }
                    }
                } else {
                    UIApplication.shared.openURL(url)
                }

            case .web:
                Safari.openURL(url, from: UIApplication.shared.topViewController)
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

fileprivate extension UIApplication {
    fileprivate var topViewController: UIViewController? {
        var topController = self.keyWindow?.rootViewController
        while let viewController = topController?.presentedViewController {
            topController = viewController
        }

        return topController
    }
}
