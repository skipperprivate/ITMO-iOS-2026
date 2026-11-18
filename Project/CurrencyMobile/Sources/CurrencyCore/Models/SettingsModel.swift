//
//  SettingsModel.swift
//  Модель экрана «О программе» (MVVM).
//
//  Показывает источник данных, их актуальность и позволяет
//  сбросить кэш курсов.
//

import Foundation
import Observation

@MainActor
@Observable
public final class SettingsModel {

    /// Дата сохранённых данных.
    public private(set) var savedDate: String = "—"

    /// Количество сохранённых валют.
    public private(set) var savedCount: Int = 0

    /// Глубина кэша в днях.
    public let keepDays = 30

    /// Сообщение о результате действия; пустое — показывать нечего.
    public private(set) var note: String = ""

    public let sourceTitle = "Центральный банк Российской Федерации"
    public let sourceURL = "https://www.cbr.ru/development/SXML/"

    private let store: RateStore
    private let library: RateLibrary

    public init(store: RateStore, library: RateLibrary) {
        self.store = store
        self.library = library
    }

    public func load() async {
        if let свежее = await store.latest() {
            savedDate = DateBits.forPerson(свежее.date)
            savedCount = свежее.rates.count
        } else {
            savedDate = "—"
            savedCount = 0
        }
        note = ""
    }

    /// Очистить кэш курсов. Избранное не трогается — это выбор
    /// пользователя, а не загруженные данные.
    public func clearCache() async {
        //  Последний день оставляем, чтобы приложение работало
        //  без сети сразу после очистки.
        await store.trim(keepDays: 1)
        await library.forget()
        await load()
        note = "Сохранённое очищено, остался только последний день."
    }

    public var summary: String {
        savedCount == 0
            ? "Данные ещё не загружались."
            : "Сохранено \(savedCount) \(валют(savedCount))"
                + " на \(savedDate)."
    }

    /// Склонение числительного: 1 валюта, 2 валюты, 5 валют.
    /// Не private — покрыто отдельным тестом.
    func валют(_ n: Int) -> String {
        let сотня = n % 100
        if (11...14).contains(сотня) { return "валют" }
        switch n % 10 {
        case 1: return "валюта"
        case 2, 3, 4: return "валюты"
        default: return "валют"
        }
    }
}
