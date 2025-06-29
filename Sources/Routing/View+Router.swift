//
//  View+Router.swift
//  Routing
//
//  Created by ned on 25/06/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Unified view modifier that adds router functionality with optional deep linking and state restoration.
struct RouterModifier<Route: Routable>: ViewModifier {
    @Router private var router: [Route]

    private let keyPath: WritableKeyPath<EnvironmentValues, Router<Route>>
    private let configuration: RouterConfiguration

    init(
        keyPath: WritableKeyPath<EnvironmentValues, Router<Route>>,
        configuration: RouterConfiguration
    ) {
        self.keyPath = keyPath
        self.configuration = configuration
    }

    func body(content: Content) -> some View {
        RouterView<Route, Content>(
            router: _router,
            content: content,
            keyPath: keyPath,
            configuration: configuration
        )
    }
}

struct RouterView<Route: Routable, Content: View>: View {
    let router: Router<Route>
    let content: Content
    let keyPath: WritableKeyPath<EnvironmentValues, Router<Route>>
    let configuration: RouterConfiguration

    @SceneStorage private var restorationData: Data?

    init(
        router: Router<Route>,
        content: Content,
        keyPath: WritableKeyPath<EnvironmentValues, Router<Route>>,
        configuration: RouterConfiguration
    ) {
        self.router = router
        self.content = content
        self.keyPath = keyPath
        self.configuration = configuration

        // Initialize SceneStorage with the key if state restoration is enabled
        if let stateConfig = configuration.stateRestoration {
            _restorationData = SceneStorage(stateConfig.sceneStorageKey)
        } else {
            _restorationData = SceneStorage("no_restoration")
        }
    }

    var body: some View {
        RoutingView(
            path: router.projectedValue,
            presentedItem: router.presentedItemBinding,
            presentationStyle: router.presentationStyle,
            onDismiss: router.onDismiss,
            routerKeyPath: keyPath
        ) {
            content
        }
        .environment(keyPath, router)
        .onOpenURL { url in
            handleDeepLink(url)
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            if let url = userActivity.webpageURL {
                handleUniversalLink(url)
            }
        }
        .task {
            restoreStateIfNeeded()
        }
        .onChange(of: router.path) {
            saveCurrentState()
        }
    }

    // MARK: - Deep Linking and Universal Linking
    
    private func handleDeepLink(_ url: URL) {
        guard let deepLinkConfig = configuration.deepLinking else { return }

        RoutingLogger.deepLinking.debug("Processing URL: \(url.absoluteString)")

        if let handler = deepLinkConfig.handler as? any DeepLinkHandler<Route> {
            router.handleDeepLink(url, handler: handler)
        }
    }

    private func handleUniversalLink(_ url: URL) {
        guard let deepLinkConfig = configuration.deepLinking, deepLinkConfig.includeUniversalLinks else { return }

        RoutingLogger.deepLinking.debug("Processing universal link: \(url.absoluteString)")

        // Use custom universal link handler if provided, otherwise fall back to deep link handler
        let handlerToUse = deepLinkConfig.universalLinkHandler ?? deepLinkConfig.handler

        if let handler = handlerToUse as? any DeepLinkHandler<Route> {
            router.handleDeepLink(url, handler: handler)
        }
    }

    // MARK: - State Restoration
    
    private func restoreStateIfNeeded() {
        guard let _ = configuration.stateRestoration,
              let restorationData,
              let codableRouter = router as? any RouterCoreWithCodableDestination else {
            return
        }
        codableRouter.restore(from: restorationData)
    }

    private func saveCurrentState() {
        guard let _ = configuration.stateRestoration,
              let codableRouter = router as? any RouterCoreWithCodableDestination,
              let data = codableRouter.encoded() else {
            return
        }
        restorationData = data
    }
}

// MARK: - Public View Extensions

public extension View {
    /// Adds router functionality with optional deep linking and state restoration
    func withRouter<Route: Routable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Router<Route>>,
        features: [RouterFeature] = []
    ) -> some View {
        let configuration = RouterConfiguration(features: features)
        return modifier(RouterModifier<Route>(keyPath: keyPath, configuration: configuration))
    }
}
