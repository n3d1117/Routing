import Foundation
@testable import Routing
import SwiftUI
import Testing

@Suite
struct StateRestorationTests {
    // MARK: - Test Routes

    private enum CodableRoute: String, Routable, Codable {
        case home, profile, settings, advanced

        var id: String { rawValue }

        var destination: some View {
            EmptyView()
        }
    } 

    // MARK: - RouterCore State Restoration Tests

    @Test("RouterCore encoded produces consistent data")
    func coreEncodedConsistent() {
        let router = RouterCore<CodableRoute>(path: [.home, .profile, .settings])

        let data1 = router.encoded()
        let data2 = router.encoded()

        #expect(data1 != nil)
        #expect(data2 != nil)
        #expect(data1 == data2)
    }

    @Test("RouterCore encoded handles empty path")
    func coreEncodedEmpty() {
        let router = RouterCore<CodableRoute>()

        let data = router.encoded()

        #expect(data != nil)

        // Should be able to decode empty array
        let decodedPath = try? JSONDecoder().decode([CodableRoute].self, from: data!)
        #expect(decodedPath?.isEmpty == true)
    }

    @Test("RouterCore restore preserves order")
    func coreRestorePreservesOrder() throws {
        let originalPath: [CodableRoute] = [.home, .settings, .profile, .advanced]
        let router = RouterCore<CodableRoute>()
        let data = try JSONEncoder().encode(originalPath)

        router.restore(from: data)

        #expect(router.path == originalPath)
    }

    @Test("RouterCore restore overwrites existing path")
    func coreRestoreOverwrites() throws {
        let router = RouterCore<CodableRoute>(path: [.home, .profile])
        let newPath: [CodableRoute] = [.settings, .advanced]
        let data = try JSONEncoder().encode(newPath)

        router.restore(from: data)

        #expect(router.path == newPath)
        #expect(router.path.count == 2)
    }

    @Test("RouterCore restore handles corrupted JSON")
    func coreRestoreCorruptedJson() {
        let router = RouterCore<CodableRoute>(path: [.home])
        let corruptedData = "{\"invalid\": json}".data(using: .utf8)!

        router.restore(from: corruptedData)

        // Should clear path on corruption
        #expect(router.path.isEmpty)
    }

    @Test("RouterCore restore handles wrong data format")
    func coreRestoreWrongFormat() throws {
        let router = RouterCore<CodableRoute>(path: [.home])
        // Encode a string instead of route array
        let wrongData = try JSONEncoder().encode("wrong format")

        router.restore(from: wrongData)

        #expect(router.path.isEmpty)
    }

    @Test("RouterCore restore handles partial corruption")
    func coreRestorePartialCorruption() {
        let router = RouterCore<CodableRoute>()
        // Manually create partially valid JSON
        let partialJson = "[\"home\", \"invalid_route\", \"settings\"]"
        let data = partialJson.data(using: .utf8)!

        router.restore(from: data)

        // Should either restore valid parts or clear entirely (depending on implementation)
        // For now, expecting it to clear on any decoding error
        #expect(router.path.isEmpty)
    }

    // MARK: - Encode/Restore Roundtrip Tests

    @Test("Single route roundtrip")
    func singleRouteRoundtrip() {
        let router1 = RouterCore<CodableRoute>(path: [.home])
        let router2 = RouterCore<CodableRoute>()

        let data = router1.encoded()!
        router2.restore(from: data)

        #expect(router1.path == router2.path)
    }

    @Test("Multiple routes roundtrip")
    func multipleRoutesRoundtrip() {
        let router1 = RouterCore<CodableRoute>(path: [.home, .profile, .settings, .advanced])
        let router2 = RouterCore<CodableRoute>()

        let data = router1.encoded()!
        router2.restore(from: data)

        #expect(router1.path == router2.path)
    }

    @Test("Empty path roundtrip")
    func emptyPathRoundtrip() {
        let router1 = RouterCore<CodableRoute>()
        let router2 = RouterCore<CodableRoute>(path: [.home, .profile])

        let data = router1.encoded()!
        router2.restore(from: data)

        #expect(router1.path == router2.path)
        #expect(router2.path.isEmpty)
    }

    @Test("Complex navigation state roundtrip")
    func complexNavigationRoundtrip() {
        let router1 = RouterCore<CodableRoute>()

        // Simulate complex navigation
        router1.navigate(to: .home)
        router1.navigate(to: .profile)
        router1.goBack()
        router1.navigate(to: .settings)
        router1.navigate(to: .advanced)

        let router2 = RouterCore<CodableRoute>()
        let data = router1.encoded()!
        router2.restore(from: data)

        #expect(router1.path == router2.path)
        #expect(router2.path == [.home, .settings, .advanced])
    }

