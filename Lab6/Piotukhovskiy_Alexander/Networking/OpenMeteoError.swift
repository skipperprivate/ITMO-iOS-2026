import Foundation

enum OpenMeteoError: LocalizedError {
    case invalidURL
    case invalidResponse
    case http(statusCode: Int, reason: String?)
    case network(URLError.Code)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось сформировать адрес запроса."
        case .invalidResponse:
            return "Open-Meteo вернул неполные или некорректные данные."
        case let .http(statusCode, reason):
            if statusCode == 429 {
                return "Слишком много запросов к Open-Meteo. Повторите позже."
            }
            if let reason, !reason.isEmpty {
                return "Open-Meteo (HTTP \(statusCode)): \(reason)"
            }
            return "Сервис Open-Meteo недоступен (HTTP \(statusCode))."
        case .network(.notConnectedToInternet):
            return "Нет подключения к интернету."
        case .network(.timedOut):
            return "Сервис не ответил вовремя. Повторите запрос."
        case .network(.networkConnectionLost):
            return "Соединение прервалось. Повторите запрос."
        case .network:
            return "Не удалось связаться с Open-Meteo. Повторите запрос."
        }
    }
}
