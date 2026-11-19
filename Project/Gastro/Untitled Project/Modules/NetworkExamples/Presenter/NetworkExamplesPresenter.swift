import Combine
import Foundation

@MainActor
final class NetworkExamplesPresenter: NetworkExamplesViewOutput {
    @Published private(set) var state = NetworkExamplesViewState()
    private let interactor: any NetworkExamplesInteractor
    private let router: any NetworkExamplesRouter

    init(interactor: any NetworkExamplesInteractor, router: any NetworkExamplesRouter) {
        self.interactor = interactor
        self.router = router
    }

    func perform(_ example: NetworkExample) async {
        guard state.activeExample == nil else { return }
        state.activeExample = example
        state.toast = nil
        state.result = nil
        defer { state.activeExample = nil }

        do {
            let result = try await interactor.perform(example)
            try Task.checkCancellation()
            state.result = result
        } catch is CancellationError {
            // Navigation away cancels the request without an error toast.
        } catch {
            guard !Task.isCancelled else { return }
            state.toast = ToastMessage(text: error.localizedDescription)
        }
    }

    func dismissToast(id: UUID) {
        guard state.toast?.id == id else { return }
        state.toast = nil
    }

    func goBack() {
        router.goBack()
    }
}
