@MainActor
protocol NewsStorage {
    func load() throws -> [News]
    func save(_ news: [News]) throws
}
