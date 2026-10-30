//
//  FavoritesStore.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation
import SwiftData

// All SwiftData work on favourites. @Model objects aren't Sendable, so only City values leave the actor.
@ModelActor
actor FavoritesStore {
    private var isSeeded = false

    func seedIfNeeded(with cities: [City], now: Date) throws {
        // Each mutation is committed explicitly, with rollback on failure.
        modelContext.autosaveEnabled = false
        guard !isSeeded else { return }
        if try modelContext.fetchCount(FetchDescriptor<SeedRecord>()) == 0 {
            // A store that already has cities (e.g. restored from a backup) is never topped up.
            if try modelContext.fetchCount(FetchDescriptor<FavoriteCityRecord>()) == 0 {
                for (index, city) in cities.enumerated() {
                    modelContext.insert(FavoriteCityRecord(city: city, sortIndex: index, addedAt: now))
                }
            }
            modelContext.insert(SeedRecord(seededAt: now))
            try save()
        }
        isSeeded = true
    }

    func favorites() throws -> [City] {
        try records().map(\.city)
    }

    func add(_ city: City, limit: Int, now: Date) throws {
        let records = try records()
        if let existing = records.first(where: { $0.cityID == city.id }) {
            existing.update(from: city)
        } else {
            guard records.count < limit else { throw RepositoryError.favoritesLimitReached }
            modelContext.insert(FavoriteCityRecord(city: city, sortIndex: records.count, addedAt: now))
        }
        try save()
    }

    func remove(id: City.ID) throws {
        let records = try records()
        guard let removed = records.first(where: { $0.cityID == id }) else { return }
        modelContext.delete(removed)
        renumber(records.filter { $0.cityID != id })
        try save()
    }

    func reorder(_ ids: [City.ID]) throws {
        let records = try records()
        let byID = Dictionary(records.map { ($0.cityID, $0) }, uniquingKeysWith: { first, _ in first })
        var seen = Set<City.ID>()
        let listed = ids.filter { seen.insert($0).inserted }.compactMap { byID[$0] }
        let rest = records.filter { !seen.contains($0.cityID) }
        renumber(listed + rest)
        try save()
    }

    // addedAt breaks ties, so a damaged order still comes out stable.
    private func records() throws -> [FavoriteCityRecord] {
        try modelContext.fetch(FetchDescriptor<FavoriteCityRecord>(
            sortBy: [SortDescriptor(\.sortIndex), SortDescriptor(\.addedAt)]
        ))
    }

    private func renumber(_ ordered: [FavoriteCityRecord]) {
        for (index, record) in ordered.enumerated() where record.sortIndex != index {
            record.sortIndex = index
        }
    }

    // A failed save must not leave half-applied changes in the context for the next call to persist.
    private func save() throws {
        guard modelContext.hasChanges else { return }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
