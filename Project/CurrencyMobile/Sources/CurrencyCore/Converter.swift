
import Foundation

public enum Converter {

    //  MARK: - Пересчёт

    /// Перевести сумму из одной валюты в другую.
    /// `nil`, если целевой курс нулевой.
    public static func convert(_ amount: Decimal,
                               from: Rate, to: Rate) -> Decimal? {
        let целевой = to.perUnit
        guard целевой > 0 else { return nil }
        return amount * from.perUnit / целевой
    }

    /// Изменение курса в процентах; знак показывает направление.
    public static func change(now: Decimal, before: Decimal) -> Decimal? {
        guard before > 0 else { return nil }
        return (now - before) / before * 100
    }

    //  MARK: - Форматирование

    /// Округление до заданного числа знаков.
    public static func round(_ value: Decimal, digits: Int) -> Decimal {
        var входное = value
        var итог = Decimal()
        NSDecimalRound(&итог, &входное, digits, .plain)
        return итог
    }

    /// Число в виде строки с запятой и разделителями разрядов.
    ///
    /// Без NumberFormatter: он зависит от языка устройства,
    /// а вид чисел в рублёвом приложении должен быть одинаковым.
    public static func text(_ value: Decimal,
                            digits: Int = 2,
                            groups: Bool = true) -> String {
        let округлённое = round(value, digits: digits)

        //  description у Decimal не зависит от локали и всегда
        //  использует точку.
        var запись = "\(округлённое)"
        var минус = false
        if запись.hasPrefix("-") {
            минус = true
            запись.removeFirst()
        }

        var целая = запись
        var дробная = ""
        if let точка = запись.firstIndex(of: ".") {
            целая = String(запись[запись.startIndex..<точка])
            дробная = String(запись[запись.index(after: точка)...])
        }

        if дробная.count > digits {
            дробная = String(дробная.prefix(digits))
        }
        while дробная.count < digits { дробная.append("0") }

        if groups { целая = разбитьПоТриЦифры(целая) }

        var out = целая
        if digits > 0 { out += ",\(дробная)" }
        //  Минус-черта, а не дефис: в колонке чисел дефис
        //  короче цифр.
        return минус ? "−\(out)" : out
    }

    /// Курс для списка: `80,97 ₽`. У валют дешевле рубля
    /// показывается четыре знака, иначе курс превращается в ноль.
    public static func rateText(_ rate: Rate) -> String {
        let цена = rate.perUnit
        let знаков = цена < 1 ? 4 : 2
        return "\(text(цена, digits: знаков)) ₽"
    }

    /// Изменение со знаком: `+0,42 %`.
    public static func changeText(_ percent: Decimal) -> String {
        let знак = percent > 0 ? "+" : ""
        return "\(знак)\(text(percent, digits: 2, groups: false)) %"
    }

    /// Неразрывные пробелы между разрядами. Четырёхзначные числа
    /// по правилам русской типографики не разбиваются.
    private static func разбитьПоТриЦифры(_ s: String) -> String {
        guard s.count > 4 else { return s }
        var out = ""
        for (номер, ch) in s.reversed().enumerated() {
            if номер > 0, номер % 3 == 0 { out.append("\u{00A0}") }
            out.append(ch)
        }
        return String(out.reversed())
    }
}
