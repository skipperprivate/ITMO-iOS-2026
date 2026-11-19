import Foundation

struct RecipeEditorViewState: Equatable {
    var title = ""
    var ingredients = [""]
    var steps = [""]
    var cookingTime = ""
    var isEditing = false
    var error: String?
    var toast: ToastMessage?
    var isPublishing = false
    let publishButtonTitle = "Опубликовать"
}
