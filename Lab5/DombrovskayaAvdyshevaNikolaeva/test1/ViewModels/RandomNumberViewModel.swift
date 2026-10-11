import Foundation
import SwiftData
import Combine

@MainActor
final class RandomNumberViewModel: ObservableObject {
    @Published var randomNumber: Int = 0
    @Published var generationCount: Int = 0
    @Published var evenSum: Int = 0
    @Published var evenCount: Int = 0
    @Published var isRunning: Bool = false
    
    private let defaults = UserDefaultsService.shared
    private var modelContext: ModelContext?
    

    private let generator = NumberGenerator()
    private let checker = EvenNumberChecker()
    private var runningTasks: [Task<Void, Never>] = []
    
    init() {
        generationCount = defaults.generationCount
        randomNumber = defaults.lastNumber
    }
    
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    func startGeneration() {
        guard !isRunning else { return }
        isRunning = true
        
        let (numberStream, continuation) = AsyncStream<Int>.makeStream()
        
        let generationTask = Task {
            for await number in await generator.generate() {
             
                self.randomNumber = number
                self.generationCount += 1
                   
                self.defaults.lastNumber = number
                self.defaults.generationCount = self.generationCount
                
              
                if let context = self.modelContext {
                    let entry = NumberEntry(value: number)
                    context.insert(entry)
                    try? context.save()
                }
                

                continuation.yield(number)
            }
            continuation.finish()
        }

        let checkingTask = Task {
            for await number in numberStream {
                
                if await checker.check(number) {
                    
                    let sum = await checker.sum
                    let count = await checker.evenCount
                    
                    self.evenSum = sum
                    self.evenCount = count
                }
            }
        }
        
        runningTasks = [generationTask, checkingTask]
    }
    
    func stopGeneration() {
        runningTasks.forEach { $0.cancel() }
        runningTasks.removeAll()
        isRunning = false
    }
    
    func resetEvenCounter() {
        Task {
            await checker.reset()
            self.evenSum = 0
            self.evenCount = 0
        }
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
        resetEvenCounter()
    }
}
