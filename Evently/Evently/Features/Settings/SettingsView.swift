import SwiftUI

struct SettingsView: View {
    @State private var viewModel: FeedbackViewModel

    let locationStore: LocationStore
    let appInfo: AppInfo
    let reminderCoordinator: ReminderCoordinator

    init(
        viewModel: FeedbackViewModel,
        locationStore: LocationStore,
        appInfo: AppInfo,
        reminderCoordinator: ReminderCoordinator
    ) {
        self.appInfo = appInfo
        self.locationStore = locationStore
        _viewModel = State(initialValue: viewModel)
        self.reminderCoordinator = reminderCoordinator
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LocationSettingsSection(store: locationStore)
                sectionDivider
                PreferencesSettingsSections(
                    appInfo: appInfo,
                    reminderCoordinator: reminderCoordinator
                )
                sectionDivider
                feedbackSection
            }
            .padding(20)
        }
        .background(Color.black.ignoresSafeArea())
        .foregroundStyle(.white)
        .navigationTitle("Настройки")
        .preferredColorScheme(.dark)
        .alert("Спасибо за обращение!", isPresented: $viewModel.isSuccess) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Сервис отработал успешно!")
        }
        .alert(
            "Не удалось отправить сообщение",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("Закрыть", role: .cancel) {}
            Button("Попробовать снова") {
                Task { await viewModel.submit() }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var sectionDivider: some View {
        Divider()
            .overlay(Color.white.opacity(0.2))
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            feedbackHeading
            feedbackFields
            submitButton
        }
    }

    private var feedbackHeading: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Обратная связь")
                .font(.title2.bold())

            Text("Демо: отправка идёт в JSONPlaceholder, сообщения не доставляются разработчику")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var feedbackFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("support.report.title", text: $viewModel.title)
                .accessibilityIdentifier("feedback.title")
                .padding(12)
                .background(Color.purple.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            ZStack(alignment: .topLeading) {
                if viewModel.message.isEmpty {
                    Text("Расскажите подробнее...")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 17)
                        .padding(.top, 20)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $viewModel.message)
                    .accessibilityIdentifier("feedback.message")
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(12)
            }
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var submitButton: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            HStack {
                Spacer()

                if viewModel.isSending {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Отправить")
                        .fontWeight(.semibold)
                }

                Spacer()
            }
            .frame(height: 52)
        }
        .accessibilityIdentifier("feedback.submit")
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .disabled(!viewModel.canSubmit)
    }
}
