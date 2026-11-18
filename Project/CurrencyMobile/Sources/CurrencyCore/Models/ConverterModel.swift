//
//  ConverterModel.swift
//  Модель экрана «Конвертер» (MVVM).
//
//  Ввод хранится строкой и разбирается на лету. Незаконченный
//  ввод («12,») считается корректным и даёт результат по уже
//  набранному, иначе поле мигало бы ошибкой при наборе.
//  Ошибкой считается только то, что числом не станет никогда.
//

import Foundation
import Observation

@MainActor
@Observable
public final class ConverterModel {

    //  MARK: - Состояние

    public private(set) var phase: LoadPhase = .idle

    /// Все валюты, включая рубль.
    public private(set) var currencies: [Rate] = []

    /// Введённая сумма. Строка, а не Decimal: иначе каждый ввод
    /// пересобирал бы текст поля и сбивал курсор.
    public var amountText: String = "1"

    public var fromCode: String = "USD"
    public var toCode: String = "RUB"

    private let library: RateLibrary

    public init(library: RateLibrary) {
        self.library = library
    }

    //  MARK: - Загрузка

    public func load() async {
        guard phase != .loading else { return }
        phase = .loading
        do {
            let день = try await library.today()
            //  Рубль первым: он нужен чаще остальных.
            currencies = [Rate.ruble(on: день.date)] + день.rates
            phase = .ready
        } catch {
            phase = .failed("Не удалось загрузить курсы.")
        }
    }

    //  MARK: - Расчёт

    /// Разобранная сумма; `nil` — вводить ещё нечего.
    public var amount: Decimal? {
        let чистое = amountText.trimmingCharacters(in: .whitespaces)
        guard !чистое.isEmpty else { return nil }
        return CBRParser.number(чистое)
    }

    public var from: Rate? { currencies.first { $0.code == fromCode } }
    public var to: Rate? { currencies.first { $0.code == toCode } }

    public var result: Decimal? {
        guard let amount, let from, let to else { return nil }
        return Converter.convert(amount, from: from, to: to)
    }

    /// Результат для показа; пустая строка, если считать нечего.
    public var resultText: String {
        guard let result else { return "" }
        let знаков = (result != 0 && result < 1) ? 4 : 2
        return Converter.text(result, digits: знаков)
    }

    /// Пояснение `1 USD = 80,97 RUB` — чтобы был виден сам курс,
    /// а не только итог.
    public var explanation: String {
        guard let from, let to,
              let один = Converter.convert(1, from: from, to: to) else {
            return ""
        }
        let знаков = (один != 0 && один < 1) ? 4 : 2
        return "1 \(from.code) = \(Converter.text(один, digits: знаков))"
            + " \(to.code)"
    }

    /// Ввод есть, но числом не станет (например «1,2,3»).
    public var inputLooksWrong: Bool {
        let чистое = amountText.trimmingCharacters(in: .whitespaces)
        if чистое.isEmpty { return false }
        //  Оборванный ввод вроде «12,» — ещё не ошибка.
        if чистое.hasSuffix(",") || чистое.hasSuffix(".") { return false }
        return CBRParser.number(чистое) == nil
    }

    //  MARK: - Действия

    /// Поменять валюты местами, сохранив введённую сумму.
    public func swap() {
        let было = fromCode
        fromCode = toCode
        toCode = было
    }

    /// Подставить первую доступную валюту, если выбранной больше
    /// нет в списке (осталась с прошлого запуска).
    public func fixMissing() {
        guard !currencies.isEmpty else { return }
        if from == nil { fromCode = currencies.first!.code }
        if to == nil { toCode = currencies.first!.code }
    }
}
