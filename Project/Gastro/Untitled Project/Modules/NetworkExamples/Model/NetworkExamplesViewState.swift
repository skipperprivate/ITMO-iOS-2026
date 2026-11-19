struct NetworkExamplesViewState {
    var activeExample: NetworkExample?
    var toast: ToastMessage?
    var result: String?
    let examples = NetworkExample.allCases

    func title(for example: NetworkExample) -> String {
        switch example {
            case .publish: "Опубликовать рецепт"
            case .badRequest: "400 — неверный запрос"
            case .unauthorized: "401 — нужна авторизация"
            case .rateLimited: "429 — слишком много запросов"
            case .serverError: "500 — ошибка сервера"
        }
    }

    func endpoint(for example: NetworkExample) -> String {
        example == .publish ? "POST /recipes/add" : "POST /http/\(example.rawValue)"
    }
}
