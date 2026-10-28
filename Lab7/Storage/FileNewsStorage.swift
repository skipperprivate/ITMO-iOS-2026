import Foundation

@MainActor
struct FileNewsStorage: NewsStorage {
    private var fileURL: URL {
        let folder = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return folder.appendingPathComponent("news.json")
    }

    func load() throws -> [News] {
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([News].self, from: data)
    }

    func save(_ news: [News]) throws {
        let data = try JSONEncoder().encode(news)
        try data.write(to: fileURL, options: .atomic)
    }
}
