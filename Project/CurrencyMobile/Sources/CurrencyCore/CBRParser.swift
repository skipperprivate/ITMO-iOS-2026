

import Foundation

public enum CBRParseError: Error, Equatable {

    /// Корень не `ValCurs` — обычно вместо данных пришла
    /// страница с ошибкой.
    case notValCurs(String)

    case noDate(String)

    /// Разбор прошёл, но ни одной валюты не нашлось.
    case emptyList
}

public enum CBRParser {

    //  MARK: - Курсы на день

    public static func rates(from data: Data) throws -> [Rate] {
        try rates(fromXML: CP1251.smartText(from: data))
    }

    /// Разбор из готовой строки. Используется тестами, чтобы
    /// проверять формат без обращения к сети.
    public static func rates(fromXML text: String) throws -> [Rate] {
        let root = try XMLBits.parse(text)
        guard root.name == "ValCurs" else {
            throw CBRParseError.notValCurs(root.name)
        }
        guard let raw = root.attributes["Date"],
              let date = DateBits.parse(raw) else {
            throw CBRParseError.noDate(root.attributes["Date"] ?? "")
        }

        var out: [Rate] = []
        for item in root.all("Valute") {
            //  Некорректная запись пропускается, а не роняет весь
            //  список: лучше показать 42 курса из 43.
            guard let id = item.attributes["ID"],
                  let code = item.value("CharCode"),
                  let name = item.value("Name"),
                  let nominalText = item.value("Nominal"),
                  let nominal = Int(nominalText.trimmingCharacters(
                    in: .whitespaces)),
                  nominal > 0,
                  let valueText = item.value("Value"),
                  let value = number(valueText) else { continue }

            out.append(Rate(id: id, code: code, name: name,
                            nominal: nominal, value: value, date: date))
        }

        guard !out.isEmpty else { throw CBRParseError.emptyList }

        //  ЦБ сортирует по внутреннему коду; экранам удобнее
        //  по буквенному, поэтому сортируем здесь один раз.
        return out.sorted { $0.code < $1.code }
    }

    //  MARK: - История

    public static func history(from data: Data) throws -> [HistoryPoint] {
        try history(fromXML: CP1251.smartText(from: data))
    }

    /// Пустой результат — не ошибка: на отрезке могли быть
    /// одни выходные.
    public static func history(fromXML text: String) throws -> [HistoryPoint] {
        let root = try XMLBits.parse(text)
        guard root.name == "ValCurs" else {
            throw CBRParseError.notValCurs(root.name)
        }

        var out: [HistoryPoint] = []
        for item in root.all("Record") {
            guard let raw = item.attributes["Date"],
                  let date = DateBits.parse(raw),
                  let nominalText = item.value("Nominal"),
                  let nominal = Int(nominalText.trimmingCharacters(
                    in: .whitespaces)),
                  nominal > 0,
                  let valueText = item.value("Value"),
                  let value = number(valueText) else { continue }

            //  Сразу приводим к цене за единицу, иначе смена
            //  номинала внутри периода даёт ложный скачок графика.
            out.append(HistoryPoint(date: date,
                                    perUnit: value / Decimal(nominal)))
        }

        return out.sorted { $0.date < $1.date }
    }

    //  MARK: - Числа

    public static func number(_ raw: String) -> Decimal? {
        var digits = ""
        var afterPoint = -1      // −1 — дробной части ещё не было
        var negative = false

        for ch in raw.trimmingCharacters(in: .whitespacesAndNewlines) {
            switch ch {
            case "-":
                guard digits.isEmpty, !negative else { return nil }
                negative = true
            case "+":
                guard digits.isEmpty else { return nil }
            case ",", ".":
                guard afterPoint < 0 else { return nil }
                afterPoint = 0
            case "0"..."9":
                digits.append(ch)
                if afterPoint >= 0 { afterPoint += 1 }
            case " ", "\u{00A0}":
                continue
            default:
                return nil
            }
        }

        guard !digits.isEmpty, let mantissa = UInt64(digits) else {
            return nil
        }
        return Decimal(sign: negative ? .minus : .plus,
                       exponent: afterPoint < 0 ? 0 : -afterPoint,
                       significand: Decimal(mantissa))
    }
}
