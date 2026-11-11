//
//  WeatherStore.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

import Foundation
import SwiftData

/// Хранение последнего успешного ответа сети по каждому городу.
@MainActor
public final class WeatherStore {
    public static let shared = WeatherStore(container: makeContainer())

    /// Один долгоживущий контекст: операции чтения и записи идут
    /// последовательно на главном акторе.
    private let context: ModelContext

    public init(container: ModelContainer) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        self.context = context
    }

    /// Если постоянное хранилище недоступно, приложение продолжает работать с хранилищем в памяти, а не падает на старте.
    public static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: WeatherRecord.self, configurations: configuration)
        } catch {
            #if DEBUG
            print("Не удалось открыть хранилище погоды: \(error)")
            #endif
            let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
            return try! ModelContainer(for: WeatherRecord.self, configurations: fallback)
        }
    }

    /// Сохраняет снимок, заменяя предыдущий снимок этого города.
    public func save(_ entity: WeatherEntity) throws {
        do {
            let payload = try JSONEncoder().encode(entity)

            if let existing = try fetchRecord(cityID: entity.cityID) {
                existing.payload = payload
            } else {
                context.insert(WeatherRecord(cityID: entity.cityID, payload: payload))
            }

            try context.save()
        } catch {
            context.rollback()
            throw WeatherStorageError(
                errorCode: 701,
                errorDescription: "Не удалось сохранить данные о погоде: \(error.localizedDescription)"
            )
        }
    }

    public func fetch(cityID: Int) throws -> WeatherEntity? {
        do {
            guard let record = try fetchRecord(cityID: cityID) else { return nil }
            return try JSONDecoder().decode(WeatherEntity.self, from: record.payload)
        } catch {
            throw WeatherStorageError(
                errorCode: 702,
                errorDescription: "Не удалось прочитать данные о погоде: \(error.localizedDescription)"
            )
        }
    }

    public func delete(cityID: Int) throws {
        do {
            guard let record = try fetchRecord(cityID: cityID) else { return }
            context.delete(record)
            try context.save()
        } catch {
            throw WeatherStorageError(
                errorCode: 703,
                errorDescription: "Не удалось удалить данные о погоде: \(error.localizedDescription)"
            )
        }
    }

    public func deleteAll() throws {
        do {
            try context.delete(model: WeatherRecord.self)
            try context.save()
        } catch {
            throw WeatherStorageError(
                errorCode: 704,
                errorDescription: "Не удалось очистить хранилище погоды: \(error.localizedDescription)"
            )
        }
    }

    private func fetchRecord(cityID: Int) throws -> WeatherRecord? {
        var descriptor = FetchDescriptor<WeatherRecord>(
            predicate: #Predicate { $0.cityID == cityID }
        )
        descriptor.fetchLimit = 1

        return try context.fetch(descriptor).first
    }
}
