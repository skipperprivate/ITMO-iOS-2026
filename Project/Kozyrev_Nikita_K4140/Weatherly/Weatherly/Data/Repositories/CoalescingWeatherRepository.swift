//
//  CoalescingWeatherRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// Decorator: concurrent requests for the same city share one network call (e.g. Home and Places
// loading at once). Nothing is kept after the call finishes — this is deduplication, not a cache.
actor CoalescingWeatherRepository: WeatherRepositoryProtocol {
    private nonisolated struct InFlight {
        let id: UUID
        let task: Task<CityWeatherSnapshot, Error>
        var waiters: Int
    }

    private let upstream: WeatherRepositoryProtocol
    private var inFlight: [String: InFlight] = [:]

    init(upstream: WeatherRepositoryProtocol) {
        self.upstream = upstream
    }

    func snapshot(for city: City) async throws -> CityWeatherSnapshot {
        let key = Self.key(for: city)
        let entry: InFlight
        if var existing = inFlight[key] {
            existing.waiters += 1
            entry = existing
        } else {
            let upstream = upstream
            entry = InFlight(id: UUID(), task: Task { try await upstream.snapshot(for: city) }, waiters: 1)
        }
        inFlight[key] = entry

        defer { finish(key: key, id: entry.id) }
        let snapshot = try await withTaskCancellationHandler {
            try await entry.task.value
        } onCancel: {
            Task { await self.cancelWaiter(key: key, id: entry.id) }
        }
        // The shared call may have succeeded for others while this caller was cancelled.
        try Task.checkCancellation()
        return snapshot
    }

    // Coordinates are part of the key: the same id must not be answered with another place's weather.
    private nonisolated static func key(for city: City) -> String {
        "\(city.id)|\(city.latitude)|\(city.longitude)|\(city.timeZoneIdentifier)"
    }

    private func finish(key: String, id: UUID) {
        guard inFlight[key]?.id == id else { return }
        inFlight[key] = nil
    }

    // The network call is cancelled only when nobody is waiting for it any more.
    private func cancelWaiter(key: String, id: UUID) {
        guard var entry = inFlight[key], entry.id == id else { return }
        entry.waiters -= 1
        if entry.waiters <= 0 {
            entry.task.cancel()
            inFlight[key] = nil
        } else {
            inFlight[key] = entry
        }
    }
}
