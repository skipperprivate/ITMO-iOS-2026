import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published private(set) var results: [City] = []
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?
    private let service: any CityService
    private var latestSearchID = UUID()

    init(service: any CityService) {
        self.service = service
    }

    func search(_ query: String) async {
        let searchID = UUID()
        latestSearchID = searchID
        results = []
        errorMessage = nil
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            isSearching = false
            return
        }
        isSearching = true
        defer {
            if latestSearchID == searchID { isSearching = false }
        }
        do {
            try await Task.sleep(for: .milliseconds(300))
            try Task.checkCancellation()
            let cities = try await service.search(trimmed)
            try Task.checkCancellation()
            guard latestSearchID == searchID else { return }
            results = cities
        } catch is CancellationError {
        } catch {
            guard latestSearchID == searchID, !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }
}
