import Combine
import Foundation

@MainActor
protocol NetworkExamplesViewOutput: ObservableObject {
    var state: NetworkExamplesViewState { get }

    func perform(_ example: NetworkExample) async

    func dismissToast(id: UUID)

    func goBack()
}
