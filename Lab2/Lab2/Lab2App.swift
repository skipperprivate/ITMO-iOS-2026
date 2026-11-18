//
//  Lab2App.swift
//  Lab2
//
//  Created by n grebenkin on 17.09.2026.
//

import SwiftUI
import SwiftData

@main
struct Lab2App: App {
    private let container: ModelContainer
    private let settings: SettingsStore
    private let history: HistoryRepository

    init() {
        do {
            container = try ModelContainer(for: GeneratedNumber.self)
        } catch {
            fatalError("Не удалось открыть хранилище SwiftData: \(error)")
        }
        settings = UserDefaultsSettingsStore()
        history = SwiftDataHistoryRepository(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            NumberView(
                viewModel: NumberViewModel(
                    generator: RandomNumberGeneratorService(),
                    settings: settings,
                    history: history
                ),
                historyViewModel: HistoryViewModel(repository: history),
                settingsViewModel: SettingsViewModel(settings: settings)
            )
        }
    }
}
