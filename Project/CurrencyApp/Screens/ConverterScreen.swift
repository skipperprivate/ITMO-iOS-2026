//
//  ConverterScreen.swift
//  Экран «Конвертер».
//
//  Расчетов нет. вид только отображает состояние
//  ConverterModel и передаёт ей ввод.

import SwiftUI
import CurrencyCore

struct ConverterScreen: View {

    @Bindable var model: ConverterModel

    var body: some View {
        NavigationStack {
            Group {
                switch model.phase {
                case .idle, .loading:
                    Ожидание()
                case .failed(let текст):
                    ПлохойСлучай(текст: текст) {
                        await model.load()
                    }
                case .ready:
                    форма
                }
            }
            .navigationTitle("Конвертер")
        }
        .task {
            await model.load()
            model.fixMissing()
        }
    }

    private var форма: some View {
        Form {
            Section("Сколько переводим") {
                TextField("Сумма", text: $model.amountText)
                    .keyboardType(.decimalPad)
                    .font(.title2)
                    .monospacedDigit()

                if model.inputLooksWrong {
                    Text("Это не похоже на число")
                        .font(.caption)
                        .foregroundStyle(Color.red)
                }

                выбор(заголовок: "Из", код: $model.fromCode)
            }

            Section {
                выбор(заголовок: "В", код: $model.toCode)

                HStack {
                    Text("Итог")
                    Spacer()
                    Text(model.resultText.isEmpty
                         ? "—" : model.resultText)
                        .font(.title2)
                        .monospacedDigit()
                        .foregroundStyle(Color.primary)
                }
            } footer: {
                //  Показываем сам курс: по одному итогу его не проверить.
                Text(model.explanation)
            }

            Section {
                Button {
                    model.swap()
                } label: {
                    Label("Поменять местами",
                          systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }

    private func выбор(заголовок: String,
                       код: Binding<String>) -> some View {
        Picker(заголовок, selection: код) {
            ForEach(model.currencies) { валюта in
                Text("\(валюта.code) — \(валюта.name)")
                    .tag(валюта.code)
            }
        }
    }
}
