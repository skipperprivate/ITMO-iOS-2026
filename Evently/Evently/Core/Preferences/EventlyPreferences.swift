import Foundation

enum EventlyPreferences {
    static let reminderLeadTimeKey = "evently.settings.reminderLeadTime"
}

enum ReminderLeadTime: Int, CaseIterable, Identifiable {
    case oneHour = 3600
    case threeHours = 10800
    case oneDay = 86400

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .oneHour: "За 1 час"
        case .threeHours: "За 3 часа"
        case .oneDay: "За 1 день"
        }
    }
}
