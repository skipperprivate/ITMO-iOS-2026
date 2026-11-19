import XCTest
@testable import Weatherly

final class ConcurrencyLimiterTests: XCTestCase {
    private actor Gauge {
        private(set) var current = 0
        private(set) var peak = 0

        func enter() {
            current += 1
            peak = max(peak, current)
        }

        func leave() {
            current -= 1
        }
    }

    func testNeverRunsMoreThanLimit() async throws {
        let limiter = ConcurrencyLimiter(limit: 3)
        let gauge = Gauge()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try await limiter.run {
                        await gauge.enter()
                        try await Task.sleep(nanoseconds: 10_000_000)
                        await gauge.leave()
                    }
                }
            }
            try await group.waitForAll()
        }

        let peak = await gauge.peak
        XCTAssertEqual(peak, 3)
    }

    func testFailedOperationReleasesItsSlot() async throws {
        let limiter = ConcurrencyLimiter(limit: 1)

        _ = try? await limiter.run { throw URLError(.timedOut) }
        let value = try await limiter.run { 42 }

        XCTAssertEqual(value, 42)
    }

    func testCancelledWaiterLeavesQueueWithoutTakingSlot() async throws {
        let limiter = ConcurrencyLimiter(limit: 1)
        let holder = Task { try await limiter.run { try await Task.sleep(nanoseconds: 300_000_000) } }
        try await Task.sleep(nanoseconds: 50_000_000)

        let waiter = Task { try await limiter.run { "should not run" } }
        try await Task.sleep(nanoseconds: 50_000_000)
        waiter.cancel()

        do {
            _ = try await waiter.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError, "Got \(error)")
        }
        try await holder.value
        let value = try await limiter.run { "free" }
        XCTAssertEqual(value, "free")
    }
}
