# TradeIt iOS Ad SDK

A library that provides tools for adding ads to your iOS apps using the TradeIt platform.

## Installation

### Git Submodule

1. In the root of the project run `git submodule add git@github.com:tradingticket/TradeItIosAdSdk.git`
1. Right click your project in xcode
1. Click `Add files to...`
1. Add `TradeItIosAdSdk.xcodeproj` from the submodule
1. Click your project in the xcode project browser
1. On the General tab, under Embedded Binaries add `TradeItIosAdSdk.framework`

This is the preferred method of including the SDK in your project until the Cocoapods release.

### Cocoapods

Coming soon

## Global Configuration

### Swift

1. Add `import TradeItIosAdSdk` to your imports
1. Set the API key with `TradeItAdConfig.apiKey = ""` when your application loads, before any ads are displayed. Your AppDelegate's `appDidFinishLaunching` is the recommended place.
1. Set the environment with `TradeItAdConfig.environment = .QA` while in development and then switch to `.Prod` for release

### Objective-C

1. Add `#import <TradeItIosAdSdk/TradeItIosAdSdk-Swift.h>` to your imports
1. Set the API key with `TradeItAdConfig.apiKey = "";` when your application loads, before any ads are displayed. Your AppDelegate's `appDidFinishLaunching` is the recommended place.
1. Set the environment with `TradeItAdConfig.environment = TradeItEnvironmentQA;` while in development and then switch to `TradeItEnvironmentProd` for release

## Adding the view

1. Add a `UIView` to the view where the ad should appear
1. Set the `UIView` to be of class `TradeItAdView` and module `TradeItAdSdk` on the `Identity Inspector`
1. Add `Trailing` and `Leading` constraints to the new view
1. Set the constant to `0` for both constraints
1. Remove `Relative to Margin` for both constraints so that it stretches the entire width of the device
1. Add a `Height` constraint to the new view
1. Set the constant to `50` for the height constraint
1. Create `IBOutlet`s for both the `adView` and `adViewHeightConstraint`

## User Account Configuration

If the user is logged in, you must pass the User information to `TradeItAdConfig` so that tracking works correctly.

```swift
TradeItAdConfig.users = [
  [ "userId": "account-1", "userToken": "token-account-1" ],
  [ "userId": "account-2", "userToken": "token-account-2" ]
]
```

If you are integrated with the current Objective-C [TradeIt Trading Ticket mobile SDK](https://github.com/tradingticket/TradeItIosTicketSDK), you can generate this using the following snippet.

```objc
TradeItConnector * connector = [[TradeItConnector alloc] initWithApiKey:TradeItAdConfig.apiKey];
NSArray *linkedLogins = [connector getLinkedLogins];

NSMutableArray *users = [[NSMutableArray alloc] init];
for (TradeItLinkedLogin *linkedLogin in linkedLogins) {
  NSString *userToken = [connector userTokenFromKeychainId:linkedLogin.keychainId];
  NSDictionary *user = @{ @"userId": linkedLogin.userId, @"userToken": userToken };
  [users addObject:user];
}
TradeItAdConfig.users = users;
```

## View Configuration

There are helpers for configuring the view. Only the Ad Type is required.

```swift
// Ad Type
adView.configureWithAdType("general")

// Ad Type and Broker
adView.configureWithAdType("general", broker: "Dummy")

// Ad Type and Height Constraint
adView.configureWithAdType("general", heightConstraint: adViewHeightConstraint)

// Ad Type, Broker and Height Constraint
adView.configureWithAdType("general", broker: "Dummy", heightConstraint: adViewHeightConstraint)
```

##### Ad Types

AdType | Description
--- | ---
`account` | An ad to display when the user is linking, editing or removing a broker.
`portfolio` | An ad to display when user is viewing positions, balances, order status or transactions.
`ticket` | An ad to display while the user is entering an order on the Trading Ticket.
`tradeConfirmation` | An ad placed when a trade has been successfully placed.
`general` | A short ad to display anywhere else within your app (i.e, home screen, quote screen, news screen).

##### Broker
Provide the `broker` if the user is interacting with a particular broker.
This allows ads to be targetted to the broker.
For example, if a user is on their Fidelity portfolio screen then pass the parameter "Fidelity".

##### Height Constraint
Provide the `heightConstraint` so that the view height can be adjusted.
If the ad is a different size to the size you have set up, it will be adjusted to fit the ad content.
If ads are disabled or the request to the ad server fail the ad view collapses to 0 height.

## Example App

The SDK includes an example Swift app target. To run, switch to the `Example App` target and click run.

## Debugging Configuration

##### `TradeItAdConfig.environment`

*Default*: `TradeItAdEnvironment.Prod`

Determines which TradeIt environment to hit. This can be set to `.Prod` or `.QA`.

##### `TradeItAdConfig.debug`

*Default*: `false`

If `true` it will log debugging information about the ad requests and device querying to the xcode console.

##### `TradeItAdConfig.enabled`

*Default*: `true`

If `false` it will hide the ad views.

## License
MIT License

Copyright (c) 2016 Trading Ticket Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
