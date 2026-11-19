import SwiftUI

struct PreferencesSettingsSections: View {
    let appInfo: AppInfo
    let reminderCoordinator: ReminderCoordinator

    @AppStorage(EventlyPreferences.reminderLeadTimeKey)
    private var reminderLeadTime = ReminderLeadTime.oneDay.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            reminderSection
            Divider()
            aboutSection
        }
        .onChange(of: reminderLeadTime) { _, _ in
            reminderCoordinator.synchronize()
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Напоминания")
                .font(.title2.bold())

            Picker("Напоминать о мероприятии", selection: $reminderLeadTime) {
                ForEach(ReminderLeadTime.allCases) { option in
                    Text(option.title)
                        .tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .tint(.purple)
            .accessibilityIdentifier("settings.reminder.leadTime")

            Text("Для мероприятий из избранного. Доступ к уведомлениям iOS запросит при первом добавлении.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("О приложении")
                .font(.title2.bold())

            detailRow("Приложение", value: appInfo.name)
            detailRow("Разработчик", value: appInfo.developer)
            detailRow("Версия", value: appInfo.version)
            detailRow("Сборка", value: appInfo.build)

            Text(appInfo.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("technologies")
                .font(.subheadline.weight(.semibold))

            Text(appInfo.technologies)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("settings.about")
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
