import Foundation
import UserNotifications

@MainActor
final class UNLocalNotificationScheduler: LocalNotificationScheduling {
    private let center: UNUserNotificationCenter
    private let prefix = "evently.reminder."

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func ensureAuthorization(requestIfNeeded: Bool) async -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            guard requestIfNeeded else { return false }
            do {
                return try await center.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                return false
            }
        @unknown default:
            return false
        }
    }

    func replaceReminders(_ reminders: [EventReminder]) async throws {
        let existing = await center.pendingNotificationRequests()
        let existingIDs = existing.map(\.identifier).filter { $0.hasPrefix(prefix) }
        let desiredIDs = Set(reminders.map { identifier(for: $0.id) })

        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = "Скоро мероприятие"
            content.body = "«\(reminder.title)» — не забудьте о событии."
            content.sound = .default
            content.userInfo = ["eventID": reminder.id.uuidString]

            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: reminder.date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifier(for: reminder.id),
                content: content,
                trigger: trigger
            )
            try await center.add(request)
        }

        let obsolete = existingIDs.filter { !desiredIDs.contains($0) }
        if !obsolete.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: obsolete)
        }
    }

    private func identifier(for eventID: UUID) -> String {
        prefix + eventID.uuidString
    }
}
