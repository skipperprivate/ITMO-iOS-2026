import Foundation
import SwiftData

enum ModelContainerFactory {
    @MainActor
    static func make(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([FavoriteCityModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
