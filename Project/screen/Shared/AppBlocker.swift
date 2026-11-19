import FamilyControls
import ManagedSettings

nonisolated enum AppBlocker {
    static var isBlocking: Bool {
        let store = ManagedSettingsStore()
        return store.shield.applications != nil || store.shield.applicationCategories != nil
    }

    @discardableResult
    static func update() -> Bool {
        // Monitor callbacks and recording matches can arrive in different processes.
        // Read all inputs inside the lock so a delayed update cannot reapply an old decision.
        (try? RecordingAccounting.withLock { applyCurrentPolicy() }) ?? isBlocking
    }

    private static func applyCurrentPolicy() -> Bool {
        let config = ConfigStore.load()
        let usage = UsageStore.load()
        let store = ManagedSettingsStore()
        guard config.shouldBlock(config.battery(for: usage, coding: CodingStore.bonus(config), recording: RecordingAccounting.today.total)) else {
            store.clearAllSettings()
            return false
        }
        let apps = config.bad.applicationTokens
        let categories = config.bad.categoryTokens
        store.shield.applications = apps.isEmpty ? nil : apps
        store.shield.applicationCategories = categories.isEmpty ? nil : .specific(categories)
        return !apps.isEmpty || !categories.isEmpty
    }
}
