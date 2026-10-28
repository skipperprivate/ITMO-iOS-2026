import SwiftData

@MainActor
enum PersistenceController {
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([Item.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
