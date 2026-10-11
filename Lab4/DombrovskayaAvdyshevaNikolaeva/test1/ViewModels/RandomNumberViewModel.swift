import Foundation
import SwiftData
import Combine

@MainActor
final class RandomNumberViewModel: ObservableObject {
    @Published var randomNumber: Int = 0
    @Published var generationCount: Int = 0
    
    private let defaults = UserDefaultsService.shared
    private var modelContext: ModelContext?
    
    init() {
        generationCount = defaults.generationCount
        randomNumber = defaults.lastNumber
    }
    
    func configure(with context: ModelContext) {
        self.modelContext = context
    }
    
    func generateRandomNumber() {
        let newNumber = Int.random(in: 1...100)
        randomNumber = newNumber
        
        defaults.lastNumber = newNumber
        generationCount += 1
        defaults.generationCount = generationCount
        
        guard let context = modelContext else { return }
        let entry = NumberEntry(value: newNumber)
        context.insert(entry)
        try? context.save()
    }
    
    func fetchAll() -> [NumberEntry] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<NumberEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func updateEntry(_ entry: NumberEntry, newValue: Int) {
        entry.value = newValue
        entry.date = Date()
        try? modelContext?.save()
    }
    
    func delete(_ entry: NumberEntry) {
        modelContext?.delete(entry)
        try? modelContext?.save()
    }
    
    func clearHistory() {
        guard let context = modelContext else { return }
        try? context.delete(model: NumberEntry.self)
        try? context.save()
        
        defaults.reset()
        generationCount = 0
    }
}
