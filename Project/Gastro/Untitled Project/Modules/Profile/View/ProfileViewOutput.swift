import Combine
import Foundation

@MainActor
protocol ProfileViewOutput: ObservableObject {
    var state: ProfileViewState { get }

    func load()

    func setName(_ value: String)

    func setPassword(_ value: String)

    func signIn()

    func signOut()

    func showNetworkExamples()

    func showRecipes()

    func clearError()
}
