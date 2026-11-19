import FamilyControls
import Foundation
import ManagedSettings

nonisolated enum Protection: String, Codable, CaseIterable, Identifiable, Sendable {
    case none, password, math, morse

    var id: Self { self }
    var title: String {
        switch self {
        case .none: "None"
        case .password: "Password"
        case .math: "Math task"
        case .morse: "Morse code"
        }
    }
}

nonisolated enum Difficulty: String, Codable, CaseIterable, Identifiable, Sendable {
    case easy, medium, hard

    var id: Self { self }
    var title: String { rawValue.capitalized }
}

nonisolated enum CreditMode: String, Codable, CaseIterable {
    case app = "Selected app"
    case screen = "Screen condition"
    case combined = "Selected app and screen condition"
}

nonisolated struct CreditPolicy: Codable, Equatable {
    var mode = CreditMode.app
    var day = ""
    var priorAppPoints = 0.0
    var baselineMinutes = 0.0

    func points(minutes: Double, rate: Double, today: String) -> Double {
        let carried = today == day ? priorAppPoints : 0
        let baseline = today == day ? baselineMinutes : 0
        return carried + (mode == .app ? max(0, minutes - baseline) * rate : 0)
    }

    mutating func change(to mode: CreditMode, minutes: Double, rate: Double, today: String) {
        guard self.mode != mode else { return }
        priorAppPoints = points(minutes: minutes, rate: rate, today: today)
        baselineMinutes = minutes
        day = today
        self.mode = mode
    }
}

nonisolated struct BatteryConfig: Codable, Equatable {
    static let rateRange = 0.0...20.0
    static let baseRange = 0.0...100.0
    static let logLimits = [10, 30, 50, 100]

    var good = FamilyActivitySelection()
    var bad = FamilyActivitySelection()
    var baseLevel = 50.0
    var goodRate = 1.0
    var badRate = 1.0
    var goodURL = ""
    var badURL = ""
    var protection = Protection.none
    var difficulty = Difficulty.medium
    var passwordHash = ""
    var blockEnabled = false
    var logLimit = 30
    var coding = CodingConfig()
    var credit = CreditPolicy()
    var textMatchPoints = 0
    var imageMatchPoints = 0

    var isProtected: Bool {
        protection != .none && !(protection == .password && passwordHash.isEmpty)
    }

    static func endpoint(from string: String) -> URL? {
        guard let url = URL(string: string.trimmingCharacters(in: .whitespaces)),
              url.scheme == "https", url.host() != nil
        else { return nil }
        return url
    }

    func battery(good goodTime: TimeInterval, bad badTime: TimeInterval, coding: Double = 0, recording: Double = 0) -> Battery {
        Battery(
            base: baseLevel,
            coding: coding,
            recording: recording,
            good: goodTime,
            bad: badTime,
            goodCharge: credit.points(minutes: goodTime / 60, rate: goodRate, today: DailyUsage.today),
            badDrain: badTime / 60 * badRate,
            goodRate: goodRate,
            badRate: badRate,
            blockEnabled: blockEnabled
        )
    }

    func battery(for usage: DailyUsage, coding: Double = 0, recording: Double = 0) -> Battery {
        battery(good: TimeInterval(usage.good * 60), bad: TimeInterval(usage.bad * 60), coding: coding, recording: recording)
    }

    func shouldBlock(_ battery: Battery) -> Bool {
        blockEnabled && battery.level <= 0
    }
}

extension BatteryConfig {
    nonisolated init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        good = try container.decodeIfPresent(FamilyActivitySelection.self, forKey: .good) ?? good
        bad = try container.decodeIfPresent(FamilyActivitySelection.self, forKey: .bad) ?? bad
        baseLevel = try container.decodeIfPresent(Double.self, forKey: .baseLevel) ?? baseLevel
        goodRate = try container.decodeIfPresent(Double.self, forKey: .goodRate) ?? goodRate
        badRate = try container.decodeIfPresent(Double.self, forKey: .badRate) ?? badRate
        goodURL = try container.decodeIfPresent(String.self, forKey: .goodURL) ?? goodURL
        badURL = try container.decodeIfPresent(String.self, forKey: .badURL) ?? badURL
        protection = try container.decodeIfPresent(Protection.self, forKey: .protection) ?? protection
        difficulty = try container.decodeIfPresent(Difficulty.self, forKey: .difficulty) ?? difficulty
        passwordHash = try container.decodeIfPresent(String.self, forKey: .passwordHash) ?? passwordHash
        blockEnabled = try container.decodeIfPresent(Bool.self, forKey: .blockEnabled) ?? blockEnabled
        logLimit = try container.decodeIfPresent(Int.self, forKey: .logLimit) ?? logLimit
        credit = try container.decodeIfPresent(CreditPolicy.self, forKey: .credit) ?? CreditPolicy()
        textMatchPoints = try container.decodeIfPresent(Int.self, forKey: .textMatchPoints) ?? 0
        imageMatchPoints = try container.decodeIfPresent(Int.self, forKey: .imageMatchPoints) ?? 0
        coding = try container.decodeIfPresent(CodingConfig.self, forKey: .coding) ?? coding
    }
}

nonisolated struct AppUsage: Identifiable {
    let token: ApplicationToken
    let duration: TimeInterval

    var id: ApplicationToken { token }

    static func top(_ durations: [ApplicationToken: TimeInterval], count: Int = 3) -> [AppUsage] {
        durations
            .map { AppUsage(token: $0.key, duration: $0.value) }
            .sorted { $0.duration > $1.duration }
            .prefix(count)
            .map { $0 }
    }
}

nonisolated struct Battery {
    var base = 50.0
    var coding = 0.0
    var recording = 0.0
    var codingBonus = CodingBonus()
    var good: TimeInterval = 0
    var bad: TimeInterval = 0
    var goodCharge = 0.0
    var badDrain = 0.0
    var goodRate = 0.0
    var badRate = 0.0
    var blockEnabled = false
    var qualifiedSeconds = 0.0
    var creditMode = CreditMode.app
    var goodApps: [AppUsage] = []
    var badApps: [AppUsage] = []

    var level: Double { (base + goodCharge + coding + recording - badDrain) / 100 }

    var badMinutesLeft: Double? {
        badRate > 0 && level > 0 ? level * 100 / badRate : nil
    }
}
