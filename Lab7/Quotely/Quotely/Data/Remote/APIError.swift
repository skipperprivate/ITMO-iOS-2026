//
//  APIError.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 15.10.2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noInternet
    case timedOut
    case connectionFailed
    case http(status: Int, message: String?)
    case encoding
    case decoding
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Не удалось сформировать адрес запроса."
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."
        case .noInternet:
            return "Нет подключения к интернету. Проверьте соединение и повторите попытку."
        case .timedOut:
            return "Сервер не ответил вовремя. Повторите попытку."
        case .connectionFailed:
            return "Не удалось связаться с сервером. Повторите попытку."
        case let .http(status, message):
            let details = message ?? "Повторите попытку позже."
            if status >= 500 {
                return "Сервер временно недоступен (HTTP \(status)). \(details)"
            } else {
                return "Запрос не принят сервером (HTTP \(status)). \(details)"
            }
        case .encoding:
            return "Не удалось подготовить данные для отправки."
        case .decoding:
            return "Не удалось прочитать данные сервера: неожиданный формат ответа."
        case .unknown:
            return "Неизвестная ошибка при обращении к серверу. Повторите попытку."
        }
    }
}
