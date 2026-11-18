//  RateStore.swift
//  Протоколы хранилища и реализация в памяти.

import Foundation

//  MARK: - Протоколы

/// Кэш загруженных курсов.
///
/// Методы асинхронные, потому что за протоколом может стоять
/// дисковая база, а обращаться к ней из главного потока нельзя.
public protocol RateStore: Sendable {

    /// Сохранить курсы за день, заменив прежние записи этого дня.
    func save(_ rates: [Rate], on date: Date) async

    func rates(on date: Date) async -> [Rate]?

    /// Самые свежие данные — для показа без сети.
    func latest() async -> (date: Date, rates: [Rate])?

    /// Оставить только несколько последних дней.
    func trim(keepDays: Int) async
}

/// Отмеченные валюты. Хранится буквенный код.
public protocol Favourites: Sendable {
    func all() async -> Set<String>
    func set(_ code: String, on: Bool) async
}

//  MARK: - Реализация в памяти

/// Хранилище на время работы процесса: тесты, превью и запасной
/// вариант, если база не открылась.
///
/// Actor, потому что обращения приходят из разных задач:
/// фоновая загрузка может дописывать результат одновременно
/// с обновлением по жесту.
public actor MemoryRateStore: RateStore, Favourites {

    /// Ключ — день в формате `18.11.2026`, чтобы время суток
    /// не создавало отдельных записей.
    private var поДням: [String: [Rate]] = [:]
    private var избранное: Set<String> = []

    public init(избранное: Set<String> = []) {
        self.избранное = избранное
    }

    private func ключ(_ date: Date) -> String {
        DateBits.forPerson(date)
    }

    //  MARK: RateStore

    public func save(_ rates: [Rate], on date: Date) async {
        поДням[ключ(date)] = rates
    }

    public func rates(on date: Date) async -> [Rate]? {
        поДням[ключ(date)]
    }

    public func latest() async -> (date: Date, rates: [Rate])? {
        //  Сравниваем даты, а не строки-ключи: «02.12» как строка
        //  меньше, чем «18.11».
        let все = поДням.values.compactMap { список -> (Date, [Rate])? in
            guard let first = список.first else { return nil }
            return (first.date, список)
        }
        guard let свежее = все.max(by: { $0.0 < $1.0 }) else { return nil }
        return (date: свежее.0, rates: свежее.1)
    }

    public func trim(keepDays: Int) async {
        //  Ноль означал бы «удалить всё»; такая просьба скорее
        //  описка, чем намерение.
        guard keepDays >= 1 else { return }
        let даты = поДням.compactMap { $0.value.first?.date }
            .sorted(by: >)
        guard даты.count > keepDays else { return }
        let граница = даты[keepDays - 1]
        for (k, v) in поДням where (v.first?.date ?? .distantPast) < граница {
            поДням.removeValue(forKey: k)
        }
    }

    //  MARK: Favourites

    public func all() async -> Set<String> { избранное }

    public func set(_ code: String, on: Bool) async {
        if on { избранное.insert(code) } else { избранное.remove(code) }
    }
}
