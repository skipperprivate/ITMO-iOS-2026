import Combine
import SwiftData

@MainActor
final class TweetRepositoryProvider: ObservableObject {
    let api: any TwitterAPI
    private let metadataSuite: String?
    private var creationTask: Task<TweetCacheRepository, Never>?

    init(metadataSuite: String? = nil, api: any TwitterAPI = TwitterAPIClient()) {
        self.metadataSuite = metadataSuite
        self.api = api
    }

    func repository(for container: ModelContainer) async -> TweetCacheRepository {
        if let creationTask { return await creationTask.value }

        let metadataSuite = metadataSuite
        let task = Task.detached {
            TweetCacheRepository(modelContainer: container, metadataSuite: metadataSuite)
        }
        creationTask = task
        return await task.value
    }
}
