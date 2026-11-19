@MainActor
final class NetworkExamplesInteractorImpl: NetworkExamplesInteractor {
    private let service: any NetworkExamplesService

    init(service: any NetworkExamplesService) {
        self.service = service
    }

    func perform(_ example: NetworkExample) async throws -> String {
        try await service.perform(example)
    }
}
