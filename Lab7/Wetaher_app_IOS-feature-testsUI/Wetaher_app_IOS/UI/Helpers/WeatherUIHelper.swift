//
//  WeatherUIHelper.swift
//  Wetaher_app_IOS
//
//  Created by Sergey Sergeev on 07.10.2026.
//

import SwiftUI
//ВЫзывать во ViewModel и пропихнуть в UI-структуру!
/// Вспомогательные структуры и утилиты для презентации погоды в UI
public enum WeatherUIHelper {
    /// Определение текстового направления ветра по градусам (0-360)
    public static func degreesToDirection(_ degrees: Int) -> String {
        let directions = ["С", "СВ", "В", "ЮВ", "Ю", "ЮЗ", "З", "СЗ"]
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int(round(Double(normalized) / 45.0)) % 8
        return directions[index]
    }

    /// Описание статуса УФ-индекса
    public static func uvStatus(for index: Double) -> UVStatus { //Color вообще используется хоть где-то?
        switch index {
        case ..<3.0:
            return UVStatus(descripiton: "Низкий", color: .green)
        case 3.0..<6.0:
            return UVStatus(descripiton: "Умеренный", color: .yellow)
        case 6.0..<8.0:
            return UVStatus(descripiton: "Высокий", color: .orange)
        case 8.0..<11.0:
            return UVStatus(descripiton: "Очень высокий", color: .red)
        default:
            return UVStatus(descripiton: "Экстремальный", color: .purple)
        }
    }

    /// Описание статуса атмосферного давления
    public static func pressureStatus(for pressureHpa: Double) -> String {
        if pressureHpa >= 1010 && pressureHpa <= 1018 {
            return "Нормальное"
        } else if pressureHpa > 1018 {
            return "Повышенное"
        } else {
            return "Пониженное"
        }
    }
    
    /// Форматирование давления в миллиметрах ртутного столба (мм рт. ст.)
    public static func pressureMmHg(_ hPa: Double) -> Int {
        return Int(round(hPa * 0.750062))
    }
    
    /// Форматирование видимости в километрах
    public static func visibility(_ metersOrKm: Double) -> Double {
        let km = metersOrKm >= 1000 ? metersOrKm / 1000.0 : metersOrKm
        return round(km)
    }

    /// Описание статуса видимости
    public static func visibilityStatus(for km: Double) -> String {
        return km >= 10.0 ? "Отличная" : "Ограниченная"
    }

    /// Извлечение времени "ЧЧ:мм" из строки формата "YYYY-MM-DDTHH:mm"
    public static func formatTimeString(_ dateString: String, index: Int = 1, timeOffset: Int = 0) -> String {
        
        if(index == timeOffset){
            return "Сейчас"
        }
        
        let timePart = dateString.components(separatedBy: "T").last ?? dateString
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .gmt //Время по гринвичу!
        formatter.locale = Locale(identifier: "ru_RU")
        if let time = formatter.date(from: timePart) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ru_RU")
            displayFormatter.timeZone = .current //Выводим п-лю его текущее время
            displayFormatter.dateFormat = "HH:mm"
            return displayFormatter.string(from: time)
        }
        return dateString
        
//        if let tIndex = dateString.firstIndex(of: "T") {
//            let timeSubstring = dateString[dateString.index(after: tIndex)...]
//            return String(timeSubstring.prefix(5))
//        }
//        return dateString
    }
    
    /// Извлечение даты "YYYY-MM-DD" из строки формата "YYYY-MM-DDTHH:mm"
    public static func formatDateString(_ dateString: String) -> String {
        if let tIndex = dateString.firstIndex(of: "T") {
            return String(dateString[..<tIndex])
        }
        return dateString
    }

    /// Форматирование даты в локализованный вид "d MMM" (например, "4 окт")
    public static func formatDateLocalizedString(_ dateLocalizedString: String) -> String {
        let datePart = dateLocalizedString.components(separatedBy: "T").first ?? dateLocalizedString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .gmt //Время по гринвичу!
        if let date = formatter.date(from: datePart) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ru_RU")
            displayFormatter.timeZone = .gmt
            displayFormatter.dateFormat = "d MMM"
            return displayFormatter.string(from: date)
        }
        return dateLocalizedString
    }
    
    /// Формирование дня недели
    public static func formatDayOfWeekString(_ dateString: String, currentDT: String ,index: Int) -> String {
        
        if(index == 0){ //Если нам нужно вывести п-лю что-то про сегодня
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            formatter.timeZone = .gmt //Время по гринвичу!
            
            if let serverDate = formatter.date(from: currentDT) {
                
                //Сравниваем текущую дату п-ля с датой по Гринвичу (API) и выводим что выдаёт п-лю сервер согласно его часовому поясу
                var gmtCalendar = Calendar.current
                gmtCalendar.timeZone = .gmt

                let localCalendar = Calendar.current // часовой пояс устройства

                let gmtDay = gmtCalendar.component(.day, from: serverDate)
                let localDay = localCalendar.component(.day, from: serverDate)

                if gmtDay == localDay {
                    return "Сегодня"
                } else {
                    if gmtDay > localDay{
                        return "Завтра"
                    }else{
                        return "Вчера"
                    }
                }
            }
        }
        
        //В противном случае выдаём ему день недели по гринвичу
        let datePart = dateString.components(separatedBy: "T").first ?? dateString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .gmt //Время по гринвичу!
        if let day = formatter.date(from: datePart) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ru_RU")
            displayFormatter.timeZone = .gmt
            displayFormatter.dateFormat = "EEE"
            return displayFormatter.string(from: day).capitalized
        }
        return dateString
    }
    
    
}
