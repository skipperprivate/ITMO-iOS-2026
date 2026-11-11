import SwiftUI

@MainActor
final class PorosityTypingViewModel: ObservableObject {

    private let repository = HairTypesRepositoryImpl()
    private let profileService = UserDefaultsService.shared

    @Published var questions: [Question] = PorosityQuestions.all

    @Published var currentQuestionId: Int = 0
    @Published var result: PorosityTypes?
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isSavedSuccess = false

    var currentQuestion: Question {
        questions[currentQuestionId]
    }

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
        let resultString = questions.compactMap { question in
            guard let index = question.selectedIndex else { return nil }
            return question.answers[index].result
        }.joined()

        let porous = resultString.filter { $0 == Character(PorosityTypes.porous.rawValue) }.count
        let semiPorous = resultString.filter { $0 == Character(PorosityTypes.semiPorous.rawValue) }.count
        let nonPorous = resultString.filter { $0 == Character(PorosityTypes.nonPorous.rawValue) }.count

        let maxVal = max(porous, semiPorous, nonPorous)

        if maxVal == porous {
            result = .porous
        } else if maxVal == semiPorous {
            result = .semiPorous
        } else {
            result = .nonPorous
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

        let request = HairTypeRequest(
            userId: userId,
            porosity: result.dbCode,
            isColored: nil,
            thickness: nil
        )

        do {
            try await repository.updateHairType(userId: userId, request: request)

            profileService.hairPorosity = result.resultName.capitalized

            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
