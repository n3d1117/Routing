import Foundation
@testable import Routing
import SwiftUI
import Testing

@Suite
struct DeepLinkingTests {
    // MARK: - Test Route & Handler

    private enum TestRoute: String, Routable, Codable {
        case home, profile, settings, item

        var id: String { rawValue }

        var destination: some View {
            EmptyView()
        }
    }

    private struct TestHandler: DeepLinkHandler {
        func handle(_ url: URL) -> [TestRoute]? {
            guard url.scheme == "testapp" else { return nil }

            let pathComponents = [url.host, url.path]
                .compactMap { $0 }
                .flatMap { $0.split(separator: "/") }
                .map(String.init)

            // Special case for /item/{id} - we just want the 'item' route
            if pathComponents.first == "item", pathComponents.count > 1 {
                return [.item]
            }

            return pathComponents.compactMap { TestRoute(rawValue: $0) }
        }
    }

    // MARK: - Tests

    @Test("Handler parses simple URL")
    func handlerParsesSimpleURL() {
        let handler = TestHandler()
        let url = URL(string: "testapp://home")!
        let routes = handler.handle(url)
        #expect(routes == [.home])
    }

    @Test("Handler parses nested URL")
    func handlerParsesNestedURL() {
        let handler = TestHandler()
        let url = URL(string: "testapp://profile/settings")!
        let routes = handler.handle(url)
        #expect(routes == [.profile, .settings])
    }

    @Test("Handler rejects wrong scheme")
    func handlerRejectsWrongScheme() {
        let handler = TestHandler()
        let url = URL(string: "wrongapp://home")!
        let routes = handler.handle(url)
        #expect(routes == nil)
    }

    @Test("Handler handles invalid routes gracefully")
    func handlerHandlesInvalidRoutes() {
        let handler = TestHandler()
        let url = URL(string: "testapp://home/invalid/settings")!
        let routes = handler.handle(url)
        #expect(routes == [.home, .settings])
    }

    @Test("Handler returns nil for only invalid routes")
    func handlerReturnsNilForOnlyInvalidRoutes() {
        let handler = TestHandler()
        let url = URL(string: "testapp://invalid/route")!
        let routes = handler.handle(url)
        #expect(routes == [])
    }

    @Test("Handler handles URL with query parameters")
    func handlerHandlesURLWithQuery() {
        let handler = TestHandler()
        let url = URL(string: "testapp://profile/settings?source=deeplink")!
        let routes = handler.handle(url)
        #expect(routes == [.profile, .settings])
    }

    @Test("Handler handles URL with fragment")
    func handlerHandlesURLWithFragment() {
        let handler = TestHandler()
        let url = URL(string: "testapp://home#section1")!
        let routes = handler.handle(url)
        #expect(routes == [.home])
    }

    @Test("Handler handles URL with path-like parameters")
    func handlerHandlesURLWithPathLikeParameters() {
        let handler = TestHandler()
        let url = URL(string: "testapp://item/12345")!
        let routes = handler.handle(url)
        #expect(routes == [.item])
    }

    @Test("Handler returns nil for empty host and path")
    func handlerReturnsNilForEmptyURL() {
        let handler = TestHandler()
        let url = URL(string: "testapp://")!
        let routes = handler.handle(url)
        #expect(routes == [])
    }
}
