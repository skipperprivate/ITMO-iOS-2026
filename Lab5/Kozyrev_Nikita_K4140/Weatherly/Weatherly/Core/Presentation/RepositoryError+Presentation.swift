//
//  RepositoryError+Presentation.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

extension RepositoryError {
    var title: String {
        switch self {
        case .offline: "Нет подключения к интернету"
        case .timedOut: "Сервер долго не отвечает"
        case .serviceUnavailable: "Сервис погоды недоступен"
        case .rateLimited: "Слишком много запросов"
        case .requestRejected: "Не удалось получить прогноз"
        case .invalidData: "Не удалось прочитать прогноз"
        case .storageFailed: "Не удалось сохранить данные"
        case .favoritesLimitReached: "Мест уже \(FavoritesPolicy.maximumCount)"
        case .unknown: "Что-то пошло не так"
        }
    }

    var message: String {
        switch self {
        case .offline: "Проверьте сеть — мы обновим данные, как только она появится"
        case .timedOut: "Попробуйте ещё раз через пару секунд"
        case .serviceUnavailable: "Open-Meteo временно не отвечает, попробуйте позже"
        case .rateLimited: "Подождите минуту и попробуйте снова"
        case .requestRejected: "Сервис не принял запрос для этого места"
        case .invalidData: "Сервис прислал неполные данные, попробуйте обновить"
        case .storageFailed: "Попробуйте ещё раз"
        case .favoritesLimitReached: "Удалите одно из мест, чтобы добавить новое"
        case .unknown: "Попробуйте ещё раз"
        }
    }

    // Short form for an inline banner over data that is still shown.
    var bannerText: String {
        switch self {
        case .offline: "Нет сети — показаны прошлые данные"
        case .rateLimited: "Лимит запросов — обновим позже"
        case .storageFailed: "Не удалось сохранить изменения"
        case .favoritesLimitReached: "Можно сохранить не больше \(FavoritesPolicy.maximumCount) мест"
        default: "Не удалось обновить данные"
        }
    }

    var symbolName: String {
        switch self {
        case .offline: "wifi.slash"
        case .timedOut: "clock.badge.exclamationmark"
        case .serviceUnavailable: "icloud.slash"
        case .rateLimited: "hourglass"
        case .storageFailed: "externaldrive.badge.exclamationmark"
        case .favoritesLimitReached: "star.slash"
        case .requestRejected, .invalidData, .unknown: "exclamationmark.triangle"
        }
    }
}
