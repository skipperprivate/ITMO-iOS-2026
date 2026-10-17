//
//  APIError.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 15.10.2026.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case encodingFailed(field: String)
    
    case noInternet
    
    case timeout
    case transport(description: String)
    
    case badRequest(message: String?)            // 400
    case unauthorized                            // 401
    case forbidden                               // 403
    case notFound                                // 404
    case tooManyRequests(retryAfter: Int?)       // 429
    case serverError(status: Int)                // 500
    case unexpectedStatus(status: Int)
    
    case noData
    case decoding
    case code(status: Int)
    
    case decodingFailed(path: String, reason: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .encodingFailed(let field): return "Ошибка формирования запроса: \(field)"
        case .timeout: return "Превышено время ожидания"
        case .badRequest(let message): return message.map { "Неверный запрос: \($0)" } ?? "Неверный запрос"
        case .unauthorized: return "Требуется авторизация"
        case .forbidden: return "Доступ запрещён"
        case .notFound: return "Данные не найдены"
        case .tooManyRequests(let retryAfter):
            if let retryAfter {
                return "Слишком много запросов. Повторите через \(retryAfter) сек."
            }
            return "Слишком много запросов. Попробуйте позже"
        case .serverError(let status): return "Ошибка на сервере (\(status))"
        case .unexpectedStatus(let status): return "Неожиданный статус ответа: \(status)"
        case .noData: return "Пустой ответ"
        case .decoding: return "Ошибка чтения данных"
        case .code(let code): return "Ошибка: \(code)"
        case .transport(let description): return "Ошибка сети: \(description)"
        case .noInternet: return "Нет подключения к интернету"
        case .decodingFailed(let path, let reason): return "Ошибка чтения json: \(path) : \(reason)"
        }
    }
}
