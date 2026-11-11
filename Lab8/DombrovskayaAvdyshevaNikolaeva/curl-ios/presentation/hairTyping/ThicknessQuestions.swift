import SwiftUI

enum ThicknessQuestions {
    static let all: [TypingQuestion] = [
        TypingQuestion(
            topic: "Возьмите карандаш/ручку, намотайте волос виток к витку. Ширину всех витков поделите на число витков. Какая ширина получилась?",
            answers: [
                TypingAnswer(text: "Более 0,07 мм", result: "bold"),
                TypingAnswer(text: "0,05–0,07 мм", result: "medium"),
                TypingAnswer(text: "Менее 0,05 мм", result: "thin"),
                TypingAnswer(text: "Я не умею / не хочу считать", result: "")
            ]
        ),
        TypingQuestion(
            topic: "Поднесите волос к окну и рассмотрите на свет. Как он выглядит?",
            answers: [
                TypingAnswer(text: "Волосок широкий, крупный, его отчётливо видно", result: "bold"),
                TypingAnswer(text: "Волос настолько тонкий, что его еле заметно на свету", result: "thin"),
                TypingAnswer(text: "Что-то среднее", result: "medium")
            ]
        ),
        TypingQuestion(
            topic: "Как быстро ваши волосы пачкаются у корней?",
            answers: [
                TypingAnswer(text: "Очень быстро, уже к вечеру жирные", result: "thin"),
                TypingAnswer(text: "Умеренно, на второй-третий день", result: "medium"),
                TypingAnswer(text: "Долго остаются чистыми", result: "bold")
            ]
        ),
        TypingQuestion(
            topic: "Как ваши волосы ведут себя без укладочных средств?",
            answers: [
                TypingAnswer(text: "Ложатся гладко, кажутся мягкими и податливыми", result: "thin"),
                TypingAnswer(text: "Немного пушатся, но держат форму", result: "medium"),
                TypingAnswer(text: "Объёмные, жёсткие, плохо поддаются укладке", result: "bold")
            ]
        ),
        TypingQuestion(
            topic: "Какой объём у ваших волос у корней?",
            answers: [
                TypingAnswer(text: "Практически отсутствует, прилегают к голове", result: "thin"),
                TypingAnswer(text: "Средний, есть естественный объём", result: "medium"),
                TypingAnswer(text: "Очень большой, волосы стоят «шапкой»", result: "bold")
            ]
        )
    ]
}
