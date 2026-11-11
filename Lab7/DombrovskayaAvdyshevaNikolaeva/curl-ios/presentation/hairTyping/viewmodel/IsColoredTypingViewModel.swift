//
//  IsColoredTypingViewModel.swift
//  curl-ios
//
//  Created by Nabineenik on 19.10.2026.
//

import SwiftUI

@MainActor
final class IsColoredTypingViewModel: ObservableObject {
    @Published var questions: [Question] = [
        Question(
            topic: "У вас окрашенные волосы? :)",
            answers: [
                Answer(result: ColoredTypes.colored.rawValue, text: "Да"),
                Answer(result: ColoredTypes.notColored.rawValue, text: "Нет")
            ]
        )
    ]
    
    @Published var currentQuestionId: Int = 0
    @Published var result: String? = nil
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
    
    func saveResult(userId: String) async {
        // TODO: Заменить на реальный вызов API
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            isSavedSuccess = true
            alertMessage = "Результат успешно сохранен"
        } catch {
            isSavedSuccess = false
            alertMessage = "Ошибка, не удалось сохранить"
        }
        showAlert = true
    }
}
