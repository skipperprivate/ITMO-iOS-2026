//  RootScreen.swift
//  Корневой экран с вкладками и общие вспомогательные виды.


import SwiftUI
import CurrencyCore

struct RootScreen: View {

    let hub: Hub

    var body: some View {
        TabView {
            ConverterScreen(model: hub.converter)
                .tabItem {
                    Label("Конвертер",
                          systemImage: "arrow.left.arrow.right")
                }

            RatesScreen(model: hub.rates, library: hub.library)
                .tabItem {
                    Label("Курсы", systemImage: "list.bullet")
                }

            FavouritesScreen(model: hub.favouritesModel,
                             library: hub.library)
                .tabItem {
                    Label("Избранное", systemImage: "star")
                }

            SettingsScreen(model: hub.settings)
                .tabItem {
                    Label("О программе", systemImage: "info.circle")
                }
        }
    }
}

//  MARK: - Общие виды

struct ПлохойСлучай: View {

    let текст: String
    let повторить: () async -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(Color.secondary)

            Text(текст)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondary)

            Button("Попробовать ещё раз") {
                Task { await повторить() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
    }
}

/// Индикатор загрузки с подписью.
struct Ожидание: View {

    var текст: String = "Загружаем курсы…"

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(текст)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
        .padding(32)
    }
}

/// Индикатор изменения курса.
struct Стрелка: View {

    /// true — рост, false — падение, nil — без изменений.
    let вверх: Bool?
    let подпись: String?

    var body: some View {
        HStack(spacing: 4) {
            if let вверх {
                Image(systemName: вверх
                      ? "arrow.up.right"
                      : "arrow.down.right")
                    .font(.caption2)
            }
            if let подпись {
                Text(подпись)
                    .font(.caption)
                    .monospacedDigit()
            }
        }
        .foregroundStyle(цвет)
    }

    private var цвет: Color {
        guard let вверх else { return Color.secondary }
        //  Направление дублируется стрелкой, чтобы цвет не был
        //  единственным носителем смысла.
        return вверх ? Color.green : Color.red
    }
}
