import Foundation

public enum DateBits {

    /// Единый календарь приложения. Создаётся один раз — Calendar
    /// недешёвый, а нужен постоянно.
    public static let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }()

    /// Собрать дату. `nil`, если такого дня не существует.
    public static func day(_ d: Int, _ m: Int, _ y: Int) -> Date? {
        var parts = DateComponents()
        parts.year = y
        parts.month = m
        parts.day = d
        //  Полдень, чтобы никакой сдвиг пояса не перебросил
        //  дату на соседние сутки.
        parts.hour = 12
        return calendar.date(from: parts)
    }

    /// Разобрать `18.11.2026` или `18/11/2026`.
    public static func parse(_ s: String) -> Date? {
        let куски = s.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: { $0 == "." || $0 == "/" })
        guard куски.count == 3,
              let d = Int(куски[0]),
              let m = Int(куски[1]),
              let y = Int(куски[2]) else { return nil }
        return day(d, m, y)
    }

    public static func parts(_ date: Date) -> (d: Int, m: Int, y: Int) {
        let c = calendar.dateComponents([.day, .month, .year], from: date)
        return (c.day ?? 1, c.month ?? 1, c.year ?? 1970)
    }

    /// Формат для запроса к ЦБ: `18/11/2026`.
    public static func forRequest(_ date: Date) -> String {
        let p = parts(date)
        return "\(two(p.d))/\(two(p.m))/\(p.y)"
    }

    /// Формат для показа: `18.11.2026`.
    public static func forPerson(_ date: Date) -> String {
        let p = parts(date)
        return "\(two(p.d)).\(two(p.m)).\(p.y)"
    }

    /// Короткая подпись для оси графика: `18.11`.
    public static func short(_ date: Date) -> String {
        let p = parts(date)
        return "\(two(p.d)).\(two(p.m))"
    }

    /// Сдвиг на сутки средствами календаря — арифметика
    /// по секундам сломалась бы на разной длине месяцев.
    public static func shift(_ date: Date, days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    public static func sameDay(_ a: Date, _ b: Date) -> Bool {
        calendar.isDate(a, inSameDayAs: b)
    }

    private static func two(_ n: Int) -> String {
        n < 10 ? "0\(n)" : "\(n)"
    }
}
