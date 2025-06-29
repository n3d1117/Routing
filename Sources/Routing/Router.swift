//
//  Router.swift
//  Routing
//
//  Created by ned on 25/06/25.
//

import SwiftUI

/// An enumeration defining the style of a modal presentation.
public enum PresentationStyle {
    case sheet
    #if os(iOS)
    case fullScreenCover
    #endif
}

/// Property wrapper for managing navigation stack state and modal presentation.
/// Provides type-safe navigation methods for SwiftUI apps.
@propertyWrapper
public struct Router<Destination: Routable>: DynamicProperty {
    @State private var core = RouterCore<Destination>()

    /// Initialize with an empty navigation path
    public init() {}

    public var wrappedValue: [Destination] {
        get { core.path }
        nonmutating set { core.path = newValue }
    }

    public var projectedValue: Binding<[Destination]> {
        Binding(
            get: { core.path },
            set: { core.path = $0 }
        )
    }

    /// Binding for the currently presented modal item.
    /// This is internal and used by the `RoutingView`.
    var presentedItemBinding: Binding<Destination?> {
        Binding(
            get: { core.presentedItem },
            set: { core.presentedItem = $0 }
        )
    }

    /// The presentation style for the next modal view.
    /// This is internal and used by the `RoutingView`.
    var presentationStyle: PresentationStyle {
        core.presentationStyle
    }

    /// The presentation style for the next modal view.
    /// This is internal and used by the `RoutingView`.
    var onDismiss: (() -> Void)? {
        core.onModalDismiss
    }

    /// Internal access to the path
    var path: [Destination] {
        core.path
    }
}

// MARK: - Navigation Methods

public extension Router {
    /// Pushes a new view onto the navigation stack.
    /// - Parameter destination: The destination view to push.
    func navigate(to destination: Destination) {
        core.navigate(to: destination)
    }

    /// Pops the top-most view from the navigation stack.
    func goBack() {
        core.goBack()
    }

    /// Pops all views from the navigation stack, returning to the root view.
    func popToRoot() {
        core.popToRoot()
    }

    /// Presents a view modally.
    /// - Parameters:
    ///   - destination: The view to present.
    ///   - style: The presentation style (`.sheet` or `.fullScreenCover`). Defaults to `.sheet`.
    ///   - onDismiss: An optional closure to be called when the presented modal is dismissed.
    func present(
        _ destination: Destination,
        style: PresentationStyle = .sheet,
        onDismiss: (() -> Void)? = nil
    ) {
        core.present(destination, style: style, onDismiss: onDismiss)
    }
}

// MARK: - Deep Linking Support

extension Router {
    /// Handle deep linking directly on this router instance
    func handleDeepLink<Handler: DeepLinkHandler<Destination>>(_ url: URL, handler: Handler) {
        if let routes = handler.handle(url) {
            core.handleDeepLink(routes)
        }
    }
}

// MARK: - State Restoration Support

extension Router: RouterCoreWithCodableDestination where Destination: Codable {
    func encoded() -> Data? {
        core.encoded()
    }

    func restore(from data: Data) {
        core.restore(from: data)
    }
}
