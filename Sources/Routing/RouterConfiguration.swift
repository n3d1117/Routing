//
//  RouterConfiguration.swift
//  Routing
//
//  Created by ned on 02/07/25.
//

import Foundation

public enum RouterFeature {
    case deepLinking(
        _ handler: any DeepLinkHandler,
        includeUniversalLinks: Bool = false,
        universalLinkHandler: (any DeepLinkHandler)? = nil
    )
    case stateRestoration(key: String)
}

/// Configuration options for the router
public struct RouterConfiguration {
    let deepLinking: DeepLinkingConfiguration?
    let stateRestoration: StateRestorationConfiguration?

    init(features: [RouterFeature]) {
        var deepLinkingConfig: DeepLinkingConfiguration?
        var stateRestorationConfig: StateRestorationConfiguration?

        for feature in features {
            switch feature {
            case let .deepLinking(handler, includeUniversalLinks, universalLinkHandler):
                deepLinkingConfig = DeepLinkingConfiguration(
                    handler: handler,
                    includeUniversalLinks: includeUniversalLinks,
                    universalLinkHandler: universalLinkHandler
                )
            case let .stateRestoration(key):
                stateRestorationConfig = StateRestorationConfiguration(
                    sceneStorageKey: key
                )
            }
        }

        deepLinking = deepLinkingConfig
        stateRestoration = stateRestorationConfig
    }
}

public struct DeepLinkingConfiguration {
    let handler: any DeepLinkHandler
    let includeUniversalLinks: Bool
    let universalLinkHandler: (any DeepLinkHandler)?

    init(
        handler: any DeepLinkHandler,
        includeUniversalLinks: Bool = false,
        universalLinkHandler: (any DeepLinkHandler)? = nil
    ) {
        self.handler = handler
        self.includeUniversalLinks = includeUniversalLinks
        self.universalLinkHandler = universalLinkHandler
    }
}

/// State restoration configuration options
public struct StateRestorationConfiguration {
    /// The key to use for storing navigation state in SceneStorage
    public let sceneStorageKey: String

    public init(sceneStorageKey: String = "navigation_state") {
        self.sceneStorageKey = sceneStorageKey
    }
}
