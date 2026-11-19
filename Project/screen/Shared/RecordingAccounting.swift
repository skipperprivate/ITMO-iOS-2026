import Darwin
import Foundation

nonisolated enum RecordingRule: String, Codable {
    case text, image
}

nonisolated struct ClosedMatch: Codable {
    var sessionID: UUID?
    var duration: Double
    var tail: Double
    var settled: Double
    var rate: Double
}

nonisolated struct RecordingSessionCredit: Codable, Identifiable, Equatable {
    var id: UUID
    var firstMatch: Date
    var matched = 0.0
    var qualified = 0.0
    var points = 0.0
    var qualifiedByRate: [Double: Double] = [:]
}

nonisolated struct RecordingAccount: Codable {
    var day: String
    private(set) var entries: [String: Int] = [:]
    // Optional fields also decode the original daily, one-time adjustments.
    var qualifiedSeconds: Double?
    var earnedPoints: Double?
    var sessions: [UUID: RecordingSessionCredit]?
    var activeSessionID: UUID?
    var window: UUID?
    var closed: [UUID: ClosedMatch]?
    var reportedAt: Date?
    var verifiedMinutes: Int?
    var settledSeconds: Double?
    var lastEnd: Date?
    var total: Double { Double(entries.values.reduce(0, +)) + (earnedPoints ?? 0) }

    mutating func recordMatch(session: UUID, first: Date, seconds: Double) {
        if sessions == nil { sessions = [:] }
        sessions?[session, default: RecordingSessionCredit(id: session, firstMatch: first)].matched += max(0, seconds)
    }

    private mutating func credit(seconds: Double, rate: Double, session: UUID?) {
        let points = seconds / 60 * rate
        qualifiedSeconds = (qualifiedSeconds ?? 0) + seconds
        earnedPoints = (earnedPoints ?? 0) + points
        if let session {
            sessions?[session]?.qualified += seconds
            sessions?[session]?.points += points
            sessions?[session]?.qualifiedByRate[rate, default: 0] += seconds
        }
    }

    mutating func settle(since start: Date, through end: Date, rate: Double, combined: Bool) {
        if combined, let reportedAt, reportedAt > end { return }
        let elapsed = max(0, end.timeIntervalSince(start))
        let verified = combined ? min(elapsed, Double(verifiedMinutes ?? 0) * 60) : elapsed
        let delta = verified - (settledSeconds ?? 0)
        guard delta > 0 else { return }
        credit(seconds: delta, rate: rate, session: activeSessionID)
        settledSeconds = verified
        lastEnd = end
    }

    mutating func close(id: UUID, start: Date, lastMatch: Date, stoppedAt: Date, rate: Double) {
        guard window == id else { return }
        let duration = max(0, lastMatch.timeIntervalSince(start))
        if duration > (settledSeconds ?? 0) {
            if closed == nil { closed = [:] }
            closed?[id] = ClosedMatch(sessionID: activeSessionID, duration: duration, tail: max(0, stoppedAt.timeIntervalSince(lastMatch)),
                                      settled: settledSeconds ?? 0, rate: rate)
        }
        window = nil
        report(minutes: verifiedMinutes ?? 0, for: id, at: stoppedAt)
    }

    mutating func report(minutes: Int, for id: UUID, at date: Date) {
        if window == id {
            if minutes > (verifiedMinutes ?? 0) {
                verifiedMinutes = minutes
                reportedAt = date
            }
        } else if var match = closed?[id] {
            // Subtract all time between the last matching frame and monitor shutdown.
            let verified = min(match.duration, max(0, Double(minutes) * 60 - match.tail))
            let delta = verified - match.settled
            guard delta > 0 else { return }
            credit(seconds: delta, rate: match.rate, session: match.sessionID)
            match.settled = verified
            closed?[id] = verified == match.duration ? nil : match
        }
    }

    mutating func apply(_ points: Int, rule: RecordingRule) -> Bool {
        guard (-20...20).contains(points), points != 0, entries[rule.rawValue] == nil else { return false }
        entries[rule.rawValue] = points
        return true
    }
}

nonisolated enum RecordingAccounting {
    // A separate, stable lock file survives atomic replacement of the ledger.
    static func withLock<T>(_ body: () throws -> T) throws -> T {
        guard let url = AppGroup.file("battery-policy.lock") else { throw CocoaError(.fileNoSuchFile) }
        let descriptor = open(url.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(descriptor) }
        guard flock(descriptor, LOCK_EX) == 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { flock(descriptor, LOCK_UN) }
        return try body()
    }

    static func read(day: String, at url: URL) throws -> RecordingAccount {
        do {
            let account = try JSONDecoder().decode(RecordingAccount.self, from: Data(contentsOf: url))
            if account.day == day { return account }
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {}
        return RecordingAccount(day: day)
    }

    static var today: RecordingAccount {
        let day = DailyUsage.today
        if let url = AppGroup.file("recording-account.json"), let account = try? read(day: day, at: url) { return account }
        return RecordingAccount(day: day)
    }

    @discardableResult
    static func update(at location: URL? = nil, _ body: (inout RecordingAccount) -> Void) throws -> RecordingAccount {
        guard let url = location ?? AppGroup.file("recording-account.json") else { throw CocoaError(.fileNoSuchFile) }
        return try withLock {
            var account = try read(day: DailyUsage.today, at: url)
            body(&account)
            try JSONEncoder().encode(account).write(to: url, options: .atomic)
            return account
        }
    }

    static func apply(_ adjustments: [RecordingRule: Int], day: String, at location: URL? = nil) throws -> [RecordingRule: Int] {
        guard let url = location ?? AppGroup.file("recording-account.json") else { throw CocoaError(.fileNoSuchFile) }
        return try withLock {
            guard day == DailyUsage.today else { return [:] }
            var account = try read(day: day, at: url)
            let applied = adjustments.filter { account.apply($0.value, rule: $0.key) }
            if !applied.isEmpty { try JSONEncoder().encode(account).write(to: url, options: .atomic) }
            return applied
        }
    }
}
