@MainActor
protocol NetworkExamplesInteractor {
    func perform(_ example: NetworkExample) async throws -> String
}
