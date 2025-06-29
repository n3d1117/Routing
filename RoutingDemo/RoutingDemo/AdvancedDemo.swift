//
//  AdvancedDemo.swift
//  RoutingDemo
//
//  Created by ned on 05/07/25.
//

import Routing
import SwiftUI

extension EnvironmentValues {
    @Entry var advancedDemoRouter: Router<AdvancedDemoRoute> = Router()
}

public enum AdvancedDemoRoute: String, Routable, Codable {
    case dashboard, analytics, reports

    public static let urlScheme = "routingdemo"

    public var id: String { rawValue }

    @ViewBuilder
    public var destination: some View {
        Group {
            switch self {
            case .dashboard:
                AdvancedDemoScreenView(
                    title: "📊 Dashboard",
                    description: "Main dashboard with metrics and overview"
                )
            case .analytics:
                AdvancedDemoScreenView(
                    title: "📈 Analytics",
                    description: "Detailed analytics and charts"
                )
            case .reports:
                AdvancedDemoScreenView(
                    title: "📋 Reports",
                    description: "Generate and view reports"
                )
            }
        }
    }
}

struct AdvancedDemoDeepLinkHandler: DeepLinkHandler {
    func handle(_ url: URL) -> [AdvancedDemoRoute]? {
        guard url.scheme == "routingdemo" else { return nil }

        return [url.host, url.path]
            .compactMap { $0 }
            .flatMap { $0.split(separator: "/") }
            .compactMap { AdvancedDemoRoute(rawValue: String($0)) }
    }
}

struct AdvancedDemoView: View {
    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 8) {
                FeatureItem(icon: "link", text: "Deep linking")
                FeatureItem(icon: "arrow.clockwise", text: "State restoration")
                FeatureItem(icon: "externaldrive.connected.to.line.below", text: "Universal links")
            }

            Text("Try these URLs:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Button("• routingdemo://dashboard") {
                    UIApplication.shared.open(URL(string: "routingdemo://dashboard")!)
                }
                Button("• routingdemo://analytics/reports") {
                    UIApplication.shared.open(URL(string: "routingdemo://analytics/reports")!)
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            Spacer()

            AdvancedDemoControlsView()
        }
        .padding()
        .navigationTitle("Advanced Features")
    }
}

struct AdvancedDemoControlsView: View {
    @Environment(\.advancedDemoRouter) private var router

    var body: some View {
        VStack(spacing: 16) {
            Text("Path: \(pathDisplay)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(6)
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

struct AdvancedDemoScreenView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()

            AdvancedDemoControlsView()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title.components(separatedBy: " ").last ?? "Screen")
    }
}
