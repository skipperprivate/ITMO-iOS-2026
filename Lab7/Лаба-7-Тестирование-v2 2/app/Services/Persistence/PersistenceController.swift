import SwiftData

@MainActor
struct PersistenceController {
    func makeContainer() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
