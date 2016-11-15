# Lyft iOS SDK

The Official Lyft iOS SDK makes it easy to integrate Lyft into your app. More specifically, it provides:
- An easily configurable Lyft button which can display cost, ETA, and ride type. Tapping the button deeplinks into the Lyft app with pre-filled pickup/destination/ridetype.
- A swift interface for making async calls to Lyft's REST APIs
- A sample iOS project that shows how to use the SDK components.

## Registration
- You must first create a Lyft Developer account [here](https://www.lyft.com/developers).
- Once registered, you will be assigned a Client ID and will be able to generate Client Tokens.

## Installation

> **Embedded frameworks require a minimum deployment target of iOS 8 or OS
> X Mavericks (10.9).**

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build LyftSDK.

To integrate LyftSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pod 'LyftSDK'
```

Then, run the following command:

```bash
$ pod install
```

#### Installing without iOS specific UI elements

```ruby
pod 'LyftSDK/API'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa. To import this SDK, add this to your Cartfile:

```
github "lyft/Lyft-iOS-sdk"
```

### Integrate without dependency manager

Drag the LyftSDK.xcodeproj project into your project's Project Navigator. In your project's Build Target, click on the General tab and then under Embedded Binaries click the + button. Select the LyftSDK.framework under your project.

## Usage

### SDK Configuration
In your app, before using LyftSDK, be sure to configure your [developer information](https://www.lyft.com/developers) using `LyftConfiguration`. This is preferably done in your `UIApplicationDelegate`'s `application:didFinishLaunchingWithOptions`' as follows:
```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
	LyftConfiguration.developer = (token: "...", clientId: "...")
	// Complete other setup
	return true
}
```

### Lyft Button
Adding the Lyft Button to a Storyboard or xib is as easy adding a new UIView to your superview and setting the class to `LyftButton` in the Identity Inspector tab. We recommend setting the width to 260p and the height to 50p. Please keep in mind that a smaller width/height may result in undesirable UI, such as cut off text.

![ib-setup](https://cloud.githubusercontent.com/assets/687769/19176092/5ee5c112-8bf1-11e6-8aa1-ecd6a9ce7189.png)

To create the button programatically with its preferred size, simply call `let lyftButton = LyftButton()`

#### Load ETA/cost
```swift
let pickup = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
let destination = CLLocationCoordinate2D(latitude: 37.7794703, longitude: -122.4233223)
lyftButton.configure(pickup: pickup, destination: destination)
```

#### Ride types
Lyft is growing very quickly and is currently available in [these cities](https://www.lyft.com/cities). Please keep in mind that some ride types (such as Lyft Line) are not yet available in all Lyft cities. If you set the ride type of the button  and it happens to be unavailable, the button will default to the Lyft Classic ride type. You can utilize the `LyftAPI.rideTypes(at:completion:)` wrapper to get a list of the available ride types in an area.

#### Deep link behavior
When a user taps on the Lyft Button, the default behavior is to deep link into the native Lyft app with the configuration information you have provided.

However, if you would like to create a ride request on Lyft using Lyft's mobile web experience, you can specify the button's `deepLinkBehavior` as follows:
```swift
lyftButton.deepLinkBehavior = .web
```

This is preferable if you do not want the user to leave your app when making a ride request. Also, it does not require the user has Lyft installed.

#### Button styles
To specify the button style, use `enum LyftButtonStyle`
```swift
lyftButton.style = .MulberryDark
```

There are 5 styles to pick from:

![lyft-styles](https://cloud.githubusercontent.com/assets/13209348/17683300/88f86446-6306-11e6-81e6-bc42fc77650e.png)

### Lyft API Wrapper

The SDK provides wrapper methods around Lyft's REST APIs - this can be helpful when you want to build a more custom integration with the Lyft platform vs making HTTP requests directly.
```swift
let pickup = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
LyftAPI.ETAs(to: pickup) { result in
    result.value?.forEach { eta in
        print("ETA for \(eta.rideKind): \(eta.minutes) min")
    }
}
```

### Deeplinking
The SDK provides direct [deeplinking](https://developer.lyft.com/docs/deeplinking) to the Lyft app for those developers who prefer to handle their own custom deeplinking vs relying on the Lyft Button. 
```swift
let pickup = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
let destination = CLLocationCoordinate2D(latitude: 37.7794703, longitude: -122.4233223)
LyftDeepLink.requestRide(kind: .Standard, from: pickup, to: destination)
```

Note that you can specify a LyftDeepLinkBehavior in this request, to decide between deep linking to the native lyft app or launching Lyft's mobile web experience within your own app.

## Support

If you're looking for help configuring or using the SDK, or if you have general questions related to our APIs, the Lyft Developer Platform team provides support through our [forum](https://developer.lyft.com/discuss) as well as on Stack Overflow (using the `lyft-api` tag)

## Reporting security vulnerabilities

If you've found a vulnerability or a potential vulnerability in the Lyft iOS SDK,
please let us know at security@lyft.com. We'll send a confirmation email to
acknowledge your report, and we'll send an additional email when we've
identified the issue positively or negatively.
