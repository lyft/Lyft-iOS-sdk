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
            return URL(string: "lyft://ridetype")
            
        case .web:
            return URL(string: "https://ride.lyft.com/u")
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
        var parameters = [String: Any]()
        parameters["partner"] = LyftConfiguration.developer?.clientId
        parameters["credits"] = couponCode
        parameters["id"] = kind.rawValue
        parameters["pickup[latitude]"] = pickup.map { $0.latitude }
        parameters["pickup[longitude]"] = pickup.map { $0.longitude }
        parameters["destination[latitude]"] = destination.map { $0.latitude }
        parameters["destination[longitude]"] = destination.map { $0.longitude }
        
        self.launch(using: behavior, parameters: parameters)
    }
    
    private static func launch(using behavior: LyftDeepLinkBehavior, parameters: [String: Any])
    {
        let request = lyftURLEncodedInURL(request: URLRequest(url: behavior.baseUrl!), parameters: parameters).0
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
