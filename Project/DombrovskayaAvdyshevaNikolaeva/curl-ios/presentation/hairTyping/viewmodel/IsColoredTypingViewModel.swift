import SwiftUI

@MainActor
final class IsColoredTypingViewModel: ObservableObject {
    private let repository = HairTypesRepositoryImpl()
    private let profileService = UserDefaultsService.shared

    @Published var questions: [Question] = IsColoredQuestions.all

    @Published var currentQuestionId: Int = 0
    @Published var result: String?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSavedSuccess = false

    var currentQuestion: Question { questions[currentQuestionId] }

    func selectAnswer(at index: Int) {
        questions[currentQuestionId].selectedIndex = index
    }

    func calculateResult() {
        guard let index = questions[currentQuestionId].selectedIndex else { return }
        let answerResult = questions[currentQuestionId].answers[index].result

        result = (answerResult == ColoredTypes.colored.rawValue) ? ColoredTypes.colored.resultName : ColoredTypes.notColored.resultName
    }

    func saveResult() async {
        guard let result = result else { return }

        guard let userId = AuthManager.shared.getUserId() else {
            isSavedSuccess = false
            alertMessage = "Ошибка: вы не авторизованы!"
            showAlert = true
            return
        }

        let isColoredBool = (result == ColoredTypes.colored.resultName)

        let request = HairTypeRequest(
            userId: userId,
            porosity: nil,
            isColored: isColoredBool,
            thickness: nil
        )

        do {
            try await repository.updateHairType(userId: userId, request: request)

            profileService.hairColoring = isColoredBool ? "Окрашенные" : "Неокрашенные"

            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
