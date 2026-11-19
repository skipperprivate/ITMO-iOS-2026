import Foundation

@MainActor
protocol LocalNotificationScheduling {
    func ensureAuthorization(requestIfNeeded: Bool) async -> Bool
    func replaceReminders(_ reminders: [EventReminder]) async throws
}

struct EventReminder: Sendable {
    let id: UUID
    let title: String
    let date: Date
}
