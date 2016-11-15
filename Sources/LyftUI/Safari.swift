import SafariServices

struct Safari {
    /// Opens a given URL in Safari or a Safari view controller based on the OS version.
    ///
    /// - parameter URL:            The URL to open (if it is nil, false is returned).
    /// - parameter viewController: The view controller to show open the URL from. This is used if a Safari
    ///                             view controller is displayed. If this view controller is nil, the URL will
    ///                             be opened in Safari.
    ///
    /// - returns: A boolean indicating success or failure of opening the URL.
    @discardableResult
    static func openURL(_ url: URL?, from viewController: UIViewController? = nil) -> Bool {
        guard let url = url else {
            return false
        }

        if #available(iOS 9, *), SFSafariViewController.canOpenURL(url), let viewController = viewController {
            let safariViewController = SFSafariViewController(url: url)
            viewController.present(safariViewController, animated: true, completion: nil)
            return true
        } else {
            return UIApplication.shared.openURL(url)
        }
    }
}

@available(iOS 9.0, *)
fileprivate extension SFSafariViewController {
    fileprivate class func canOpenURL(_ url: URL) -> Bool {
        return url.host != nil && (url.scheme == "http" || url.scheme == "https")
    }
}
