import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published private(set) var results: [City] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    private let service: any CityService

    init(service: any CityService) {
        self.service = service
    }

    var availableCities: [City] { service.availableCities }

    func search(_ query: String) async {
        results = []
        errorMessage = nil
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isSearching = false
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            let cities = try await service.search(trimmed)
            try Task.checkCancellation()
            results = cities
        } catch is CancellationError {
        } catch {
            errorMessage = "Не удалось найти города"
        }
    }
}
