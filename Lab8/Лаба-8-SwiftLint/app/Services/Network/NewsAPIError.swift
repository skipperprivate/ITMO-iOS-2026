import Foundation

enum NewsAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case invalidData
    case invalidInput
    case offline
    case timeout
    case connection

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Сервер вернул некорректный ответ."
        case .httpStatus(429): "Слишком много запросов. Попробуйте немного позже."
        case .httpStatus(let code): "Сервер вернул HTTP \(code). Попробуйте позже."
        case .invalidData: "Не удалось прочитать данные сервера: неверный формат или пустые поля."
        case .invalidInput: "Заполните заголовок и текст публикации."
        case .offline: "Нет подключения к интернету. Проверьте сеть и повторите попытку."
        case .timeout: "Сервер не ответил вовремя. Повторите попытку."
        case .connection: "Не удалось соединиться с сервером. Повторите попытку позже."
        }
    }
}
