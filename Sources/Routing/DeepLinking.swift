//
//  DeepLinking.swift
//  Routing
//
//  Created by ned on 02/07/25.
//

import SwiftUI

// MARK: - Deep Link Handler Protocol

/// Protocol for handling deep links and converting them to routes
public protocol DeepLinkHandler<Route> {
    associatedtype Route: Routable

    /// Parse a URL and return the route(s) to navigate to
    func handle(_ url: URL) -> [Route]?
}
