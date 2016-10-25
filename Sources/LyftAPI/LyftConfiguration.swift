import Foundation

/// Lyft SDK configuration
public struct LyftConfiguration {
    /// Represents the current developer using the LyftSDK. Must be set before any API calls can be made
    public static var developer: (token: String, clientId: String)?
    /// Customizable for specific partners. Do not modify unless explicitly instructed to do so.
    public static var signUpIdentifier: String = "SDKSIGNUP"
}
