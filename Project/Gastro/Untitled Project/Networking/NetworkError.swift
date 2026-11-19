import Foundation

nonisolated enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding
    case transport(URLError.Code)

    var errorDescription: String? {
        switch self {
            case .invalidURL: "Не удалось создать запрос."
            case .invalidResponse: "Сервер вернул некорректный ответ."
            case .httpStatus(400): "HTTP 400: сервер отклонил запрос. Проверьте отправленные данные."
            case .httpStatus(401): "HTTP 401: для запроса нужна авторизация."
            case .httpStatus(403): "HTTP 403: нет доступа к этому ресурсу."
            case .httpStatus(404): "HTTP 404: запрошенный ресурс не найден."
            case .httpStatus(429): "HTTP 429: слишком много запросов. Попробуйте позже."
            case .httpStatus(let code) where (500...599).contains(code):
                "Ошибка сервера (HTTP \(code)). Попробуйте позже."
            case .httpStatus(let code): "Ошибка запроса: HTTP \(code)."
            case .decoding: "Не удалось прочитать данные в ответе сервера."
            case .transport(.notConnectedToInternet): "Нет подключения к интернету. Проверьте соединение."
            case .transport(.timedOut): "Сервер не ответил вовремя. Повторите запрос."
            case .transport: "Не удалось связаться с сервером. Попробуйте ещё раз."
        }
    }

}
