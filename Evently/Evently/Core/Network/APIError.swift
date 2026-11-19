import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
    case network(URLError)
    case unexpectedResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось сформировать запрос."

        case .invalidResponse:
            return "Сервер вернул некорректный ответ."

        case .httpStatus(let code):
            switch code {
            case 400:
                return "Сервер не смог обработать запрос."

            case 401:
                return "Ошибка авторизации API. Проверьте ключ доступа."

            case 403:
                return "Доступ к сервису запрещён. Проверьте подключение и доступность API."

            case 404:
                return "Запрашиваемые данные не найдены."

            case 429:
                return "Превышен лимит запросов. Попробуйте позже."

            case 500...599:
                return "Сервис временно недоступен. Попробуйте позже."

            default:
                return "Не удалось выполнить запрос (HTTP \(code))."
            }

        case .decoding:
            return "Не удалось обработать данные сервера."

        case .network(let error):
            switch error.code {
            case .notConnectedToInternet:
                return "Нет подключения к интернету."

            case .timedOut:
                return "Сервер слишком долго отвечает."

            case .cannotFindHost, .cannotConnectToHost:
                return "Не удалось подключиться к серверу."

            case .networkConnectionLost:
                return "Соединение с интернетом было прервано."

            case .secureConnectionFailed:
                return "Не удалось установить защищённое соединение."

            default:
                return "Ошибка сети. Проверьте подключение."
            }

        case .unexpectedResponse:
            return "Сервис вернул неожиданные данные."
        }
    }

    static func map(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }

        if let urlError = error as? URLError {
            return .network(urlError)
        }

        if let decodingError = error as? DecodingError {
            return .decoding(decodingError)
        }

        return .unexpectedResponse
    }
}
