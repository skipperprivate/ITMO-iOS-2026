import Foundation

struct BundleJSONLoader: Sendable {
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    nonisolated func load<T: Decodable & Sendable>(
        _ resource: String,
        extension ext: String = "json"
    ) async throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: ext) else {
            throw AppError.resourceNotFound("\(resource).\(ext)")
        }
        return try await Task.detached(priority: .userInitiated) {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw AppError.decodingFailed(String(describing: error))
            }
        }.value
    }
}
