import Foundation

enum AuthError: LocalizedError {
    case validation(String)
    case emptyServerResponse
    case invalidToken
    case httpError(code: Int, body: String)
    case network(String)
    case deleteAccount(String)

    var errorDescription: String? {
        switch self {
        case let .validation(message):    return message
        case .emptyServerResponse:        return "Пустой ответ от сервера"
        case .invalidToken:               return "Не удалось расшифровать ID пользователя из токена"
        case let .httpError(code, body):  return "Ошибка \(code) - \(body)"
        case let .network(message):       return "Ошибка сети: \(message)"
        case let .deleteAccount(message): return "Ошибка при удалении аккаунта: \(message)"
        }
    }
}
