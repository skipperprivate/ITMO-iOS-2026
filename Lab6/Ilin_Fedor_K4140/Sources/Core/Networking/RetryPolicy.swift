import Foundation

nonisolated struct RetryPolicy: Sendable {
    var maxAttempts: Int
    var baseDelay: TimeInterval
    var maxDelay: TimeInterval
    var jitter: ClosedRange<Double> = 0.8...1.2

    static let `default` = RetryPolicy(maxAttempts: 3, baseDelay: 0.5, maxDelay: 5)
    static let none = RetryPolicy(maxAttempts: 1, baseDelay: 0, maxDelay: 0)

    func delay(afterAttempt attempt: Int, failedWith error: NetworkError) -> TimeInterval? {
        guard attempt < maxAttempts, error.isTransient else { return nil }
        if case .rateLimited(let retryAfter?) = error {
            return retryAfter <= maxDelay ? max(0, retryAfter) : nil
        }
        let exponential = baseDelay * pow(2, Double(attempt - 1))
        return min(exponential, maxDelay) * Double.random(in: jitter)
    }
}
