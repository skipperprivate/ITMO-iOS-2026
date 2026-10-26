//
//  CityDetailViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

@Observable
@MainActor
final class CityDetailViewModel {
    enum State {
        case loading
        case loaded(CityWeatherSnapshot)
        case failed(RepositoryError)
    }

    // Forecast models update every 15 min–1 h; older data is refetched when the screen shows up again.
    static let staleInterval: TimeInterval = 10 * 60

    let city: City
    private(set) var state: State = .loading
    // A failed refresh while older data stays on screen: shown as a banner, never replaces the data.
    private(set) var refreshError: RepositoryError?
    private(set) var lastUpdated: Date?

    private let weatherRepository: WeatherRepositoryProtocol
    private let now: () -> Date
    @ObservationIgnored private var inFlight: Task<Void, Never>?

    init(city: City, weatherRepository: WeatherRepositoryProtocol, now: @escaping () -> Date = Date.init) {
        self.city = city
        self.weatherRepository = weatherRepository
        self.now = now
    }

    var snapshot: CityWeatherSnapshot? {
        if case .loaded(let snapshot) = state { return snapshot }
        return nil
    }

    var isStale: Bool {
        guard let lastUpdated else { return true }
        return now().timeIntervalSince(lastUpdated) >= Self.staleInterval
    }

    // Appearance, page swipes, return from background: fetch only if there is nothing fresh.
    func loadIfNeeded() async {
        guard snapshot == nil || isStale else { return }
        await load()
    }

    // Pull-to-refresh and "Повторить".
    func refresh() async {
        await load()
    }

    // Connection is back: retry whatever failed while offline.
    func recoverAfterReconnect() async {
        let hasFailed = if case .failed = state { true } else { false }
        guard hasFailed || refreshError != nil else { return }
        await load()
    }

    // Single flight: overlapping triggers (appearance + pull-to-refresh) share one load.
    // Unstructured on purpose — swiping a page away must not throw the response away.
    private func load() async {
        if let inFlight {
            await inFlight.value
            return
        }
        let task = Task { await performLoad() }
        inFlight = task
        await task.value
        inFlight = nil
    }

    private func performLoad() async {
        if snapshot == nil { state = .loading }
        do {
            let snapshot = try await weatherRepository.snapshot(for: city)
            state = .loaded(snapshot)
            refreshError = nil
            lastUpdated = now()
        } catch {
            let error = RepositoryError.from(error)
            if snapshot == nil {
                state = .failed(error)
            } else {
                refreshError = error
            }
        }
    }
}
