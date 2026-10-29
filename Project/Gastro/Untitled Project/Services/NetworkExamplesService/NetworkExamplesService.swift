protocol NetworkExamplesService: Sendable {
    func perform(_ example: NetworkExample) async throws -> String
}
