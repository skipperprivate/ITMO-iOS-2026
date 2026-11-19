import Dispatch
import SwiftData

nonisolated final class BackgroundModelExecutor: SerialModelExecutor, @unchecked Sendable {
    let modelContext: ModelContext
    private let queue = DispatchSerialQueue(label: "MiniTwitter.TweetCache", qos: .userInitiated)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func enqueue(_ job: consuming ExecutorJob) {
        queue.enqueue(job)
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        queue.asUnownedSerialExecutor()
    }
}
