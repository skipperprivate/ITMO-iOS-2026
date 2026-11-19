import Combine
import Foundation

@MainActor
protocol RemoteRecipeDetailViewOutput: ObservableObject {
    var state: RemoteRecipeDetailViewState { get }

    func load() async

    func goBack()
}
