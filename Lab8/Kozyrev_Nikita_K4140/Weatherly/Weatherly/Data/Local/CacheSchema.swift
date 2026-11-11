//
//  CacheSchema.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import SwiftData

// Disposable data: no versions or migrations. A store that doesn't open with the current models
// is deleted and created again (PersistenceStack), so changing these models is free.
// Payloads are JSON of domain values: they are always read and written whole, never queried inside.
nonisolated enum CacheSchema {
    static var models: [any PersistentModel.Type] { [CachedForecastRecord.self, CachedSearchRecord.self] }

    @Model
    final class CachedForecastRecord {
        // Coordinates and time zone, not the city id: the forecast depends only on the location.
        @Attribute(.unique) var key: String
        var fetchedAt: Date
        var payloadVersion: Int
        var payload: Data

        init(key: String, fetchedAt: Date, payloadVersion: Int, payload: Data) {
            self.key = key
            self.fetchedAt = fetchedAt
            self.payloadVersion = payloadVersion
            self.payload = payload
        }
    }

    @Model
    final class CachedSearchRecord {
        @Attribute(.unique) var query: String
        var fetchedAt: Date
        // Kept apart from the payload: "nothing found" expires sooner and is purged by a predicate.
        var resultCount: Int
        var payloadVersion: Int
        var payload: Data

        init(query: String, fetchedAt: Date, resultCount: Int, payloadVersion: Int, payload: Data) {
            self.query = query
            self.fetchedAt = fetchedAt
            self.resultCount = resultCount
            self.payloadVersion = payloadVersion
            self.payload = payload
        }
    }
}

typealias CachedForecastRecord = CacheSchema.CachedForecastRecord
typealias CachedSearchRecord = CacheSchema.CachedSearchRecord
