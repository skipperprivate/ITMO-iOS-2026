//
//  RatesModel.swift
//  Модель экрана «Курсы» (MVVM).
//
//  Состояние и вся логика экрана живут здесь: SwiftUI-вид
//  нельзя покрыть тестами, а обычный класс — можно.
//

import Foundation
import Observation

/// Состояние загрузки.
///
/// Перечисление вместо набора флагов: три булевых поля допускали
/// бы невозможные сочетания вроде «грузится и одновременно упало».
public enum LoadPhase: Equatable, Sendable {
    case idle
    case loading
    case ready
    case failed(String)
}

@MainActor
@Observable
public final class RatesModel {

    //  MARK: - Состояние

    public private(set) var phase: LoadPhase = .idle
    public private(set) var day: DayRates?
    public private(set) var favourites: Set<String> = []

    /// Строка поиска, редактируется полем ввода.
    public var search: String = ""

    /// Фильтр «только избранное».
    public var onlyFavourites = false

    private let library: RateLibrary
    private let favStore: Favourites

    public init(library: RateLibrary, favourites: Favourites) {
        self.library = library
        self.favStore = favourites
    }

    //  MARK: - Действия

    public func load() async {
        //  SwiftUI может вызвать .task повторно; второй запрос
        //  в сеть при этом не нужен.
        guard phase != .loading else { return }
        phase = .loading
        favourites = await favStore.all()
        do {
            day = try await library.today()
            phase = .ready
        } catch {
            phase = .failed(понятно(error))
        }
    }

    public func refresh() async {
        do {
            day = try await library.refresh()
            phase = .ready
        } catch {
            phase = .failed(понятно(error))
        }
    }

    public func toggleFavourite(_ code: String) async {
        let было = favourites.contains(code)
        await favStore.set(code, on: !было)
        //  Перечитываем из хранилища: на экране должно быть то,
        //  что действительно сохранилось.
        favourites = await favStore.all()
    }

    public func isFavourite(_ code: String) -> Bool {
        favourites.contains(code)
    }

    //  MARK: - Данные для показа

    /// Отфильтрованный и отсортированный список: избранные сверху,
    /// остальные по алфавиту.
    public var visible: [Rate] {
        var список = day?.rates ?? []

        if onlyFavourites {
            список = список.filter { favourites.contains($0.code) }
        }

        let запрос = search.trimmingCharacters(in: .whitespaces)
        if !запрос.isEmpty {
            let нижний = запрос.lowercased()
            список = список.filter {
                $0.code.lowercased().contains(нижний)
                    || $0.name.lowercased().contains(нижний)
            }
        }

        return список.sorted { a, b in
            let aОтмечена = favourites.contains(a.code)
            let bОтмечена = favourites.contains(b.code)
            if aОтмечена != bОтмечена { return aОтмечена }
            return a.code < b.code
        }
    }

    /// Подпись под заголовком: дата курсов и их источник.
    public var subtitle: String {
        guard let day else { return "Загружаем…" }
        let дата = DateBits.forPerson(day.date)
        return day.fromCache
            ? "Сохранённые данные на \(дата) — сети нет"
            : "Курсы ЦБ РФ на \(дата)"
    }

    public func changeText(for rate: Rate) -> String? {
        guard let percent = day?.change(for: rate) else { return nil }
        return Converter.changeText(percent)
    }

    /// `nil`, если курс не изменился и стрелку рисовать не нужно.
    public func grew(_ rate: Rate) -> Bool? {
        guard let percent = day?.change(for: rate), percent != 0 else {
            return nil
        }
        return percent > 0
    }

    //  MARK: - Ошибки

    /// Текст ошибки для экрана. Системные описания вроде
    /// `NSURLErrorDomain error -1009` пользователю ничего не дают.
    func понятно(_ error: Error) -> String {
        if let сетевая = error as? NetError {
            switch сетевая {
            case .offline:
                return "Нет связи с Центробанком. Проверьте интернет."
            case .http(let код):
                return "Сервер Центробанка ответил ошибкой \(код)."
            case .empty:
                return "Центробанк прислал пустой ответ."
            case .badURL:
                return "Неверный адрес запроса."
            }
        }
        if let разбор = error as? CBRParseError {
            switch разбор {
            case .emptyList:
                return "Центробанк не дал курсов на этот день."
            case .notValCurs, .noDate:
                return "Ответ Центробанка не удалось разобрать."
            }
        }
        if error is XMLError {
            return "Ответ Центробанка не удалось разобрать."
        }
        return "Не удалось загрузить курсы."
    }
}
