//
//  FavoritesSchema.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation
import SwiftData

// The user's own data: any change to these models ships as a new schema version plus a stage
// in FavoritesMigrationPlan, otherwise the store fails to open and is moved aside.
nonisolated enum FavoritesSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [FavoriteCityRecord.self, SeedRecord.self] }

    @Model
    final class FavoriteCityRecord {
        @Attribute(.unique) var cityID: String
        var name: String
        var region: String
        var country: String
        var latitude: Double
        var longitude: Double
        var timeZoneIdentifier: String
        // Always 0..<count; rewritten on every reorder or removal.
        var sortIndex: Int
        var addedAt: Date

        init(city: City, sortIndex: Int, addedAt: Date) {
            cityID = city.id
            name = city.name
            region = city.region
            country = city.country
            latitude = city.latitude
            longitude = city.longitude
            timeZoneIdentifier = city.timeZoneIdentifier
            self.sortIndex = sortIndex
            self.addedAt = addedAt
        }
    }

    // Exists once the default cities went in. Saved together with them, so seeding is atomic and
    // a user who deleted every city doesn't get them back; a store reset after corruption does.
    @Model
    final class SeedRecord {
        var seededAt: Date

        init(seededAt: Date) {
            self.seededAt = seededAt
        }
    }
}

nonisolated enum FavoritesMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [FavoritesSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

typealias FavoriteCityRecord = FavoritesSchemaV1.FavoriteCityRecord
typealias SeedRecord = FavoritesSchemaV1.SeedRecord

nonisolated extension FavoriteCityRecord {
    var city: City {
        City(
            id: cityID,
            name: name,
            region: region,
            country: country,
            latitude: latitude,
            longitude: longitude,
            timeZoneIdentifier: timeZoneIdentifier
        )
    }

    func update(from city: City) {
        name = city.name
        region = city.region
        country = city.country
        latitude = city.latitude
        longitude = city.longitude
        timeZoneIdentifier = city.timeZoneIdentifier
    }
}
