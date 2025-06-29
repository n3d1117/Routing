//
//  RoutingView.swift
//  Routing
//
//  Created by ned on 25/06/25.
//

import SwiftUI

/// A wrapper view that provides navigation stack functionality and modal presentation for Routable types.
/// This view handles the underlying NavigationStack, destination setup, and sheet presentation.
struct RoutingView<RouteType: Routable, Content: View>: View {
    @Binding private var path: [RouteType]
    @Binding private var presentedItem: RouteType?

    private let content: Content
    private let presentationStyle: PresentationStyle
    private let onDismiss: (() -> Void)?
    private let routerKeyPath: WritableKeyPath<EnvironmentValues, Router<RouteType>>

    /// Initialize with path binding, presented item binding, and root content
    /// - Parameters:
    ///   - path: Binding to the navigation path array.
    ///   - presentedItem: Binding to the currently presented modal item.
    ///   - presentationStyle: The style for modal presentations.
    ///   - routerKeyPath: The key path for the router in the environment.
    ///   - content: The root content view builder.
    init(
        path: Binding<[RouteType]>,
        presentedItem: Binding<RouteType?>,
        presentationStyle: PresentationStyle,
        onDismiss: (() -> Void)?,
        routerKeyPath: WritableKeyPath<EnvironmentValues, Router<RouteType>>,
        @ViewBuilder content: () -> Content
    ) {
        _path = path
        _presentedItem = presentedItem
        self.presentationStyle = presentationStyle
        self.onDismiss = onDismiss
        self.content = content()
        self.routerKeyPath = routerKeyPath
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationDestination(for: RouteType.self) { route in
                    route.destination
                }
        }
        .present(item: $presentedItem, style: presentationStyle, onDismiss: onDismiss) { route in
            route.destination
                .withRouter(routerKeyPath)
        }
    }
}

// MARK: - View Extension for Presentation

private extension View {
    @ViewBuilder
    func present<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        style: PresentationStyle,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        switch style {
        case .sheet:
            sheet(item: item, onDismiss: onDismiss, content: content)
        #if os(iOS)
        case .fullScreenCover:
            fullScreenCover(item: item, onDismiss: onDismiss, content: content)
        #endif
        }
    }
}