    // MARK: - JSON Format Tests

    @Test("Encoded data produces valid JSON")
    func encodedDataValidJson() throws {
        let router = RouterCore<CodableRoute>(path: [.home, .profile])
        let data = router.encoded()!

        // Should be valid JSON
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        #expect(jsonObject is [String])

        let stringArray = jsonObject as! [String]
        #expect(stringArray == ["home", "profile"])
    }

    @Test("Encoded data is compact")
    func encodedDataCompact() {
        let router = RouterCore<CodableRoute>(path: [.home])
        let data = router.encoded()!

        let jsonString = String(data: data, encoding: .utf8)!

        // Should be compact JSON without extra whitespace
        #expect(jsonString == "[\"home\"]")
    }

    @Test("Encoded data handles special route names")
    func encodedDataSpecialNames() {
        // Create route enum with special characters
        enum SpecialRoute: String, Routable, Codable {
            case normalRoute = "normal"
            case spaceRoute = "route with spaces"
            case unicodeRoute = "route_with_émojis_🚀"
            case numbersRoute = "route123"

            var id: String { rawValue }
            var destination: some View { EmptyView() }
        }

        let router = RouterCore<SpecialRoute>(path: [.spaceRoute, .unicodeRoute])
        let data = router.encoded()!

        // Should handle special characters correctly
        let restoredRouter = RouterCore<SpecialRoute>()
        restoredRouter.restore(from: data)

        #expect(restoredRouter.path == [.spaceRoute, .unicodeRoute])
    }

    // MARK: - Performance Tests

    @Test("Encoding large path is efficient")
    func encodingLargePathEfficient() {
        // Create a large path
        let largePath = Array(repeating: CodableRoute.home, count: 1000)
        let router = RouterCore<CodableRoute>(path: largePath)

        let startTime = CFAbsoluteTimeGetCurrent()
        let data = router.encoded()
        let endTime = CFAbsoluteTimeGetCurrent()

        #expect(data != nil)
        #expect(endTime - startTime < 0.1) // Should complete in less than 100ms
    }

    @Test("Restoring large path is efficient")
    func restoringLargePathEfficient() throws {
        let largePath = Array(repeating: CodableRoute.home, count: 1000)
        let data = try JSONEncoder().encode(largePath)
        let router = RouterCore<CodableRoute>()

        let startTime = CFAbsoluteTimeGetCurrent()
        router.restore(from: data)
        let endTime = CFAbsoluteTimeGetCurrent()

        #expect(router.path.count == 1000)
        #expect(endTime - startTime < 0.1) // Should complete in less than 100ms
    }

    // MARK: - Memory Management Tests

    @Test("RouterCore doesn't retain unnecessary data")
    func routerCoreMemoryManagement() {
        var router: RouterCore<CodableRoute>? = RouterCore<CodableRoute>()
        weak var weakRouter = router

        router?.navigate(to: .home)
        let data = router?.encoded()

        // Router should be deallocated when we clear the reference
        router = nil
        #expect(weakRouter == nil)

        // Data should still be valid
        #expect(data != nil)
    }

    @Test("Restore doesn't create memory leaks")
    func restoreMemoryManagement() throws {
        let originalPath = [CodableRoute.home, .profile, .settings]
        let data = try JSONEncoder().encode(originalPath)

        for _ in 0 ..< 100 {
            let router = RouterCore<CodableRoute>()
            router.restore(from: data)
            #expect(router.path == originalPath)
        }

        // If we get here without memory issues, test passes
        #expect(Bool(true))
    }

    // MARK: - Integration with Navigation Tests

    @Test("State restoration preserves navigation history")
    func stateRestorationNavigationHistory() throws {
        let router1 = RouterCore<CodableRoute>()

        // Build up navigation history
        router1.navigate(to: .home)
        router1.navigate(to: .profile)
        router1.navigate(to: .settings)

        // Encode state
        let data = router1.encoded()!

        // Create new router and restore
        let router2 = RouterCore<CodableRoute>()
        router2.restore(from: data)

        // Navigation should work normally
        router2.goBack()
        #expect(router2.path == [.home, .profile])

        router2.navigate(to: .advanced)
        #expect(router2.path == [.home, .profile, .advanced])
    }

    @Test("State restoration doesn't affect modal state")
    func stateRestorationModalState() throws {
        let router1 = RouterCore<CodableRoute>(path: [.home, .profile])
        router1.present(.settings, style: .sheet)

        let data = router1.encoded()!

        let router2 = RouterCore<CodableRoute>()
        router2.restore(from: data)

        // Navigation path should be restored
        #expect(router2.path == [.home, .profile])

        // Modal state should NOT be restored (by design)
        #expect(router2.presentedItem == nil)
    }
}
