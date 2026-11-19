import Foundation

@MainActor
final class ReminderCoordinator {
    private let favorites: any FavoritesRepository
    private let scheduler: any LocalNotificationScheduling
    private let defaults: UserDefaults
    private var lastTask: Task<Void, Never>?

    init(
        favorites: any FavoritesRepository,
        scheduler: any LocalNotificationScheduling,
        defaults: UserDefaults = .standard
    ) {
        self.favorites = favorites
        self.scheduler = scheduler
        self.defaults = defaults
    }

    func synchronize(requestAuthorization: Bool = false) {
        let previous = lastTask
        lastTask = Task { [weak self] in
            await previous?.value
            await self?.rebuild(requestAuthorization: requestAuthorization)
        }
    }

    private func rebuild(requestAuthorization: Bool) async {
        let saved: [FavoriteEvent]
        do {
            saved = try favorites.fetchFavorites()
        } catch {
            NSLog("Evently: failed to load favorites for reminders: %@", String(describing: error))
            return
        }

        let raw = defaults.object(forKey: EventlyPreferences.reminderLeadTimeKey) as? Int
        let leadTime = ReminderLeadTime(rawValue: raw ?? ReminderLeadTime.oneDay.rawValue)
            ?? .oneDay
        let now = Date()

        let reminders = saved.compactMap { favorite -> EventReminder? in
            let fireDate = favorite.date.addingTimeInterval(-TimeInterval(leadTime.rawValue))
            guard fireDate > now else { return nil }
            return EventReminder(id: favorite.eventId, title: favorite.title, date: fireDate)
        }
        .sorted { $0.date < $1.date }
        .prefix(60)

        let allowed = await scheduler.ensureAuthorization(requestIfNeeded: requestAuthorization)
        guard allowed else { return }

        do {
            try await scheduler.replaceReminders(Array(reminders))
        } catch {
            NSLog("Evently: failed to schedule reminders: %@", String(describing: error))
        }
    }
}
