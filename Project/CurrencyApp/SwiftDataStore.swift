//  SwiftDataStore.swift

import Foundation
import SwiftData
import CurrencyCore

//  MARK: - Модели хранения

/// Сохранённый курс.
/// Цена хранится строкой: при переводе в двоичное представление точная десятичная дробь теряет последний знак. Разбор парсится так же как ответ ЦБ.
@Model
final class SavedRate {

    var cbrID: String = ""
    var code: String = ""
    var name: String = ""
    var nominal: Int = 1

    /// Цена условных единиц в виде текста.
    var valueText: String = "0"

    var date: Date = Date()

    /// День в формате дд.мм.ггг — ключ для поиска.
    var day: String = ""

    init(from rate: Rate) {
        self.cbrID = rate.id
        self.code = rate.code
        self.name = rate.name
        self.nominal = rate.nominal
        self.valueText = "\(rate.value)"
        self.date = rate.date
        self.day = DateBits.forPerson(rate.date)
    }

    var asRate: Rate {
        Rate(id: cbrID, code: code, name: name, nominal: nominal,
             value: CBRParser.number(valueText) ?? 0, date: date)
    }
}

/// Отмеченная валюта.
@Model
final class SavedFavourite {

    /// Уникальный, чтобы повторные нажатия не плодили дубли.
    @Attribute(.unique) var code: String = ""

    init(code: String) {
        self.code = code
    }
}

//  MARK: - Хранилище

@ModelActor
actor SwiftDataStore: RateStore, Favourites {

    //  MARK: Курсы

    func save(_ rates: [Rate], on date: Date) async {
        let день = DateBits.forPerson(date)

        //  Сначала убираем прежние записи этого дня, иначе база
        //  копила бы дубли при каждом обновлении.
        await удалитьДень(день)

        for r in rates {
            modelContext.insert(SavedRate(from: r))
        }
        попытатьсяСохранить()
    }

    func rates(on date: Date) async -> [Rate]? {
        let день = DateBits.forPerson(date)
        let запрос = FetchDescriptor<SavedRate>(
            predicate: #Predicate { $0.day == день })
        guard let найдено = try? modelContext.fetch(запрос),
              !найдено.isEmpty else { return nil }
        return найдено.map(\.asRate).sorted { $0.code < $1.code }
    }

    func latest() async -> (date: Date, rates: [Rate])? {
        //  Одна запись, чтобы узнать дату, и только потом выборка дня целиком.
        var запрос = FetchDescriptor<SavedRate>(
            sortBy: [SortDescriptor(\.date, order: .reverse)])
        запрос.fetchLimit = 1
        guard let первая = try? modelContext.fetch(запрос).first,
              let список = await rates(on: первая.date) else {
            return nil
        }
        return (date: первая.date, rates: список)
    }

    func trim(keepDays: Int) async {
        guard keepDays >= 1 else { return }

        let запрос = FetchDescriptor<SavedRate>(
            sortBy: [SortDescriptor(\.date, order: .reverse)])
        guard let всё = try? modelContext.fetch(запрос) else { return }

        //  Сортировка по дате добавления
        var дни: [String] = []
        for r in всё where !дни.contains(r.day) {
            дни.append(r.day)
        }
        guard дни.count > keepDays else { return }

        for день in дни.dropFirst(keepDays) {
            await удалитьДень(день)
        }
        попытатьсяСохранить()
    }

    private func удалитьДень(_ день: String) async {
        let запрос = FetchDescriptor<SavedRate>(
            predicate: #Predicate { $0.day == день })
        guard let старые = try? modelContext.fetch(запрос) else { return }
        for строка in старые {
            modelContext.delete(строка)
        }
    }

    //  MARK: Избранное

    func all() async -> Set<String> {
        let запрос = FetchDescriptor<SavedFavourite>()
        guard let найдено = try? modelContext.fetch(запрос) else {
            return []
        }
        return Set(найдено.map(\.code))
    }

    func set(_ code: String, on: Bool) async {
        let запрос = FetchDescriptor<SavedFavourite>(
            predicate: #Predicate { $0.code == code })
        let было = (try? modelContext.fetch(запрос)) ?? []

        if on {
            guard было.isEmpty else { return }
            modelContext.insert(SavedFavourite(code: code))
        } else {
            for строка in было {
                modelContext.delete(строка)
            }
        }
        попытатьсяСохранить()
    }

    //  MARK: Служебное

    /// Ошибка записи (например, кончилось место) не крашит приложение т.к. в памяти уже есть записи которые будут показаны
    private func попытатьсяСохранить() {
        do {
            try modelContext.save()
        } catch {
            print("Не удалось сохранить: \(error)")
        }
    }
}
