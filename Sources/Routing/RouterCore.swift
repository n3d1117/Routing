//
//  RouterCore.swift
//  Routing
//
//  Created by ned on 30/06/25.
//

import SwiftUI

// MARK: - Protocol for State Restoration Support

protocol RouterCoreWithCodableDestination {
    func encoded() -> Data?
    func restore(from data: Data)
}

@Observable
class RouterCore<Destination: Routable> {
    var path: [Destination]
    var presentedItem: Destination?

    @ObservationIgnored
    var presentationStyle: PresentationStyle = .sheet

    @ObservationIgnored
    var onModalDismiss: (() -> Void)?

    init(path: [Destination] = []) {
        self.path = path
        presentedItem = nil
    }

    func navigate(to destination: Destination) {
        path.append(destination)
    }

    func present(
        _ destination: Destination,
        style: PresentationStyle,
        onDismiss: (() -> Void)? = nil
    ) {
        presentationStyle = style
        onModalDismiss = onDismiss
        presentedItem = destination
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    // MARK: - Deep Linking Support

    func handleDeepLink(_ routes: [Destination]) {
        RoutingLogger.deepLinking.debug("Handling routes: \(routes)")
        path.append(contentsOf: routes)
    }
}

// MARK: - State Restoration Support

extension RouterCore: RouterCoreWithCodableDestination where Destination: Codable {
    func encoded() -> Data? {
        try? JSONEncoder().encode(path)
    }

    func restore(from data: Data) {
        do {
            let restoredPath = try JSONDecoder().decode([Destination].self, from: data)
            if restoredPath != path {
                path = restoredPath
                RoutingLogger.stateRestoration.debug("Path restored to: \(String(describing: self.path))")
            }
        } catch {
            RoutingLogger.stateRestoration.error("Failed to decode saved state: \(error.localizedDescription)")
            path = []
        }
    }
}
