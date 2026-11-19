import DeviceActivity
import FamilyControls
import Foundation

/// The monitor only exists during one continuously observed match. Event names identify
/// that window so delayed callbacks from an earlier match cannot qualify another one.
@MainActor
final class MatchedUsage {
    private var config = BatteryConfig()
    private var previous: Date?
    private var firstMatch: Date?
    private(set) var samples = 0
    var sessionID = UUID()
    private var lastRecordedMatch: Date?
    private var window: UUID?
    private var start: Date?
    private var monitoring = false

    private let accountURL: URL?

    init(accountURL: URL? = nil) { self.accountURL = accountURL }

    func configure(_ value: BatteryConfig) {
        if config.credit != value.credit || config.good != value.good || config.goodRate != value.goodRate {
            reset()
        }
        config = value
    }

    var usesScreenCredit: Bool { config.credit.mode != .app }

    var needsAppSelection: Bool {
        config.credit.mode == .combined && config.good.applicationTokens.isEmpty && config.good.categoryTokens.isEmpty
    }

    func waitingForUsage(_ account: RecordingAccount) -> Bool {
        config.credit.mode == .combined && (account.verifiedMinutes ?? 0) == 0
    }

    func reset() {
        if monitoring {
            DeviceActivityCenter().stopMonitoring([.recordingMatch])
            if let window, let start, let previous {
                _ = try? RecordingAccounting.update(at: accountURL) {
                    $0.close(id: window, start: start, lastMatch: previous, stoppedAt: .now, rate: config.goodRate)
                }
                AppBlocker.update()
            }
            monitoring = false
        }
        previous = nil
        lastRecordedMatch = nil
        firstMatch = nil
        samples = 0
        window = nil
        start = nil
    }

    func observe(_ result: ScreenAnalysisResult, at date: Date, options: ScreenAnalysisOptions) throws -> RecordingAccount? {
        let match = result.matchesCondition(options)
        let interval = options.interval
        let required = options.requiredMatches
        if let previous, date <= previous || date.timeIntervalSince(previous) > max(3, interval * 2.5)
            || !Calendar.current.isDate(date, inSameDayAs: previous) {
            reset()
        }
        guard match, config.credit.mode != .app, Calendar.current.isDateInToday(date)
        else { reset(); return nil }
        previous = date
        firstMatch = firstMatch ?? date
        samples += 1
        guard samples >= max(1, required) else { return nil }
        let combined = config.credit.mode == .combined
        let first = firstMatch ?? date
        let matchedDelta = date.timeIntervalSince(lastRecordedMatch ?? first)
        if needsAppSelection {
            let account = try RecordingAccounting.update(at: accountURL) {
                $0.recordMatch(session: sessionID, first: first, seconds: matchedDelta)
            }
            lastRecordedMatch = date
            return account
        }
        if window == nil {
            let id = UUID()
            try RecordingAccounting.update(at: accountURL) { account in
                account.activeSessionID = sessionID
                account.window = id
                account.reportedAt = nil
                account.verifiedMinutes = 0
                account.settledSeconds = 0
                start = max(combined ? Date.now : (firstMatch ?? date), account.lastEnd ?? .distantPast)
            }
            if combined {
                do { try startMonitoring(id) } catch { reset(); throw error }
            }
            window = id
        }
        guard let start else { return nil }
        let account = try RecordingAccounting.update(at: accountURL) { account in
            guard account.window == window else { return }
            account.recordMatch(session: sessionID, first: first, seconds: matchedDelta)
            account.settle(since: start, through: date, rate: config.goodRate, combined: combined)
        }
        lastRecordedMatch = date
        // Re-arm long sessions before exhausting the configured event thresholds.
        if combined, (account.settledSeconds ?? 0) >= 240 * 60 { reset() }
        return account
    }

    private func startMonitoring(_ id: UUID) throws {
        let schedule = DeviceActivitySchedule(intervalStart: DateComponents(hour: 0, minute: 0),
                                              intervalEnd: DateComponents(hour: 23, minute: 59, second: 59), repeats: true)
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        for minute in UsageThresholds.all {
            events[.init("\(id.uuidString).\(minute)")] = DeviceActivityEvent(
                applications: config.good.applicationTokens, categories: config.good.categoryTokens,
                threshold: DateComponents(hour: minute / 60, minute: minute % 60), includesPastActivity: false)
        }
        try DeviceActivityCenter().startMonitoring(.recordingMatch, during: schedule, events: events)
        monitoring = true
    }
}
