//  SettingsScreen.swift
//  Экран «О программе»: источник данных, их актуальность и сброс кэша.

import SwiftUI
import CurrencyCore

struct SettingsScreen: View {

    let model: SettingsModel

    /// Подтверждение очистки: действие необратимое.
    @State private var спроситьПроОчистку = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Источник данных") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.sourceTitle)
                            .font(.subheadline)
                        Text("Официальные курсы, XML-сервис ЦБ РФ")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    if let адрес = URL(string: model.sourceURL) {
                        Link("Описание сервиса", destination: адрес)
                    }
                }

                Section("Сохранено на телефоне") {
                    HStack {
                        Text("Данные на")
                        Spacer()
                        Text(model.savedDate)
                            .monospacedDigit()
                            .foregroundStyle(Color.secondary)
                    }
                    HStack {
                        Text("Хранится дней")
                        Spacer()
                        Text("\(model.keepDays)")
                            .foregroundStyle(Color.secondary)
                    }
                    Text(model.summary)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                }

                Section {
                    Button(role: .destructive) {
                        спроситьПроОчистку = true
                    } label: {
                        Label("Очистить сохранённое",
                              systemImage: "trash")
                    }
                    if !model.note.isEmpty {
                        Text(model.note)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                } footer: {
                    Text("Отмеченные валюты останутся на месте —"
                         + " очищаются только загруженные курсы.")
                }
            }
            .navigationTitle("О программе")
            .confirmationDialog("Очистить сохранённые курсы?",
                                isPresented: $спроситьПроОчистку,
                                titleVisibility: .visible) {
                Button("Очистить", role: .destructive) {
                    Task { await model.clearCache() }
                }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text("Останется только последний загруженный день,"
                     + " чтобы приложение работало без сети.")
            }
        }
        .task {
            await model.load()
        }
    }
}
