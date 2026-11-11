//
//  WeatherFormatter.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Formatting lives here, not in ViewModels: they expose raw domain values only.
enum WeatherFormatter {
    private static let locale = Locale(identifier: "ru_RU")
    private static var dateFormatterCache: [String: DateFormatter] = [:]

    private static func dateFormatter(_ format: String, timeZone: TimeZone) -> DateFormatter {
        let key = "\(format)|\(timeZone.identifier)"
        if let cached = dateFormatterCache[key] { return cached }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        dateFormatterCache[key] = formatter
        return formatter
    }

    // MARK: Values

    static func temperature(_ celsius: Double, unit: TemperatureUnit) -> String {
        let value = Int(unit.convert(fromCelsius: celsius).rounded())
        return value < 0 ? "−\(abs(value))°" : "\(value)°"
    }

    static func windSpeedValue(_ kmh: Double, unit: WindSpeedUnit) -> String {
        "\(Int(unit.convert(fromKmh: kmh).rounded()))"
    }

    static func windSpeed(_ kmh: Double, unit: WindSpeedUnit) -> String {
        "\(windSpeedValue(kmh, unit: unit)) \(unit.symbol)"
    }

    static func pressureValue(_ hPa: Double, unit: PressureUnit) -> String {
        let value = unit.convert(fromHPa: hPa)
        return unit == .inchesOfMercury
            ? value.formatted(.number.precision(.fractionLength(2)).locale(locale))
            : "\(Int(value.rounded()))"
    }

    static func precipitation(_ millimeters: Double) -> String {
        "\(millimeters.formatted(.number.precision(.fractionLength(1)).locale(locale))) мм"
    }

    static func visibility(_ kilometers: Double) -> String {
        kilometers < 1
            ? "\(Int((kilometers * 1000).rounded())) м"
            : "\(Int(kilometers.rounded())) км"
    }

    static func days(_ value: Int) -> String {
        count(value, one: "день", few: "дня", many: "дней")
    }

    static func letters(_ value: Int) -> String {
        count(value, one: "букву", few: "буквы", many: "букв")
    }

    // Age of the loaded data, relative to the device clock (not a city time).
    static func updated(at date: Date, now: Date) -> String {
        let minutes = Int(max(0, now.timeIntervalSince(date)) / 60)
        switch minutes {
        case 0: return "Обновлено только что"
        case 1..<60: return "Обновлено \(count(minutes, one: "минуту", few: "минуты", many: "минут")) назад"
        default:
            let hours = minutes / 60
            return hours < 24
                ? "Обновлено \(count(hours, one: "час", few: "часа", many: "часов")) назад"
                : "Обновлено \(days(hours / 24)) назад"
        }
    }

    private static func count(_ value: Int, one: String, few: String, many: String) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        if mod10 == 1 && mod100 != 11 { return "\(value) \(one)" }
        if (2...4).contains(mod10) && !(12...14).contains(mod100) { return "\(value) \(few)" }
        return "\(value) \(many)"
    }

    // MARK: Dates (city time zone)

    static func time(_ date: Date, in timeZone: TimeZone) -> String {
        dateFormatter("HH:mm", timeZone: timeZone).string(from: date)
    }

    static func dayMonth(_ date: Date, in timeZone: TimeZone) -> String {
        dateFormatter("d MMMM", timeZone: timeZone).string(from: date)
    }

    static func weekday(_ date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) { return "Сегодня" }
        if calendar.isDateInTomorrow(date) { return "Завтра" }
        return dateFormatter("EEEE", timeZone: calendar.timeZone).string(from: date).capitalized(with: locale)
    }
}
