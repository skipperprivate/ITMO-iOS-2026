import Foundation

actor NumberGenerator {
    func generate() -> AsyncStream<Int> {
        AsyncStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    let number = Int.random(in: 1...100)
                    continuation.yield(number)
                    try? await Task.sleep(nanoseconds: 700_000_000)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
