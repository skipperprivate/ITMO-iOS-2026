nonisolated enum NetworkExample: Int, CaseIterable, Identifiable, Sendable {
    case publish = 201
    case badRequest = 400
    case unauthorized = 401
    case rateLimited = 429
    case serverError = 500

    var id: Int { rawValue }
}
