//
//  Routable.swift
//  Routing
//
//  Created by ned on 26/06/25.
//

import SwiftUI

/// A protocol that defines a type that can be used for navigation.
/// A routable item is a value that can be resolved into a destination view.
public protocol Routable: Hashable, Identifiable {
    /// The type of view to be presented for this route.
    associatedtype Destination: View

    /// The view to be presented for this route.
    @ViewBuilder var destination: Destination { get }
}
