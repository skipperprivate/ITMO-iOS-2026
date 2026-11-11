import Foundation

enum IsColoredQuestions {
    static let all: [Question] = [
        Question(
            topic: "У вас окрашенные волосы? :)",
            answers: [
                Answer(result: ColoredTypes.colored.rawValue, text: "Да"),
                Answer(result: ColoredTypes.notColored.rawValue, text: "Нет")
            ]
        )
    ]
}
