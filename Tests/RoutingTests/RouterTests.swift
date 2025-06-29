@testable import Routing
import SwiftUI
import Testing

@Suite
struct RouterTests {
    private enum TestRoute: String, Routable {
        case first, second, third

        var id: String { rawValue }

        var destination: some View {
            EmptyView()
        }
    }

    @Test("RouterCore initializes empty by default")
    func coreDefaultInitialization() {
        let router = RouterCore<TestRoute>()
        #expect(router.path.isEmpty)
        #expect(router.presentedItem == nil)
    }

    @Test("RouterCore navigate adds to path")
    func coreNavigate() {
        let router = RouterCore<TestRoute>()
        router.navigate(to: .first)
        #expect(router.path.count == 1)
        #expect(router.path.first == .first)
    }

    @Test("RouterCore goBack removes from path")
    func coreGoBack() {
        let router = RouterCore<TestRoute>(path: [.first, .second])
        router.goBack()
        #expect(router.path.count == 1)
        #expect(router.path.first == .first)
    }

    @Test("RouterCore goBack does nothing on empty path")
    func coreGoBackEmpty() {
        let router = RouterCore<TestRoute>()
        router.goBack()
        #expect(router.path.isEmpty)
    }

    @Test("RouterCore popToRoot clears path")
    func corePopToRoot() {
        let router = RouterCore<TestRoute>(path: [.first, .second])
        router.popToRoot()
        #expect(router.path.isEmpty)
    }

    @Test("RouterCore present sets presentedItem and style")
    func corePresent() {
        let router = RouterCore<TestRoute>()
        router.present(.first, style: .sheet)
        #expect(router.presentedItem == .first)
        #expect(router.presentationStyle == .sheet)
        #if os(iOS)
        router.present(.second, style: .fullScreenCover)
        #expect(router.presentedItem == .second)
        #expect(router.presentationStyle == .fullScreenCover)
        #endif
    }

    @Test("RouterCore dismiss clears presentedItem")
    func coreDismiss() {
        let router = RouterCore<TestRoute>()
        router.present(.first, style: .sheet)
        router.presentedItem = nil
        #expect(router.presentedItem == nil)
    }

    // MARK: - Custom Deep Link Handler Tests

    private enum TestDeepLinkRoute: String, Routable, Codable {
        case home, profile, settings

        var id: String { rawValue }

        var destination: some View {
            EmptyView()
        }
    }

    private struct TestCustomHandler: DeepLinkHandler {
        func handle(_ url: URL) -> [TestDeepLinkRoute]? {
            guard url.scheme == "customtest",
                  let host = url.host else { return nil }

            switch host {
            case "user": return [.profile]
            case "config": return [.settings]
            case "dashboard": return [.home, .profile]
            default: return nil
            }
        }
    }

    @Test("Custom DeepLinkHandler handles custom URLs")
    func customHandlerBasic() {
        let handler = TestCustomHandler()
        let url = URL(string: "customtest://user")!

        let routes = handler.handle(url)

        #expect(routes?.count == 1)
        #expect(routes?.first == .profile)
    }

    @Test("Custom DeepLinkHandler handles multi-route URLs")
    func customHandlerMultiRoute() {
        let handler = TestCustomHandler()
        let url = URL(string: "customtest://dashboard")!

        let routes = handler.handle(url)

        #expect(routes?.count == 2)
        #expect(routes == [.home, .profile])
    }

    @Test("Custom DeepLinkHandler rejects invalid URLs")
    func customHandlerInvalid() {
        let handler = TestCustomHandler()
        let url = URL(string: "customtest://unknown")!

        let routes = handler.handle(url)

        #expect(routes == nil)
    }

    @Test("Custom DeepLinkHandler rejects wrong scheme")
    func customHandlerWrongScheme() {
        let handler = TestCustomHandler()
        let url = URL(string: "wrongscheme://user")!

        let routes = handler.handle(url)

        #expect(routes == nil)
    }
}
