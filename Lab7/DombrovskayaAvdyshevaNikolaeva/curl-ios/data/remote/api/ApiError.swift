import Foundation

enum ApiError: LocalizedError {
    case invalidURL
    case network(Error)
    case decoding(Error)
    case http(code: Int, message: String?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .network(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .decoding:
            return "Ошибка обработки данных"
        case .http(let code, let message):
            return "Ошибка сервера (\(code))\(message.map { ": \($0)" } ?? "")"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }

    var code: Int {
        switch self {
        case .http(let code, _): return code
        default: return -1
        }
    }
}
