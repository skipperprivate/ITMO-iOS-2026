//
//  WeatherUIHelper.swift
//  Wetaher_app_IOS
//
//  Created by Sergey Sergeev on 07.10.2026.
//

import SwiftUI
// Вспомогательные структуры и утилиты для презентации погоды в UI
public enum WeatherUIHelper {
    // Определение текстового направления ветра по градусам (0-360)
    public static func degreesToDirection(_ degrees: Int) -> String {
        let directions = BaseText.WindDirection.all
        let normalized = ((degrees % 360) + 360) % 360
        let index = Int(round(Double(normalized) / 45.0)) % 8
        return directions[index]
    }

    // Описание статуса УФ-индекса
    public static func uvStatus(for index: Double) -> UVStatus {
        switch index {
        case ..<3.0:
            return UVStatus(descripiton: BaseText.UV.low, color: BaseColors.green)
        case 3.0..<6.0:
            return UVStatus(descripiton: BaseText.UV.moderate, color: BaseColors.yellow)
        case 6.0..<8.0:
            return UVStatus(descripiton: BaseText.UV.high, color: BaseColors.orange)
        case 8.0..<11.0:
            return UVStatus(descripiton: BaseText.UV.veryHigh, color: BaseColors.red)
        default:
            return UVStatus(descripiton: BaseText.UV.extreme, color: BaseColors.purple)
        }
    }

    // Описание статуса атмосферного давления
    public static func pressureStatus(for pressureHpa: Double) -> String {
        if pressureHpa >= 1010 && pressureHpa <= 1018 {
            return BaseText.Pressure.normal
        } else if pressureHpa > 1018 {
            return BaseText.Pressure.high
        } else {
            return BaseText.Pressure.low
        }
    }

    // Форматирование давления в миллиметрах ртутного столба (мм рт. ст.)
    public static func pressureMmHg(_ hPa: Double) -> Int {
        return Int(round(hPa * 0.750062))
    }

    // Форматирование видимости в километрах
    public static func visibility(_ metersOrKm: Double) -> Double {
        let km = metersOrKm >= 1000 ? metersOrKm / 1000.0 : metersOrKm
        return round(km)
    }

    // Описание статуса видимости
    public static func visibilityStatus(for km: Double) -> String {
        return km >= 10.0 ? BaseText.Visibility.excellent : BaseText.Visibility.limited
    }

    // Извлечение времени "ЧЧ:мм" из строки формата "YYYY-MM-DDTHH:mm"
    public static func formatTimeString(_ dateString: String, index: Int = 1, timeOffset: Int = 0) -> String {
        
        if(index == timeOffset){
            return BaseText.Date.now
        }
        
        let timePart = dateString.components(separatedBy: "T").last ?? dateString
        return String(timePart.prefix(5))
    }

    // Извлечение даты "YYYY-MM-DD" из строки формата "YYYY-MM-DDTHH:mm"
    public static func formatDateString(_ dateString: String) -> String {
        if let tIndex = dateString.firstIndex(of: "T") {
            return String(dateString[..<tIndex])
        }
        return dateString
    }

    // Форматирование даты в локализованный вид "d MMM" (например, "4 окт")
    public static func formatDateLocalizedString(_ dateLocalizedString: String) -> String {
        let datePart = dateLocalizedString.components(separatedBy: "T").first ?? dateLocalizedString
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        if let date = formatter.date(from: datePart) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ru_RU")
            displayFormatter.timeZone = .current
            displayFormatter.dateFormat = "d MMM"
            return displayFormatter.string(from: date)
        }
        return dateLocalizedString
    }
    
    // Формирование дня недели
    // Даты приходят уже в часовом поясе города (`timezone=auto`), поэтому сравниваем их как есть
    public static func formatDayOfWeekString(_ dateString: String, currentDT: String ,index: Int) -> String {

        let datePart = dateString.components(separatedBy: "T").first ?? dateString

        if(index == 0){ //Если нам нужно вывести п-лю что-то про сегодня

            let currentDatePart = currentDT.components(separatedBy: "T").first ?? currentDT

            if datePart == currentDatePart {
                return BaseText.Date.today
            } else {
                if datePart > currentDatePart{
                    return BaseText.Date.tomorrow
                }else{
                    return BaseText.Date.yesterday
                }
            }
        }

        // В противном случае выдаём ему день недели
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        if let day = formatter.date(from: datePart) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ru_RU")
            displayFormatter.timeZone = .current
            displayFormatter.dateFormat = "EEE"
            return displayFormatter.string(from: day).capitalized
        }
        return dateString
    }

}
