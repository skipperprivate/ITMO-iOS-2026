import Combine
import Foundation

@MainActor
protocol RecipeEditorViewOutput: ObservableObject {
    var state: RecipeEditorViewState { get }

    func load()

    func setTitle(_ value: String)

    func setCookingTime(_ value: String)

    func setIngredient(at index: Int, to value: String)

    func addIngredient()

    func removeIngredient(at index: Int)

    func setStep(at index: Int, to value: String)

    func addStep()

    func removeStep(at index: Int)

    func publish() async

    func dismissToast(id: UUID)

    func save()

    func cancel()

    func clearError()
}
