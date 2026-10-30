//
//  MockWeatherRepository.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

#if DEBUG
import Foundation

// Previews only; the app always talks to Open-Meteo. `failure` renders the error states.
nonisolated final class MockWeatherRepository: WeatherRepositoryProtocol, Sendable {
    private let failure: RepositoryError?

    init(failure: RepositoryError? = nil) {
        self.failure = failure
    }

    func snapshot(for city: City) async throws -> CityWeatherSnapshot {
        if let failure { throw failure }
        return MockData.snapshot(for: city)
    }
}
#endif
