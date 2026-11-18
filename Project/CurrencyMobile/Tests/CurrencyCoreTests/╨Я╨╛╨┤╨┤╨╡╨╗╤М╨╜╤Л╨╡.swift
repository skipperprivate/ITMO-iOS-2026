
import Foundation
@testable import CurrencyCore

/// Источник курсов с заданными ответами.

actor ПоддельныйИсточник: RateSource {

    var курсы: [Rate]
    var точки: [HistoryPoint]

    /// Если задано — выбрасывается вместо ответа.
    var ошибка: Error?

    /// Задержка ответа: без неё запросы не успевают наложиться
    /// и параллельность не видна.
    var задержка: UInt64 = 0

    private(set) var вызововКурсов = 0
    private(set) var вызововИстории = 0
    private(set) var сейчасВРаботе = 0
    private(set) var максимумОдновременно = 0

    /// Даты, которые запрашивали.
    private(set) var спрашивали: [String] = []

    init(курсы: [Rate] = [], точки: [HistoryPoint] = []) {
        self.курсы = курсы
        self.точки = точки
    }

    /// Если задано — ответ всегда с этой датой, какой бы день
    /// ни запросили. Так изображаются выходные.
    var закреплённаяДата: Date?

    func настроить(ошибка: Error?) { self.ошибка = ошибка }
    func настроить(задержка: UInt64) { self.задержка = задержка }
    func настроить(курсы: [Rate]) { self.курсы = курсы }
    func настроить(закреплённаяДата: Date?) {
        self.закреплённаяДата = закреплённаяДата
    }

    func rates(on date: Date) async throws -> [Rate] {
        вызововКурсов += 1
        спрашивали.append(DateBits.forPerson(date))
        try await поработать()
        if let ошибка { throw ошибка }
        let дата = закреплённаяДата ?? date
        return курсы.map {
            Rate(id: $0.id, code: $0.code, name: $0.name,
                 nominal: $0.nominal, value: $0.value, date: дата)
        }
    }

    func history(id: String, from: Date, to: Date) async throws
        -> [HistoryPoint] {
        вызововИстории += 1
        try await поработать()
        if let ошибка { throw ошибка }
        return точки
    }

    /// Имитация работы с подсчётом одновременных обращений.
    private func поработать() async throws {
        сейчасВРаботе += 1
        максимумОдновременно = max(максимумОдновременно, сейчасВРаботе)
        if задержка > 0 {
            try? await Task.sleep(nanoseconds: задержка)
        }
        сейчасВРаботе -= 1
    }
}

/// Транспорт с заранее заданным ответом. Запоминает URL —
/// по ним проверяется, что запросы собраны правильно.
actor ПоддельнаяДоставка: Transport {

    var ответ: Data
    var ошибка: Error?
    private(set) var ссылки: [String] = []

    init(ответ: String) {
        self.ответ = Data(ответ.utf8)
    }

    init(ответ: Data) {
        self.ответ = ответ
    }

    func настроить(ошибка: Error?) { self.ошибка = ошибка }

    func get(_ url: URL) async throws -> Data {
        ссылки.append(url.absoluteString)
        if let ошибка { throw ошибка }
        return ответ
    }
}

//  MARK: - Образцы данных

enum Образцы {

    static let день = DateBits.day(18, 11, 2026)!

    static func доллар(_ цена: String = "80,9734",
                       on date: Date = день) -> Rate {
        Rate(id: "R01235", code: "USD", name: "Доллар США",
             nominal: 1, value: CBRParser.number(цена)!, date: date)
    }

    static func евро(_ цена: String = "93,6195",
                     on date: Date = день) -> Rate {
        Rate(id: "R01239", code: "EUR", name: "Евро",
             nominal: 1, value: CBRParser.number(цена)!, date: date)
    }

    /// Валюта с номиналом 100.
    static func драм(_ цена: String = "21,0824",
                     on date: Date = день) -> Rate {
        Rate(id: "R01060", code: "AMD", name: "Армянских драмов",
             nominal: 100, value: CBRParser.number(цена)!, date: date)
    }

    static var тройка: [Rate] { [драм(), евро(), доллар()] }

    static func история(_ цены: [String]) -> [HistoryPoint] {
        цены.enumerated().map { номер, цена in
            HistoryPoint(date: DateBits.shift(день, days: -цены.count + 1
                                              + номер),
                         perUnit: CBRParser.number(цена)!)
        }
    }
}
