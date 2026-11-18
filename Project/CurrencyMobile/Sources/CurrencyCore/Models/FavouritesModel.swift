//
//  FavouritesModel.swift
//  Модель экрана «Избранное» (MVVM).
//
//  Графики за неделю для всех отмеченных валют загружаются
//  параллельно (RateLibrary.histories): последовательная
//  загрузка умножала бы ожидание на их количество.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FavouritesModel {

    public private(set) var phase: LoadPhase = .idle

    /// Отмеченные валюты с текущими курсами.
    public private(set) var rates: [Rate] = []

    /// Короткие графики: буквенный код → точки за неделю.
    public private(set) var sparks: [String: [HistoryPoint]] = [:]

    /// Отмеченных валют нет — экран показывает подсказку,
    /// а не пустой список.
    public var isEmpty: Bool { phase == .ready && rates.isEmpty }

    private let library: RateLibrary
    private let favStore: Favourites

    public init(library: RateLibrary, favourites: Favourites) {
        self.library = library
        self.favStore = favourites
    }

    public func load() async {
        guard phase != .loading else { return }
        phase = .loading

        let коды = await favStore.all()
        guard !коды.isEmpty else {
            rates = []
            sparks = [:]
            phase = .ready
            return
        }

        do {
            let день = try await library.today()
            rates = день.rates
                .filter { коды.contains($0.code) }
                .sorted { $0.code < $1.code }

            //  История доступна только по внутреннему коду ЦБ.
            let поВнутренним = await library.histories(
                ids: rates.map(\.id), days: 7)

            //  Экран работает с буквенными кодами, поэтому
            //  перекладываем результат на них.
            var собранное: [String: [HistoryPoint]] = [:]
            for r in rates {
                собранное[r.code] = поВнутренним[r.id] ?? []
            }
            sparks = собранное
            phase = .ready
        } catch {
            phase = .failed("Не удалось загрузить избранное.")
        }
    }

    public func remove(_ code: String) async {
        await favStore.set(code, on: false)
        rates.removeAll { $0.code == code }
        sparks.removeValue(forKey: code)
    }

    /// Точки мини-графика в долях 0…1.
    public func spark01(for code: String) -> [(x: Double, y: Double)] {
        let точки = sparks[code] ?? []
        guard точки.count > 1 else { return [] }

        let значения = точки.map {
            NSDecimalNumber(decimal: $0.perUnit).doubleValue
        }
        guard let низ = значения.min(),
              let верх = значения.max() else { return [] }
        let размах = верх - низ

        return значения.enumerated().map { номер, v in
            (x: Double(номер) / Double(значения.count - 1),
             y: размах == 0 ? 0.5 : (v - низ) / размах)
        }
    }

    /// Направление за неделю по мини-графику.
    public func grewThisWeek(_ code: String) -> Bool? {
        let точки = sparks[code] ?? []
        guard let первая = точки.first?.perUnit,
              let последняя = точки.last?.perUnit,
              первая != последняя else { return nil }
        return последняя > первая
    }
}
