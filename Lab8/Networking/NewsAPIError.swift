import Foundation

enum NewsAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неправильный адрес сервера."

        case .invalidResponse:
            return "Получен неизвестный ответ сервера."

        case .serverError(let code):
            return "Ошибка сервера. Код: \(code)."

        case .invalidData:
            return "Не удалось прочитать новости из ответа сервера."
        }
    }
}
