import Foundation
import Testing
@testable import screen

struct RecordingAccountingTests {
    @Test func concurrentConfirmationsAreAppliedOnceAndSurviveReload() async throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        let day = DailyUsage.today
        let accepted = try await withThrowingTaskGroup(of: Bool.self) { group in
            for index in 0..<12 {
                group.addTask {
                    let text = index.isMultiple(of: 2)
                    let changes: [RecordingRule: Int] = text ? [.text: 4] : [.image: -2]
                    return try !RecordingAccounting.apply(changes, day: day, at: url).isEmpty
                }
            }
            var count = 0
            for try await applied in group where applied { count += 1 }
            return count
        }
        #expect(accepted == 2)
        let ledger = try RecordingAccounting.read(day: day, at: url)
        #expect(ledger.total == 2)
        #expect(ledger.entries.count == 2)
        #expect(try RecordingAccounting.read(day: "another day", at: url).total == 0)
        #expect(try RecordingAccounting.apply([.text: 4], day: "yesterday", at: url).isEmpty)
    }

    @Test func adjustmentCrossesShieldThresholdWithoutChangingMinutes() {
        var config = BatteryConfig()
        config.blockEnabled = true
        config.baseLevel = 10
        let usage = DailyUsage(bad: 12)
        let empty = config.battery(for: usage, coding: 2)
        let charged = config.battery(for: usage, coding: 2, recording: 3)
        #expect(config.shouldBlock(empty))
        #expect(!config.shouldBlock(charged))
        #expect(charged.bad == empty.bad && charged.good == empty.good)
        #expect(charged.level == 0.03)
        let drained = config.battery(for: usage, coding: 2, recording: -3)
        #expect(config.shouldBlock(drained))
        #expect(BlockMessage(config: config, usage: usage, coding: 2, recording: -3).level == drained.level)
        #expect(BlockMessage.goodMinutesNeeded(config: config, usage: usage, coding: 2, recording: -3) == 4)
    }

    @Test func changingModesKeepsPreviouslyEarnedAppCredit() {
        var policy = CreditPolicy()
        policy.change(to: .combined, minutes: 8, rate: 2, today: "Monday")
        #expect(policy.points(minutes: 18, rate: 2, today: "Monday") == 16)
        policy.change(to: .app, minutes: 18, rate: 2, today: "Monday")
        #expect(policy.points(minutes: 20, rate: 2, today: "Monday") == 20)
        #expect(policy.points(minutes: 2, rate: 2, today: "Tuesday") == 4)
    }

    @Test func combinedRequiresConfirmedUsageDuringMatchingWindow() {
        var account = RecordingAccount(day: DailyUsage.today)
        let start = Date.now
        account.settle(since: start, through: start + 125, rate: 2, combined: true)
        #expect(account.total == 0)
        account.verifiedMinutes = 1
        account.settle(since: start, through: start + 125, rate: 2, combined: true)
        account.settle(since: start, through: start + 130, rate: 2, combined: true)
        #expect(account.qualifiedSeconds == 60)
        #expect(account.total == 2)
        account.verifiedMinutes = 4
        account.settle(since: start, through: start + 150, rate: 2, combined: true)
        #expect(account.qualifiedSeconds == 150)
        #expect(account.total == 5)
    }

    @Test func lateUsageCreditsOnlyItsOriginalWindow() {
        var account = RecordingAccount(day: DailyUsage.today)
        let window = UUID()
        let start = Date.now
        account.window = window
        account.close(id: window, start: start, lastMatch: start + 65, stoppedAt: start + 70, rate: 2)
        account.window = UUID()
        account.report(minutes: 1, for: window, at: start + 90)
        account.report(minutes: 1, for: window, at: start + 91)
        #expect(account.qualifiedSeconds == 55)
        #expect(account.verifiedMinutes == nil)
    }

    @Test func delayedConfirmationSurvivesReopenAndCreditsOriginalSessionOnce() throws {
        let session = UUID()
        let window = UUID()
        let start = Date.now
        var account = RecordingAccount(day: DailyUsage.today)
        account.activeSessionID = session
        account.window = window
        account.recordMatch(session: session, first: start, seconds: 65)
        account.close(id: window, start: start, lastMatch: start + 65, stoppedAt: start + 65, rate: 2)
        var reopened = try JSONDecoder().decode(RecordingAccount.self, from: JSONEncoder().encode(account))
        reopened.activeSessionID = UUID()
        reopened.window = UUID()
        for _ in 0..<2 { reopened.report(minutes: 1, for: window, at: start + 80) }
        #expect(reopened.sessions?[session]?.matched == 65)
        #expect(reopened.sessions?[session]?.qualified == 60)
        #expect(reopened.sessions?[session]?.points == 2)
        #expect(reopened.total == 2)
    }

    @Test func olderSettingsKeepDetectionsNeutral() throws {
        let config = try JSONDecoder().decode(BatteryConfig.self, from: Data(#"{"baseLevel":75}"#.utf8))
        #expect(config.baseLevel == 75)
        #expect(config.textMatchPoints == 0 && config.imageMatchPoints == 0)
    }
}
