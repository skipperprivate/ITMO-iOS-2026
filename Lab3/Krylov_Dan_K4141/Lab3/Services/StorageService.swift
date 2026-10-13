import Foundation
import SwiftData

@MainActor
final class StorageService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func add(value: Int) {
        context.insert(NumberRecord(value: value))
        save()
    }

    func fetchAll() -> [NumberRecord] {
        let descriptor = FetchDescriptor<NumberRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func update(_ record: NumberRecord, newValue: Int) {
        record.value = newValue
        save()
    }

    func delete(_ record: NumberRecord) {
        context.delete(record)
        save()
    }

    private func save() {
        try? context.save()
    }
}
