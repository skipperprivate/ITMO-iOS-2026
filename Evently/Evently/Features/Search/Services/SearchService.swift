import Foundation

struct SearchService: Sendable {

    @concurrent
    func search(
        query: String,
        events: [Event]
    ) async throws -> [Event] {

        let normalizedQuery = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalizedQuery.isEmpty else {
            return []
        }

        var result: [Event] = []

        for event in events {
            try Task.checkCancellation()

            if event.title.localizedCaseInsensitiveContains(normalizedQuery)
                || event.venue.localizedCaseInsensitiveContains(normalizedQuery)
                || event.city.localizedCaseInsensitiveContains(normalizedQuery) {
                result.append(event)
            }
        }

        return result
    }
}
