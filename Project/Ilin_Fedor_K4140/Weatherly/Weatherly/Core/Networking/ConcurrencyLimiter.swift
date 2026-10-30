//
//  ConcurrencyLimiter.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// Async semaphore: at most `limit` operations run at once, the rest wait in FIFO order.
// A cancelled waiter leaves the queue immediately instead of holding its place.
actor ConcurrencyLimiter {
    private let limit: Int
    private var running = 0
    private var waiters: [(id: UUID, continuation: CheckedContinuation<Void, Error>)] = []

    init(limit: Int) {
        self.limit = max(1, limit)
    }

    nonisolated func run<Value>(_ operation: () async throws -> Value) async throws -> Value {
        try await acquire()
        do {
            let value = try await operation()
            await release()
            return value
        } catch {
            await release()
            throw error
        }
    }

    private func acquire() async throws {
        try Task.checkCancellation()
        guard running >= limit else {
            running += 1
            return
        }
        let id = UUID()
        try await withTaskCancellationHandler {
            try await enqueue(id)
        } onCancel: {
            Task { await self.cancelWaiter(id) }
        }
    }

    private func enqueue(_ id: UUID) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            // Cancelled before reaching the queue: onCancel's cleanup would find nothing to remove.
            if Task.isCancelled {
                continuation.resume(throwing: CancellationError())
            } else {
                waiters.append((id, continuation))
            }
        }
    }

    // The slot passes straight to the next waiter, so `running` never dips and lets a newcomer jump the queue.
    private func release() {
        if waiters.isEmpty {
            running -= 1
        } else {
            waiters.removeFirst().continuation.resume()
        }
    }

    private func cancelWaiter(_ id: UUID) {
        guard let index = waiters.firstIndex(where: { $0.id == id }) else { return }
        waiters.remove(at: index).continuation.resume(throwing: CancellationError())
    }
}
