import Foundation

enum PorosityQuestions {
    static let all: [Question] = [
        Question(topic: "Проведите пальцами по волоску от кончика к коже головы.", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Чувствую сопротивление"),
            Answer(result: "\(PorosityTypes.semiPorous.rawValue)\(PorosityTypes.nonPorous.rawValue)", text: "Не чувствую сопротивление")
        ]),
        Question(topic: "Какие Ваши волосы наощупь и на вид?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Скользкие и гладкие, на вид –– блестящие, буквально отражающие свет"),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Гладкие и блестящие"),
            Answer(result: PorosityTypes.porous.rawValue, text: "На ощупь шершавые, визуально матовые, не блестят")
        ]),
        Question(topic: "Хорошо ли Ваши волосы держат завиток?", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Да"),
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Нет")
        ]),
        Question(topic: "Пушатся ли Ваши волосы?", answers: [
            Answer(result: "\(PorosityTypes.porous.rawValue)\(PorosityTypes.semiPorous.rawValue)", text: "Да"),
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Нет")
        ]),
        Question(topic: "Насколько хорошо Ваши волосы держат кудри и прикорневой объем?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Плохо, без дополнительных фиксирующих средств совсем не держат"),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Укладка может держаться несколько дней"),
            Answer(result: PorosityTypes.porous.rawValue, text: "Отлично держат форму, хороший прикорневой объем")
        ]),
        Question(topic: "Как ведут себя Ваши волосы после мытья?", answers: [
            Answer(result: PorosityTypes.nonPorous.rawValue, text: "Во влажном состоянии могут виться, но после высыхания распрямляются"),
            Answer(result: PorosityTypes.semiPorous.rawValue, text: "Пушаться и лохматяться"),
            Answer(result: PorosityTypes.porous.rawValue, text: "Если лечь спать с влажными волосами, на утро будет колтун и валенок")
        ])
    ]
}
