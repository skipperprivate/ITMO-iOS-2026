import Foundation
import OSLog
import SwiftData

nonisolated enum PersistenceStack {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Weatherly", category: "Persistence")

    static var favoritesStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: "Favorites.store")
    }

    static var cacheStoreURL: URL {
        URL.cachesDirectory.appending(path: "Cache.store")
    }

    // MARK: Favourites

    static func favoritesContainer(at url: URL = favoritesStoreURL) -> ModelContainer {
        do {
            return try makeFavoritesContainer(storedAt: url)
        } catch {
            logger.error("Favorites store failed to open: \(error.localizedDescription, privacy: .public); moving it aside")
            moveAside(storeAt: url)
        }
        do {
            return try makeFavoritesContainer(storedAt: url)
        } catch {
            logger.fault("Fresh favorites store failed to open: \(error.localizedDescription, privacy: .public); using memory")
            return inMemoryFavoritesContainer()
        }
    }

    static func inMemoryFavoritesContainer() -> ModelContainer {
        do {
            return try makeFavoritesContainer(storedAt: nil)
        } catch {
            fatalError("Favorites schema is invalid: \(error)")
        }
    }

    private static func makeFavoritesContainer(storedAt url: URL?) throws -> ModelContainer {
        let schema = Schema(versionedSchema: FavoritesSchemaV1.self)
        return try ModelContainer(
            for: schema,
            migrationPlan: FavoritesMigrationPlan.self,
            configurations: try configuration(schema: schema, url: url)
        )
    }

    // MARK: Cache

    static func cacheContainer(at url: URL = cacheStoreURL) -> ModelContainer {
        do {
            return try makeCacheContainer(storedAt: url)
        } catch {
            logger.notice("Cache store failed to open: \(error.localizedDescription, privacy: .public); recreating it")
            removeStore(at: url)
        }
        do {
            return try makeCacheContainer(storedAt: url)
        } catch {
            logger.fault("Fresh cache store failed to open: \(error.localizedDescription, privacy: .public); using memory")
            return inMemoryCacheContainer()
        }
    }

    static func inMemoryCacheContainer() -> ModelContainer {
        do {
            return try makeCacheContainer(storedAt: nil)
        } catch {
            fatalError("Cache schema is invalid: \(error)")
        }
    }

    private static func makeCacheContainer(storedAt url: URL?) throws -> ModelContainer {
        let schema = Schema(CacheSchema.models)
        return try ModelContainer(for: schema, configurations: try configuration(schema: schema, url: url))
    }

    // MARK: Files

    private static func configuration(schema: Schema, url: URL?) throws -> ModelConfiguration {
        guard let url else {
            return ModelConfiguration(schema: schema, isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        return ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
    }

    private static func storeFiles(at url: URL) -> [URL] {
        ["", "-wal", "-shm"].map { URL(filePath: url.path() + $0) }
    }

    private static func moveAside(storeAt url: URL) {
        let stamp = Int(Date().timeIntervalSince1970)
        let base = url.deletingPathExtension().lastPathComponent
        let fileManager = FileManager.default
        for (source, suffix) in zip(storeFiles(at: url), ["", "-wal", "-shm"]) where fileManager.fileExists(atPath: source.path()) {
            let target = url.deletingLastPathComponent().appending(path: "\(base)-corrupt-\(stamp).\(url.pathExtension)\(suffix)")
            do {
                try fileManager.moveItem(at: source, to: target)
            } catch {
                logger.error(
                    """
                    Couldn't move \(source.lastPathComponent, privacy: .public) aside: \
                    \(error.localizedDescription, privacy: .public)
                    """
                )
                try? fileManager.removeItem(at: source)
            }
        }
    }

    private static func removeStore(at url: URL) {
        for file in storeFiles(at: url) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}
