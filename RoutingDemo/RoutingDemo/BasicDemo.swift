//
//  BasicDemo.swift
//  RoutingDemo
//
//  Created by ned on 05/07/25.
//

import Routing
import SwiftUI

extension EnvironmentValues {
    @Entry var basicDemoRouter: Router<BasicDemoRoute> = Router()
}

public enum BasicDemoRoute: String, Routable {
    case red, green, blue, yellow

    public var id: String { rawValue }

    @ViewBuilder
    public var destination: some View {
        Group {
            switch self {
            case .red: Color.red
            case .green: Color.green
            case .blue: Color.blue
            case .yellow: Color.yellow
            }
        }
        .overlay(BasicRoutingControlsView(), alignment: .bottom)
    }
}

struct BasicRoutingDemoView: View {
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 8) {
                FeatureItem(icon: "arrow.right", text: "Push navigation")
                FeatureItem(icon: "doc.on.doc", text: "Sheet presentation")
                FeatureItem(icon: "rectangle.expand.vertical", text: "Full screen covers (iOS)")
                FeatureItem(icon: "arrow.backward", text: "Go back / Pop to root")
            }

            Spacer()

            BasicRoutingControlsView()
        }
        .padding()
        .navigationTitle("Basic Router")
    }
}

struct BasicRoutingControlsView: View {
    @Environment(\.basicDemoRouter) private var router
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Path: \(pathDisplay)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(6)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                Button("Red") { router.navigate(to: .red) }
                    .buttonStyle(.highContrastButton)
                Button("Green") { router.navigate(to: .green) }
                    .buttonStyle(.highContrastButton)
                Button("Blue") { router.navigate(to: .blue) }
                    .buttonStyle(.highContrastButton)
                Button("Yellow") { router.navigate(to: .yellow) }
                    .buttonStyle(.highContrastButton)
            }

            Divider()

            HStack(spacing: 12) {
                Button("Sheet (Red)") {
                    router.present(.red, style: .sheet)
                }
                .buttonStyle(.highContrastButton)

                #if os(iOS)
                    Button("Cover (Green)") {
                        router.present(.green, style: .fullScreenCover)
                    }
                    .buttonStyle(.highContrastButton)
                #endif
            }

            Divider()

            HStack(spacing: 12) {
                Button("Back") { router.goBack() }
                    .buttonStyle(.highContrastButton)
                Button("Root") { router.popToRoot() }
                    .buttonStyle(.highContrastButton)
                Button("Dismiss") { dismiss() }
                    .buttonStyle(.highContrastButton)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var pathDisplay: String {
        let path = router.wrappedValue.map { $0.rawValue }
        return path.isEmpty ? "root" : path.joined(separator: " → ")
    }
}

struct FeatureItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}

struct HighContrastButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            )
            .foregroundColor(.black)
            .font(.system(size: 14, weight: .medium))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == HighContrastButtonStyle {
    static var highContrastButton: HighContrastButtonStyle {
        HighContrastButtonStyle()
    }
}
