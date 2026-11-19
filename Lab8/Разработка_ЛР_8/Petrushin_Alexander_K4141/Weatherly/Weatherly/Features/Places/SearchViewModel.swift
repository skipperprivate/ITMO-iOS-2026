//
//  SearchViewModel.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

@Observable
@MainActor
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case tooShort(minimumLength: Int)
        case results([City])
        case empty
        case failed(RepositoryError)
    }

    static let debounceNanoseconds: UInt64 = 350_000_000

    var query: String = "" {
        didSet {
            if query != oldValue { scheduleSearch(debounced: true) }
        }
    }
    private(set) var state: State = .idle
    // Separate from state: previous results stay on screen while the next query is in flight.
    private(set) var isSearching = false

    private let geocodingRepository: GeocodingRepositoryProtocol
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(geocodingRepository: GeocodingRepositoryProtocol) {
        self.geocodingRepository = geocodingRepository
    }

    var isActive: Bool {
        !trimmedQuery.isEmpty
    }

    func retry() {
        scheduleSearch(debounced: false)
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Debounce: sleep inside the task and cancel the previous one on every keystroke,
    // so only the last pause in typing reaches the network.
    private func scheduleSearch(debounced: Bool) {
        searchTask?.cancel()
        let term = trimmedQuery
        let minimumLength = geocodingRepository.minimumQueryLength
        guard !term.isEmpty else {
            isSearching = false
            state = .idle
            return
        }
        guard term.count >= minimumLength else {
            isSearching = false
            state = .tooShort(minimumLength: minimumLength)
            return
        }

        isSearching = true
        searchTask = Task { [weak self, geocodingRepository] in
            if debounced {
                try? await Task.sleep(nanoseconds: Self.debounceNanoseconds)
            }
            guard !Task.isCancelled else { return }
            let newState: State
            do {
                let cities = try await geocodingRepository.searchCities(matching: term)
                newState = cities.isEmpty ? .empty : .results(cities)
            } catch is CancellationError {
                return
            } catch {
                newState = .failed(RepositoryError.from(error))
            }
            // A newer keystroke owns the state now.
            guard !Task.isCancelled, let self else { return }
            state = newState
            isSearching = false
        }
    }
}
