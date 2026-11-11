//
//  CoalescingWeatherRepositoryTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import XCTest
@testable import Weatherly

final class CoalescingWeatherRepositoryTests: XCTestCase {
    func testConcurrentRequestsForOneCityShareOneUpstreamCall() async throws {
        let upstream = StubWeatherRepository()
        upstream.hold()
        let repository = CoalescingWeatherRepository(upstream: upstream)

        async let first = repository.snapshot(for: TestCities.moscow)
        async let second = repository.snapshot(for: TestCities.moscow)
        async let third = repository.snapshot(for: TestCities.moscow)
        try await Task.sleep(nanoseconds: 50_000_000)
        upstream.release()
        let results = try await [first, second, third]

        XCTAssertEqual(upstream.callCount, 1)
        XCTAssertTrue(results.allSatisfy { $0.city == TestCities.moscow })
    }

    func testDifferentCitiesAreNotMerged() async throws {
        let upstream = StubWeatherRepository()
        let repository = CoalescingWeatherRepository(upstream: upstream)

        let snapshots = try await repository.snapshots(for: [TestCities.moscow, TestCities.kazan])

        XCTAssertEqual(snapshots.map(\.city), [TestCities.moscow, TestCities.kazan])
        XCTAssertEqual(upstream.callCount, 2)
    }

    // Deduplication only, not a cache: a finished call is not reused.
    func testSequentialRequestsHitUpstreamEachTime() async throws {
        let upstream = StubWeatherRepository()
        let repository = CoalescingWeatherRepository(upstream: upstream)

        _ = try await repository.snapshot(for: TestCities.moscow)
        _ = try await repository.snapshot(for: TestCities.moscow)

        XCTAssertEqual(upstream.callCount, 2)
    }

    func testErrorIsDeliveredToEveryWaiter() async {
        let upstream = StubWeatherRepository { _ in throw RepositoryError.offline }
        upstream.hold()
        let repository = CoalescingWeatherRepository(upstream: upstream)

        async let first = Result.capture { try await repository.snapshot(for: TestCities.moscow) }
        async let second = Result.capture { try await repository.snapshot(for: TestCities.moscow) }
        try? await Task.sleep(nanoseconds: 50_000_000)
        upstream.release()
        let results = await [first, second]

        for result in results {
            XCTAssertThrowsError(try result.get()) { XCTAssertEqual($0 as? RepositoryError, .offline) }
        }
        XCTAssertEqual(upstream.callCount, 1)
    }

    func testCancelledWaiterDoesNotCancelOthers() async throws {
        let upstream = StubWeatherRepository()
        upstream.hold()
        let repository = CoalescingWeatherRepository(upstream: upstream)

        let cancelled = Task { try await repository.snapshot(for: TestCities.moscow) }
        let kept = Task { try await repository.snapshot(for: TestCities.moscow) }
        try await Task.sleep(nanoseconds: 50_000_000)
        cancelled.cancel()
        try await Task.sleep(nanoseconds: 50_000_000)
        upstream.release()

        let snapshot = try await kept.value
        XCTAssertEqual(snapshot.city, TestCities.moscow)
        do {
            _ = try await cancelled.value
            XCTFail("Expected cancellation")
        } catch {
            XCTAssertTrue(error is CancellationError, "Got \(error)")
        }
    }
}

private extension Result where Failure == Error {
    static func capture(_ body: () async throws -> Success) async -> Result {
        do {
            return .success(try await body())
        } catch {
            return .failure(error)
        }
    }
}
