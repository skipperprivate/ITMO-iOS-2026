//  Money.swift
//  Доменные типы: валюта, курс, точка истории.

import Foundation

/// Курс валюты к рублю на определённую дату.
///
/// ЦБ публикует цену не за одну единицу, а за `nominal` единиц
/// (у драма это 100, у донга 10 000), поэтому хранятся оба числа,
/// а цена за единицу считается в `perUnit`.
public struct Rate: Equatable, Sendable, Identifiable {

    /// Внутренний код ЦБ, например `R01235`. Нужен для запроса истории.
    public let id: String

    /// Код по ISO 4217: `USD`, `EUR`.
    public let code: String

    /// Название на русском.
    public let name: String

    /// За сколько единиц указана цена.
    public let nominal: Int

    /// Цена `nominal` единиц в рублях.
    public let value: Decimal

    /// Дата, на которую действует курс.
    public let date: Date

    public init(id: String, code: String, name: String,
                nominal: Int, value: Decimal, date: Date) {
        self.id = id
        self.code = code
        self.name = name
        self.nominal = nominal
        self.value = value
        self.date = date
    }

    /// Цена одной единицы валюты в рублях.
    public var perUnit: Decimal {
        guard nominal > 0 else { return 0 }
        return value / Decimal(nominal)
    }
}

/// Точка графика истории курса.
///
/// Отдельный тип, а не `Rate`: в ответе с историей нет ни кода,
/// ни названия валюты — только дата и цена.
public struct HistoryPoint: Equatable, Sendable {
    public let date: Date
    public let perUnit: Decimal

    public init(date: Date, perUnit: Decimal) {
        self.date = date
        self.perUnit = perUnit
    }
}

public extension Rate {

    /// Рубль. В ответе ЦБ его нет, но конвертеру он нужен как
    /// обычная валюта с курсом 1 — тогда пересчёт везде идёт
    /// по одной формуле.
    static func ruble(on date: Date) -> Rate {
        Rate(id: "RUB", code: "RUB", name: "Российский рубль",
             nominal: 1, value: 1, date: date)
    }

    var isRuble: Bool { code == "RUB" }
}
