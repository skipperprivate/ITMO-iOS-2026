import Foundation

enum ImageLoaderError: Error {
    case invalidResponse
    case badStatusCode(Int)
}

struct ImageLoader {

    static func loadImages(from urls: [URL]) async -> [Data] {
        await withTaskGroup(of: (Int, Data?).self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    let data = try? await download(url)
                    return (index, data)
                }
            }

            var results: [(Int, Data)] = []
            for await (index, data) in group {
                if let data {
                    results.append((index, data))
                }
            }

            return results
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }

    private static func download(_ url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw ImageLoaderError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ImageLoaderError.badStatusCode(http.statusCode)
        }
        return data
    }
}
