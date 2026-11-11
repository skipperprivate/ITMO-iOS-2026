import SwiftUI

@MainActor
final class ThicknessTypingViewModel: ObservableObject {

    private let repository = HairTypesRepositoryImpl()
    private let profileService = UserDefaultsService.shared

    @Published var questions: [TypingQuestion] = ThicknessQuestions.all
    @Published var currentQuestionId: Int = 0
    @Published var result: ThicknessTypes?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSavedSuccess = false

    var currentQuestion: TypingQuestion { questions[currentQuestionId] }

    var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionId + 1) / CGFloat(questions.count)
    }

    func selectAnswer(at index: Int) {
        questions[currentQuestionId].selectedIndex = index
    }

    func nextQuestion() {
        if currentQuestionId + 1 < questions.count {
            currentQuestionId += 1
        } else {
            calculateResult()
        }
    }

    func previousQuestion() {
        if currentQuestionId > 0 {
            currentQuestionId -= 1
        }
    }

    func calculateResult() {
        var thinCount = 0
        var mediumCount = 0
        var boldCount = 0

        for question in questions {
            guard let selectedIndex = question.selectedIndex else { continue }
            let answer = question.answers[selectedIndex]

            switch answer.result {
            case "thin", "THIN": thinCount += 1
            case "medium", "MEDIUM": mediumCount += 1
            case "bold", "THICK": boldCount += 1
            default: break
            }
        }

        let maxCount = max(thinCount, mediumCount, boldCount)

        if maxCount == boldCount {
            result = .bold
        } else if maxCount == thinCount {
            result = .thin
        } else {
            result = .medium
        }
    }

    func saveResult() async {
        guard let result = result else { return }

        guard let userId = AuthManager.shared.getUserId() else {
            isSavedSuccess = false
            alertMessage = "Ошибка: вы не авторизованы!"
            showAlert = true
            return
        }

        do {
            let current = try await repository.getHairType(userId: userId)

            let request = HairTypeRequest(
                userId: userId,
                porosity: current.porosity,
                isColored: current.isColored,
                thickness: result.dbCode
            )

            try await repository.updateHairType(userId: userId, request: request)

            profileService.hairThickness = result.resultName

            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
