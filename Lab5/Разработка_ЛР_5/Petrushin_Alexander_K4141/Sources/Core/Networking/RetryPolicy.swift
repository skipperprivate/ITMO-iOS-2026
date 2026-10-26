//
//  RetryPolicy.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// Exponential backoff with jitter, only for transient errors.
nonisolated struct RetryPolicy: Sendable {
    var maxAttempts: Int
    var baseDelay: TimeInterval
    var maxDelay: TimeInterval
    // Spreads retries of parallel requests so they don't hit the server in lockstep.
    var jitter: ClosedRange<Double> = 0.8...1.2

    static let `default` = RetryPolicy(maxAttempts: 3, baseDelay: 0.5, maxDelay: 5)
    static let none = RetryPolicy(maxAttempts: 1, baseDelay: 0, maxDelay: 0)

    // nil — give up and surface the error.
    func delay(afterAttempt attempt: Int, failedWith error: NetworkError) -> TimeInterval? {
        guard attempt < maxAttempts, error.isTransient else { return nil }
        // Without Retry-After a 429 still gets the short backoff: it may be a momentary concurrency limit,
        // and a quota rejection costs only a couple of cheap extra requests.
        if case .rateLimited(let retryAfter?) = error {
            // Waiting longer than maxDelay would look like a hang; better to fail now.
            return retryAfter <= maxDelay ? max(0, retryAfter) : nil
        }
        let exponential = baseDelay * pow(2, Double(attempt - 1))
        return min(exponential, maxDelay) * Double.random(in: jitter)
    }
}
