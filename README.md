# Routing
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fn3d1117%2FRouting%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/n3d1117/Routing)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fn3d1117%2FRouting%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/n3d1117/Routing)

A type-safe, declarative routing system for SwiftUI applications. Supports both navigation stack (push) and modal (sheet, fullScreenCover) presentations, with optional deep linking and state restoration features.

## Features

- **Type-safe navigation** - Navigation destinations are defined as enum cases
- **Modal presentation** - Support for sheets and full-screen covers  
- **Deep linking** - Optional support for URL-based navigation
- **Universal links** - Built-in support for handling universal links (https:// URLs) alongside custom URL schemes, automatically routing users to specific app content when they tap links from web browsers, emails, or other apps
- **State restoration** - Optional persistence of navigation state across app launches

## Overview

The routing system consists of four main components:

1.  **`Routable`** - A protocol that defines a type that can be resolved into a destination view.
2.  **`AppRoute`** - A user-defined enum that conforms to `Routable` and defines all possible navigation destinations.
3.  **`Router`** - A property wrapper that manages navigation state and provides navigation methods.
4.  **`View.withRouter()`** - A view modifier for injecting the router into the SwiftUI environment.

## Usage

### 1. Define Routes

First, define your app's routes by creating a type that conforms to the `Routable` protocol. It must be `Hashable` and `Identifiable`, and provide a `destination` view.

```swift
enum AppRoute: Routable {
    case about
    case settings(user: String)
    
    var id: String {
        switch self {
        case .about: return "about"
        case .settings: return "settings"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .about:
            AboutView()
        case .settings(let user):
            SettingsView(user: user)
        }
    }
}
```

### 2. Add Router to Environment

Create an environment entry for your router:

```swift
// Define a key for the environment
extension EnvironmentValues {
    @Entry var router: Router<AppRoute> = Router()
}
```

### 3. Apply Router to Root View

Apply the router modifier to your root content view:

```swift
struct ContentView: View {
    var body: some View {
        HomeView()
            .withRouter(\.router)
    }
}
```

## Usage

### Accessing the Router

In any view within the routing hierarchy (pushed or modal), access the router through the environment:

```swift
@Environment(\.router) private var router
```

### Navigation Stack

Use the following methods to control the navigation stack:

```swift
// Push a new view
router.navigate(to: .about)

// Pop the top-most view
router.goBack()

// Pop all views to return to the root
router.popToRoot()
```

### Modal Presentation

Use `present(_:style:onDismiss:)` to present a view modally and `dismiss()` to close it.

```swift
// Present a sheet
router.present(.settings(user: "User"))

// Present a full screen cover with an onDismiss closure
router.present(.settings(user: "User"), style: .fullScreenCover) {
    print("Full screen cover dismissed!")
}
```

### Advanced Usage: Multiple Routers

For large applications with multiple independent navigation flows (e.g., a `TabView`), the library supports creating distinct routers for each feature. This is achieved by defining a unique `Routable` type and environment `keyPath` for each flow. The specific router is then applied to the root view of that feature, ensuring navigation states are completely isolated.

```swift
// 1. Define routers for each feature
extension EnvironmentValues {
    @Entry var homeRouter: Router<HomeRoute> = Router()
    @Entry var searchRouter: Router<SearchRoute> = Router()
}

// 2. Apply to each tab's root view
TabView {
    HomeView()
        .withRouter(\.homeRouter)
        .tabItem { ... }

    SearchView()
        .withRouter(\.searchRouter)
        .tabItem { ... }
}

// 3. Use the specific router within a feature
@Environment(\.homeRouter) private var homeRouter
@Environment(\.searchRouter) private var homeRouter
```


## Configuration Options

The `withRouter` modifier accepts an array of `RouterFeature` enums to enable optional features:

- **`.deepLinking(_ handler: DeepLinkHandler, includeUniversalLinks: Bool = false, universalLinkHandler: DeepLinkHandler? = nil)`** - Enables custom deep link handling with optional universal links support.
- **`.stateRestoration(key: String)`** - Enables state restoration, allowing the navigation state to be persisted and restored across app launches. The `key` is used to identify the saved state in `SceneStorage`.

### Deep Linking

To enable deep linking, first register your custom URL scheme in your app's `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourapp.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myscheme</string>
        </array>
    </dict>
</array>
```

Then implement the `DeepLinkHandler` protocol:

```swift
struct MyDeepLinkHandler: DeepLinkHandler {
    func handle(_ url: URL) -> [AppRoute]? {
        guard url.scheme == "myscheme" else { return nil }
        // your logic to convert `myscheme://` URLs into app routes
    }
}
```

And then use it:

```swift
struct ContentView: View {
    var body: some View {
        HomeView()
            .withRouter(\.router, features: [.deepLinking(MyDeepLinkHandler())])
    }
}
```

For more details on URL schemes, see [Apple's documentation](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app).

### Universal Links

Universal links enable your app to respond to HTTPS URLs (web links) in addition to custom URL schemes. When enabled, your app can handle links like `https://myapp.com/profile` alongside custom schemes like `myapp://profile`.

First, configure universal links by adding an associated domain to your app's entitlements and hosting an `apple-app-site-association` file on your server. See [Apple's Universal Links documentation](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app) for setup details.

Then, to enable universal links, set `includeUniversalLinks: true` in your deep linking configuration:

```swift
struct ContentView: View {
    var body: some View {
        HomeView()
            .withRouter(\.router, features: [
                .deepLinking(
                    MyDeepLinkHandler(), 
                    includeUniversalLinks: true
                )
            ])
    }
}
```

By default, universal links are handled with the same deep link handler defined above. For custom behavior, you can optionally provide a _separate_ handler specifically for universal links:

```swift
struct UniversalLinkHandler: DeepLinkHandler {
    func handle(_ url: URL) -> [AppRoute]? {
        guard url.scheme == "https", url.host == "myapp.com" else { return nil }
        // Parse path components and return routes
    }
}

struct ContentView: View {
    var body: some View {
        HomeView()
            .withRouter(\.router, features: [
                .deepLinking(
                    MyDeepLinkHandler(),
                    includeUniversalLinks: true,
                    universalLinkHandler: UniversalLinkHandler()
                )
            ])
    }
}
```

### State Restoration

For state restoration, your `Routable` enum must also conform to `Codable`. Navigation state will be automatically saved and restored across app launches using `SceneStorage`:

```swift
enum AppRoute: Routable, Codable {
    case home, profile(userId: String), settings
    
    // ... implementation
}

// Enable state restoration
.withRouter(\.router, features: [.stateRestoration(key: "main_nav")])
```

The navigation state is persisted using `SceneStorage` and automatically restored when the app relaunches. Note that modal sheets are _not_ restored.

## Example Project

See the included `RoutingDemo` project for a complete example showing:
- Basic navigation
- Modal presentation  
- Deep linking
- State restoration
- Multiple independent routers in a TabView
