//  RateLibrary.swift
//  Единая точка доступа к данным для всех экранов.


import Foundation

/// Курсы за день вместе с ценами предыдущего рабочего дня.
public struct DayRates: Sendable, Equatable {

    /// Дата, к которой данные относятся фактически. В выходные
    /// не совпадает с запрошенной.
    public let date: Date

    public let rates: [Rate]

    /// Цена за единицу в предыдущий рабочий день: код → цена.
    public let previous: [String: Decimal]

    /// Данные из хранилища — сеть была недоступна. Экран обязан
    /// это показать.
    public let fromCache: Bool

    public init(date: Date, rates: [Rate],
                previous: [String: Decimal] = [:],
                fromCache: Bool = false) {
        self.date = date
        self.rates = rates
        self.previous = previous
        self.fromCache = fromCache
    }

    /// Изменение курса со вчера в процентах.
    public func change(for rate: Rate) -> Decimal? {
        guard let вчера = previous[rate.code] else { return nil }
        return Converter.change(now: rate.perUnit, before: вчера)
    }

    public func rate(code: String) -> Rate? {
        rates.first { $0.code == code }
    }
}

public actor RateLibrary {

    private let source: RateSource
    private let store: RateStore

    /// Кэш на время работы процесса: запрошенный день → результат.
    private var память: [String: DayRates] = [:]

    public init(source: RateSource, store: RateStore) {
        self.source = source
        self.store = store
    }

    //  MARK: - Курсы

    public func today() async throws -> DayRates {
        try await day(Date())
    }

    /// Курсы на день: сначала память процесса, затем сеть,
    /// и только при ошибке — хранилище.
    public func day(_ date: Date) async throws -> DayRates {
        let ключ = DateBits.forPerson(date)
        if let готовое = память[ключ] { return готовое }

        do {
            let свежее = try await загрузить(date)
            память[ключ] = свежее
            return свежее
        } catch {
            if let спасение = await изХранилища(date) {
                память[ключ] = спасение
                return спасение
            }
            throw error
        }
    }

    /// Принудительное обновление (жест «потянуть вниз»).
    public func refresh(_ date: Date = Date()) async throws -> DayRates {
        память.removeValue(forKey: DateBits.forPerson(date))
        return try await day(date)
    }

    private func загрузить(_ date: Date) async throws -> DayRates {
        //  Оба запроса уходят одновременно: последовательные
        //  удвоили бы время ожидания.
        async let сегодняЗадача = source.rates(on: date)
        async let вчераЗадача = source.rates(
            on: DateBits.shift(date, days: -1))

        let сегодня = try await сегодняЗадача

        //  Вчерашние курсы нужны только для стрелок изменения,
        //  поэтому их отсутствие не ошибка.
        var вчера = (try? await вчераЗадача) ?? []

        //  В выходные ЦБ отдаёт те же курсы, что и накануне.
        //  Тогда шагаем назад ещё раз — от фактической даты ответа.
        let настоящаяДата = сегодня.first?.date ?? date
        if let д = вчера.first?.date, DateBits.sameDay(д, настоящаяДата) {
            вчера = (try? await source.rates(
                on: DateBits.shift(настоящаяДата, days: -1))) ?? []
        }

        var прошлые: [String: Decimal] = [:]
        прошлые.reserveCapacity(вчера.count)
        for r in вчера { прошлые[r.code] = r.perUnit }

        //  Сохраняем под фактической датой, иначе пятничные курсы
        //  попали бы в базу как понедельничные.
        await store.save(сегодня, on: настоящаяДата)
        await store.trim(keepDays: 30)

        return DayRates(date: настоящаяДата, rates: сегодня,
                        previous: прошлые, fromCache: false)
    }

    private func изХранилища(_ date: Date) async -> DayRates? {
        if let точное = await store.rates(on: date), !точное.isEmpty {
            return DayRates(date: точное.first?.date ?? date,
                            rates: точное, fromCache: true)
        }
        //  Точного дня нет — отдаём самое свежее, экран подпишет дату.
        guard let свежее = await store.latest() else { return nil }
        return DayRates(date: свежее.date, rates: свежее.rates,
                        fromCache: true)
    }

    //  MARK: - История

    public func history(id: String, days: Int,
                        to date: Date = Date()) async throws
        -> [HistoryPoint] {
        try await source.history(id: id,
                                 from: DateBits.shift(date, days: -days),
                                 to: date)
    }

    /// Истории нескольких валют одной пачкой.
    ///
    /// Источник снимается в локальную переменную до создания
    /// группы: обращение к свойству актора внутри задач
    /// сериализовало бы их и свело параллельность на нет.
    public func histories(ids: [String], days: Int,
                          to date: Date = Date()) async
        -> [String: [HistoryPoint]] {

        let источник = source
        let начало = DateBits.shift(date, days: -days)

        return await withTaskGroup(
            of: (String, [HistoryPoint]).self
        ) { группа in
            for id in ids {
                группа.addTask {
                    //  Неудача по одной валюте не должна ронять
                    //  весь экран — у неё просто не будет графика.
                    let точки = (try? await источник.history(
                        id: id, from: начало, to: date)) ?? []
                    return (id, точки)
                }
            }
            var итог: [String: [HistoryPoint]] = [:]
            for await (id, точки) in группа {
                итог[id] = точки
            }
            return итог
        }
    }

    //  MARK: - Прочее

    /// Сбросить кэш процесса.
    public func forget() {
        память.removeAll()
    }
}
