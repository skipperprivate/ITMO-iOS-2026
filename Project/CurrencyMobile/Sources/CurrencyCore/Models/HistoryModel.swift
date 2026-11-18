//
//  HistoryModel.swift
//  Модель экрана «История курса» (MVVM).
//
//  Точки графика нормализуются здесь, а не в виде: это
//  арифметика, и её нужно покрывать тестами. Виду остаётся
//  умножить доли на свои размеры.
//

import Foundation
import Observation

/// Период истории. Значение случая — количество дней, поэтому
/// название и длительность не могут разойтись.
public enum HistoryPeriod: Int, CaseIterable, Sendable, Identifiable {
    case week = 7
    case month = 30
    case quarter = 90
    case year = 365

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .week: return "Неделя"
        case .month: return "Месяц"
        case .quarter: return "3 месяца"
        case .year: return "Год"
        }
    }
}

@MainActor
@Observable
public final class HistoryModel {

    //  MARK: - Состояние

    public let rate: Rate

    public private(set) var phase: LoadPhase = .idle
    public private(set) var points: [HistoryPoint] = []

    public var period: HistoryPeriod = .month

    private let library: RateLibrary

    public init(rate: Rate, library: RateLibrary) {
        self.rate = rate
        self.library = library
    }

    //  MARK: - Загрузка

    public func load() async {
        phase = .loading
        do {
            points = try await library.history(id: rate.id,
                                               days: period.rawValue)
            //  Пустой ответ — не сбой связи, но и графика нет.
            phase = points.isEmpty
                ? .failed("За этот период Центробанк данных не даёт.")
                : .ready
        } catch {
            phase = .failed("Не удалось загрузить историю.")
        }
    }

    public func choose(_ new: HistoryPeriod) async {
        guard new != period else { return }
        period = new
        await load()
    }

    //  MARK: - Сводка

    public var minimum: Decimal? { points.map(\.perUnit).min() }
    public var maximum: Decimal? { points.map(\.perUnit).max() }
    public var first: Decimal? { points.first?.perUnit }
    public var last: Decimal? { points.last?.perUnit }

    public var change: Decimal? {
        guard let first, let last else { return nil }
        return Converter.change(now: last, before: first)
    }

    public var changeText: String? {
        guard let change else { return nil }
        return Converter.changeText(change)
    }

    public var grew: Bool? {
        guard let change, change != 0 else { return nil }
        return change > 0
    }

    public var minimumText: String? {
        guard let minimum else { return nil }
        return Converter.text(minimum, digits: знаков) + " ₽"
    }

    public var maximumText: String? {
        guard let maximum else { return nil }
        return Converter.text(maximum, digits: знаков) + " ₽"
    }

    private var знаков: Int {
        (last ?? rate.perUnit) < 1 ? 4 : 2
    }

    //  MARK: - Точки графика

    /// Точки в долях 0…1: x — положение по времени, y — цена,
    /// где 0 это минимум периода, 1 — максимум.
    ///
    /// При неизменном курсе размах нулевой, поэтому линия
    /// рисуется посередине — иначе было бы деление на ноль.
    public var points01: [(x: Double, y: Double)] {
        guard points.count > 1,
              let низ = minimum, let верх = maximum else {
            return points.isEmpty ? [] : [(x: 0.5, y: 0.5)]
        }

        let размах = верх - низ
        let плоско = размах == 0

        //  Здесь это уже координаты, а не деньги, поэтому Double.
        let нижняя = вДробное(низ)
        let высота = вДробное(размах)

        return points.enumerated().map { номер, точка in
            let x = Double(номер) / Double(points.count - 1)
            let y = плоско
                ? 0.5
                : (вДробное(точка.perUnit) - нижняя) / высота
            return (x: x, y: y)
        }
    }

    /// Подписи по краям оси времени.
    public var axisLabels: (left: String, right: String)? {
        guard let a = points.first?.date,
              let b = points.last?.date else { return nil }
        return (DateBits.short(a), DateBits.short(b))
    }

    private func вДробное(_ d: Decimal) -> Double {
        NSDecimalNumber(decimal: d).doubleValue
    }
}
