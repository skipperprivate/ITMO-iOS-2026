//  RatesScreen.swift
//  Экран «Курсы»: список валют с поиском, избранным,
//  обновлением по жесту и переходом к истории.


import SwiftUI
import CurrencyCore

struct RatesScreen: View {

    @Bindable var model: RatesModel

    let library: RateLibrary

    var body: some View {
        NavigationStack {
            Group {
                if model.visible.isEmpty {
                    пустота
                } else {
                    список
                }
            }
            .navigationTitle("Курсы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        model.onlyFavourites.toggle()
                    } label: {
                        Image(systemName: model.onlyFavourites
                              ? "star.fill" : "star")
                    }
                    .accessibilityLabel(model.onlyFavourites
                                        ? "Показать все валюты"
                                        : "Показать только избранное")
                }
            }
            .searchable(text: $model.search,
                        prompt: "Код или название")
        }
        .task {
            await model.load()
        }
    }

    //  MARK: - Части экрана

    private var список: some View {
        List {
            Section {
                ForEach(model.visible) { валюта in
                    NavigationLink {
                        HistoryScreen(rate: валюта, library: library)
                    } label: {
                        строка(валюта)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            Task {
                                await model.toggleFavourite(валюта.code)
                            }
                        } label: {
                            Image(systemName: model.isFavourite(валюта.code)
                                  ? "star.slash" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            } header: {
                //  Дата курсов и признак того, что данные сохраненные, а не свежие.
                Text(model.subtitle)
            }
        }
        .refreshable {
            await model.refresh()
        }
    }

    private func строка(_ валюта: Rate) -> some View {
        HStack {
            if model.isFavourite(валюта.code) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(Color.yellow)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(валюта.code)
                    .font(.headline)
                Text(подпись(валюта))
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(Converter.rateText(валюта))
                    .monospacedDigit()
                Стрелка(вверх: model.grew(валюта),
                        подпись: model.changeText(for: валюта))
            }
        }
    }

    private func подпись(_ валюта: Rate) -> String {
        валюта.nominal == 1
            ? валюта.name
            : "\(валюта.name) (за \(валюта.nominal))"
    }

    @ViewBuilder
    private var пустота: some View {
        switch model.phase {
        case .idle, .loading:
            Ожидание()
        case .failed(let текст):
            ПлохойСлучай(текст: текст) {
                await model.refresh()
            }
        case .ready:
            
            ContentUnavailableView(заголовокПустоты,
                                   systemImage: "magnifyingglass",
                                   description: Text(поясненьеПустоты))
        }
    }

    private var пустоИзЗаИзбранного: Bool {
        model.onlyFavourites && model.search.isEmpty
    }

    private var заголовокПустоты: String {
        пустоИзЗаИзбранного ? "Нет отмеченных валют" : "Ничего не нашлось"
    }

    private var поясненьеПустоты: String {
        пустоИзЗаИзбранного
            ? "Отметьте валюту звёздочкой в общем списке."
            : "Попробуйте другой запрос."
    }
}
