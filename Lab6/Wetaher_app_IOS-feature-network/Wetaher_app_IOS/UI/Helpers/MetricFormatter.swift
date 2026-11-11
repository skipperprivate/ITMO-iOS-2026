//
//  MetricFormatter.swift
//  Wetaher_app_IOS
//
//  Created by Sergey Sergeev on 07.10.2026.
//

import Foundation

/// Единицы измерения
public enum MetricFormatter {
    /// Форматирование температуры в градусах Цельсия (°C)
    public static func temperature(_ celsius: Double, showSign: Bool = true) -> String {
        let value = Int(round(celsius))
        if showSign && value > 0 {
            return "+\(value)°"
        } else {
            return "\(value)°"
        }
    }
    
    public static func dateInDaily( date: String) -> String{
        return date.replacingOccurrences(of: "-", with: ".")
    }

    /// Форматирование скорости ветра в метрах в секунду
    public static func windSpeed(_ mps: Double) -> String {
        String(format: "%.1f км/ч", mps)
    }

    /// Форматирование давления в гектопаскалях (1 гПа = 100 Па)
    public static func pressure(_ hPa: Double) -> String {
        "\(Int(round(hPa))) гПа"
    }

    /// Форматирование давления в миллиметрах ртутного столба (мм рт. ст.)
    public static func pressureMmHg(_ mmHg: Int) -> String {
        return "\(mmHg) мм рт. ст."
    }

    /// Форматирование видимости в километрах (< 443)
    public static func visibility(_ km: Double) -> String {
        return "\(Int(km)) км"
    }
}
