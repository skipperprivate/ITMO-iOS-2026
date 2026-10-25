import Foundation

extension AppContainer {
    @MainActor
    static func configuredForLaunch(arguments: [String] = ProcessInfo.processInfo.arguments) -> AppContainer {
        #if DEBUG
        if arguments.contains("--uitesting") {
            guard let configuration = UITestConfiguration(arguments: arguments) else {
                preconditionFailure("UI tests require a valid session UUID")
            }
            do {
                return try configuration.makeContainer()
            } catch {
                preconditionFailure("Cannot prepare UI test storage: \(error)")
            }
        }
        #endif
        return .live()
    }
}

#if DEBUG
nonisolated struct UITestConfiguration {
    let session: UUID
    let resetsState: Bool
    let failsFirstSearch: Bool

    init?(arguments: [String]) {
        guard arguments.contains("--uitesting"),
              let index = arguments.firstIndex(of: "--uitesting-session"),
              arguments.indices.contains(index + 1),
              let session = UUID(uuidString: arguments[index + 1]) else { return nil }
        self.session = session
        resetsState = arguments.contains("--uitesting-reset")
        failsFirstSearch = arguments.contains("--uitesting-fail-search")
    }

    var directory: URL {
        URL.applicationSupportDirectory.appending(path: "UITests").appending(path: session.uuidString)
    }

    var defaultsSuiteName: String {
        "Weatherly.UITests.\(session.uuidString)"
    }

    func resetStorageIfRequested() throws {
        guard resetsState else { return }
        // FileManager expects a filesystem path, not a URL-encoded path.
        if FileManager.default.fileExists(atPath: directory.path(percentEncoded: false)) {
            try FileManager.default.removeItem(at: directory)
        }
        UserDefaults.standard.removePersistentDomain(forName: defaultsSuiteName)
    }

    @MainActor
    func makeContainer() throws -> AppContainer {
        try resetStorageIfRequested()
        guard let defaults = UserDefaults(suiteName: defaultsSuiteName) else {
            preconditionFailure("Cannot open UI test defaults")
        }
        return AppContainer(
            weatherRepository: MockWeatherRepository(),
            geocodingRepository: UITestGeocodingRepository(failsFirstSearch: failsFirstSearch),
            favoritesRepository: SwiftDataFavoritesRepository(
                container: PersistenceStack.favoritesContainer(at: directory.appending(path: "Favorites.store")),
                defaultCities: []
            ),
            settingsRepository: UserDefaultsSettingsRepository(defaults: defaults),
            appStateRepository: UserDefaultsAppStateRepository(defaults: defaults)
        )
    }
}

private actor UITestGeocodingRepository: GeocodingRepositoryProtocol {
    nonisolated let minimumQueryLength = 2
    private let upstream = MockGeocodingRepository()
    private let failsFirstSearch: Bool
    private var hasFailed = false

    init(failsFirstSearch: Bool) {
        self.failsFirstSearch = failsFirstSearch
    }

    func searchCities(matching query: String) async throws -> [City] {
        if failsFirstSearch, !hasFailed, query.trimmingCharacters(in: .whitespacesAndNewlines) == "Москва" {
            hasFailed = true
            throw RepositoryError.offline
        }
        return try await upstream.searchCities(matching: query)
    }
}
#endif
