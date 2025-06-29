//
//  RoutingDemoApp.swift
//  RoutingDemo
//
//  Created by ned on 02/07/25.
//

import SwiftUI

@main
struct RoutingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoTabView()
        }
    }
}

struct DemoTabView: View {
    enum Tab: Int {
        case basic, advanced
    }

    @SceneStorage("selectedTab") private var selectedTab: Tab = .basic

    public var body: some View {
        TabView(selection: $selectedTab) {
            BasicRoutingDemoView()
                .withRouter(\.basicDemoRouter)
                .tabItem {
                    Label("Basic", systemImage: "arrow.right.circle")
                }
                .tag(Tab.basic)

            AdvancedDemoView()
                .withRouter(\.advancedDemoRouter, features: [
                    .deepLinking(AdvancedDemoDeepLinkHandler()),
                    .stateRestoration(key: "advanced_demo")
                ])
                .tabItem {
                    Label("Advanced", systemImage: "star.circle")
                }
                .tag(Tab.advanced)
        }
    }
}
