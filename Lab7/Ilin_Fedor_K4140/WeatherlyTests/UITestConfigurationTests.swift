#if DEBUG
import XCTest
@testable import Weatherly

final class UITestConfigurationTests: XCTestCase {
    func testLaunchWithoutUITestFlagHasNoConfiguration() {
        XCTAssertNil(UITestConfiguration(arguments: ["Weatherly"]))
    }

    func testUITestLaunchRequiresValidSessionID() {
        XCTAssertNil(UITestConfiguration(arguments: ["--uitesting"]))
        XCTAssertNil(UITestConfiguration(arguments: ["--uitesting", "--uitesting-session", "../Favorites"]))
    }

    func testSessionAndOptionsAreParsed() throws {
        let session = UUID()
        let configuration = try XCTUnwrap(UITestConfiguration(arguments: [
            "--uitesting", "--uitesting-session", session.uuidString,
            "--uitesting-reset", "--uitesting-fail-search"
        ]))

        XCTAssertEqual(configuration.session, session)
        XCTAssertTrue(configuration.resetsState)
        XCTAssertTrue(configuration.failsFirstSearch)
    }

    func testSessionsUseSeparateStorage() throws {
        let first = try configuration(session: UUID())
        let second = try configuration(session: UUID())

        XCTAssertNotEqual(first.directory, second.directory)
        XCTAssertNotEqual(first.defaultsSuiteName, second.defaultsSuiteName)
        XCTAssertNotEqual(first.directory.appending(path: "Favorites.store"), PersistenceStack.favoritesStoreURL)
        XCTAssertFalse(first.resetsState)
    }

    func testResetOnlyClearsRequestedSession() throws {
        let first = try configuration(session: UUID(), reset: true)
        let second = try configuration(session: UUID())
        let manager = FileManager.default
        defer {
            try? manager.removeItem(at: first.directory)
            try? manager.removeItem(at: second.directory)
            UserDefaults.standard.removePersistentDomain(forName: first.defaultsSuiteName)
            UserDefaults.standard.removePersistentDomain(forName: second.defaultsSuiteName)
        }
        for configuration in [first, second] {
            try manager.createDirectory(at: configuration.directory, withIntermediateDirectories: true)
            try Data("saved".utf8).write(to: configuration.directory.appending(path: "sentinel"))
            try XCTUnwrap(UserDefaults(suiteName: configuration.defaultsSuiteName)).set(true, forKey: "sentinel")
        }

        try first.resetStorageIfRequested()
        try second.resetStorageIfRequested()

        XCTAssertFalse(manager.fileExists(atPath: first.directory.path(percentEncoded: false)))
        XCTAssertNil(try XCTUnwrap(UserDefaults(suiteName: first.defaultsSuiteName)).object(forKey: "sentinel"))
        XCTAssertTrue(manager.fileExists(atPath: second.directory.appending(path: "sentinel").path(percentEncoded: false)))
        XCTAssertTrue(try XCTUnwrap(UserDefaults(suiteName: second.defaultsSuiteName)).bool(forKey: "sentinel"))
    }

    private func configuration(session: UUID, reset: Bool = false) throws -> UITestConfiguration {
        var arguments = ["--uitesting", "--uitesting-session", session.uuidString]
        if reset { arguments.append("--uitesting-reset") }
        return try XCTUnwrap(UITestConfiguration(arguments: arguments))
    }
}
#endif
