//
//  GeocodingRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Errors are RepositoryError or CancellationError.
nonisolated protocol GeocodingRepositoryProtocol: Sendable {
    // Shorter queries return nothing without a request; the UI shows a hint instead of "not found".
    var minimumQueryLength: Int { get }

    func searchCities(matching query: String) async throws -> [City]
}
