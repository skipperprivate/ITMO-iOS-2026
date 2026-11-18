//
//  FavouritesScreen.swift
//  Экран «Избранное»: отмеченные валюты с мини-графиками
//  за неделю. Графики загружаются параллельно.
//

import SwiftUI
import CurrencyCore

struct FavouritesScreen: View {

    let model: FavouritesModel
    let library: RateLibrary

    var body: some View {
        NavigationStack {
            Group {
                if model.isEmpty {
                    ContentUnavailableView(
                        "Пока пусто",
                        systemImage: "star",
                        description: Text("Отметьте валюту"
                                          + " звёздочкой на вкладке"
                                          + " «Курсы» — она появится"
                                          + " здесь."))
                } else {
                    содержимое
                }
            }
            .navigationTitle("Избранное")
        }
        .task {
            await model.load()
        }
    }

    @ViewBuilder
    private var содержимое: some View {
        switch model.phase {
        case .idle, .loading:
            Ожидание(текст: "Загружаем избранное…")

        case .failed(let текст):
            ПлохойСлучай(текст: текст) {
                await model.load()
            }

        case .ready:
            List {
                ForEach(model.rates) { валюта in
                    NavigationLink {
                        HistoryScreen(rate: валюта, library: library)
                    } label: {
                        строка(валюта)
                    }
                }
                .onDelete { номера in
                    //  Снимается только отметка; сами курсы
                    //  остаются в хранилище.
                    let коды = номера.map { model.rates[$0].code }
                    Task {
                        for код in коды {
                            await model.remove(код)
                        }
                    }
                }
            }
            .refreshable {
                await model.load()
            }
        }
    }

    private func строка(_ валюта: Rate) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(валюта.code)
                    .font(.headline)
                Text(валюта.name)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }

            Spacer()

            //  Тот же вид графика, что и на экране истории.
            График(точки: model.spark01(for: валюта.code))
                .frame(width: 70, height: 32)

            Text(Converter.rateText(валюта))
                .monospacedDigit()
                .font(.subheadline)
        }
    }
}
