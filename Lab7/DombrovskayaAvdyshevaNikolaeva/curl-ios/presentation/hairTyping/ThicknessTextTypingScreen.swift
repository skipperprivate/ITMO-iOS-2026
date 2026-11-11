import SwiftUI

struct ThicknessTextTypingScreen: View {
    let onBackToHome: () -> Void

    @State private var currentQuestionIndex = 0
    @State private var result: String? = nil
    @State private var showSaveAlert = false
    @State private var saveError = false
    @State private var questions = ThicknessQuestions.all

    var body: some View {
        ZStack {
            Color(hex: "F8F4ED").ignoresSafeArea()

            if result == nil {
                questionView
            } else {
                resultView
            }
        }
        .navigationTitle("Типизация волос")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Результат", isPresented: $showSaveAlert) {
            Button("OK") { onBackToHome() }
        } message: {
            Text(saveError ? "Ошибка сохранения" : "Успешно сохранено")
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            
            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "EDE9E1"))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(Color(hex: "728C6A"))
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 4)
                
                Text("\(currentQuestionIndex + 1)/\(questions.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48"))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            if currentQuestionIndex < questions.count {
                let question = questions[currentQuestionIndex]

                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(currentQuestionIndex + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "728C6A"))
                            .frame(width: 28, height: 28)
                            .background(Color(hex: "F8F4ED"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hex: "728C6A").opacity(0.3), lineWidth: 1))
                        
                        Text(question.topic)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "4A5B48"))
                            .lineSpacing(4)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(24)

                    VStack(spacing: 10) {
                        ForEach(question.answers.indices, id: \.self) { index in
                            let answer = question.answers[index]
                            let isSelected = question.selectedIndex == index
                            
                            Button {
                                selectAnswer(index)
                            } label: {
                                HStack(spacing: 16) {
                                    Circle()
                                        .stroke(isSelected ? Color(hex: "728C6A") : Color(hex: "4A5B48").opacity(0.2), lineWidth: 1)
                                        .background(
                                            Circle().fill(isSelected ? Color(hex: "728C6A") : Color.clear)
                                        )
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle().fill(Color.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0)
                                        )

                                    Text(answer.text)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(hex: "4A5B48"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(isSelected ? Color(hex: "F8F4ED") : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? Color(hex: "728C6A").opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button {
                            if currentQuestionIndex > 0 { currentQuestionIndex -= 1 }
                        } label: {
                            Text("Назад")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "4A5B48"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(30)
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(hex: "4A5B48").opacity(0.2), lineWidth: 1))
                        }
                        .disabled(currentQuestionIndex == 0)
                        .opacity(currentQuestionIndex == 0 ? 0.5 : 1)

                        Button {
                            if currentQuestionIndex + 1 < questions.count {
                                currentQuestionIndex += 1
                            } else {
                                calculateResult()
                            }
                        } label: {
                            Text(currentQuestionIndex + 1 == questions.count ? "Результат" : "Далее")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "728C6A"))
                                .cornerRadius(30)
                        }
                        .disabled(question.selectedIndex == nil)
                        .opacity(question.selectedIndex == nil ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Text("Ваш результат")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "4A5B48"))

            Text(result ?? "")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "728C6A"))

            Spacer()

            Button("Сохранить результат") {
                saveError = false
                showSaveAlert = true
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "728C6A"))
            .cornerRadius(30)

            Button("Не сохранять") {
                onBackToHome()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color(hex: "4A5B48"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(30)
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color(hex: "4A5B48").opacity(0.2), lineWidth: 1))
        }
        .padding(24)
    }

    private var progress: CGFloat {
        guard !questions.isEmpty else { return 0 }
        return CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count)
    }

    private func selectAnswer(_ index: Int) {
        questions[currentQuestionIndex].selectedIndex = index
    }

    private func calculateResult() {
        var thinCount = 0
        var mediumCount = 0
        var boldCount = 0

        for question in questions {
            guard let selectedIndex = question.selectedIndex else { continue }
            let answer = question.answers[selectedIndex]
            
            switch answer.result {
            case "thin":   thinCount += 1
            case "medium": mediumCount += 1
            case "bold":   boldCount += 1
            default: break
            }
        }

        let maxCount = max(thinCount, mediumCount, boldCount)
        
        if maxCount == boldCount {
            result = "Толстые"
        } else if maxCount == thinCount {
            result = "Тонкие"
        } else {
            result = "Средние"
        }
    }
}
