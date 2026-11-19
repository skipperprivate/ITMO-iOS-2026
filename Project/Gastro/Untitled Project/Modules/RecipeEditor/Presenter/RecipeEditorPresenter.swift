import Combine
import Foundation

@MainActor
final class RecipeEditorPresenter: RecipeEditorViewOutput {
    @Published private(set) var state: RecipeEditorViewState
    private let id: UUID?
    private let interactor: any RecipeEditorInteractor
    private let router: any RecipeEditorRouter
    private var hasLoaded = false

    init(id: UUID?, interactor: any RecipeEditorInteractor, router: any RecipeEditorRouter) {
        self.id = id
        self.interactor = interactor
        self.router = router
        state = RecipeEditorViewState(isEditing: id != nil)
    }

    func load() {
        guard !hasLoaded else { return }
        hasLoaded = true
        guard let id else { return }
        do {
            guard let recipe = try interactor.recipe(id: id) else {
                state.error = RecipeStoreError.notFound.localizedDescription
                return
            }
            state.title = recipe.title
            state.ingredients = recipe.ingredients
            state.steps = recipe.steps
            state.cookingTime = recipe.cookingTimeMinutes.map(String.init) ?? ""
        } catch {
            state.error = error.localizedDescription
        }
    }

    func setTitle(_ value: String) {
        state.title = value
    }

    func setCookingTime(_ value: String) {
        state.cookingTime = value
    }

    func setIngredient(at index: Int, to value: String) {
        state.ingredients[index] = value
    }

    func addIngredient() {
        state.ingredients.append("")
    }

    func removeIngredient(at index: Int) {
        state.ingredients.remove(at: index)
        if state.ingredients.isEmpty { state.ingredients = [""] }
    }

    func setStep(at index: Int, to value: String) {
        state.steps[index] = value
    }

    func addStep() {
        state.steps.append("")
    }

    func removeStep(at index: Int) {
        state.steps.remove(at: index)
        if state.steps.isEmpty { state.steps = [""] }
    }

    func save() {
        guard !state.isPublishing else { return }
        do {
            let draft = try makeDraft()
            if let id {
                try interactor.update(id: id, with: draft)
            } else {
                try interactor.create(draft)
            }
            router.goBack()
        } catch {
            state.error = error.localizedDescription
        }
    }

    func publish() async {
        guard !state.isPublishing else { return }
        state.isPublishing = true
        state.error = nil
        state.toast = nil
        defer { state.isPublishing = false }

        do {
            let draft = try makeDraft()
            _ = try await interactor.publish(draft)
            try Task.checkCancellation()
        } catch is CancellationError {
            // Leaving the screen cancels the request without showing an error.
        } catch {
            guard !Task.isCancelled else { return }
            state.toast = ToastMessage(text: error.localizedDescription)
        }
    }

    func dismissToast(id: UUID) {
        guard state.toast?.id == id else { return }
        state.toast = nil
    }

    private func makeDraft() throws -> RecipeDraft {
        let time = state.cookingTime.trimmingCharacters(in: .whitespacesAndNewlines)
        let minutes: Int?
        if time.isEmpty {
            minutes = nil
        } else if let parsed = Int(time), parsed > 0 {
            minutes = parsed
        } else {
            throw RecipeStoreError.invalidCookingTime
        }
        return try RecipeDraft(
            title: state.title,
            ingredients: state.ingredients,
            steps: state.steps,
            cookingTimeMinutes: minutes
        ).validated()
    }

    func cancel() {
        router.goBack()
    }

    func clearError() {
        state.error = nil
    }
}
