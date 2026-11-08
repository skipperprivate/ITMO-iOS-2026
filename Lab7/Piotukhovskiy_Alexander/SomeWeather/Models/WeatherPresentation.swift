import Foundation

// Подготовлены для open-meteo
enum WeatherPresentation {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "Ясно"
        case 1: return "Преимущественно ясно"
        case 2: return "Переменная облачность"
        case 3: return "Пасмурно"
        case 45, 48: return "Туман"
        case 51, 53, 55: return "Морось"
        case 56, 57: return "Ледяная морось"
        case 61, 63, 65: return "Дождь"
        case 66, 67: return "Ледяной дождь"
        case 71, 73, 75: return "Снег"
        case 77: return "Снежные зёрна"
        case 80, 81, 82: return "Ливень"
        case 85, 86: return "Снежные заряды"
        case 95: return "Гроза"
        case 96, 99: return "Гроза с градом"
        default: return "Нет данных"
        }
    }

    static func symbol(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 0, 1: return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 2: return isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 56, 57: return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67: return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.rain.fill"
        default: return "questionmark.circle"
        }
    }
}
