import SwiftUI

struct PorosityTypingScreen: View {
    @StateObject private var viewModel = PorosityTypingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.curlySurface).ignoresSafeArea()

            if let result = viewModel.result {
                TypingResultView(
                    resultTitle: result.resultName,
                    onAction: handleResultAction
                )
            } else {
                questionView
            }
        }
        .navigationTitle("Тест на пористость")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: { dismiss() },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(.curlyDarkGreen))
                    }
                )
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.isSavedSuccess { dismiss() }
            }
        }
    }

    private func handleResultAction(_ action: TypingResultView.Action) {
        switch action {
        case .save:
            Task { await viewModel.saveResult() }
        case .skip:
            dismiss()
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.curlySurfaceMuted))
                            .frame(height: 4)

                        Capsule()
                            .fill(Color(.curlyGreen))
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 4)

                Text("\(viewModel.currentQuestionId + 1)/\(viewModel.questions.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(.curlyDarkGreen))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            if viewModel.currentQuestionId < viewModel.questions.count {
                let question = viewModel.currentQuestion

                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(viewModel.currentQuestionId + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(.curlyGreen))
                            .frame(width: 28, height: 28)
                            .background(Color(.curlySurface))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.curlyGreen).opacity(0.3), lineWidth: 1))

                        Text(question.topic)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(.curlyDarkGreen))
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
                                viewModel.selectAnswer(at: index)
                            } label: {
                                HStack(spacing: 16) {
                                    Circle()
                                        .stroke(isSelected ? Color(.curlyGreen) : Color(.curlyDarkGreen).opacity(0.2), lineWidth: 1)
                                        .background(Circle().fill(isSelected ? Color(.curlyGreen) : Color.clear))
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().fill(Color.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0))

                                    Text(answer.text)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(.curlyDarkGreen))
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(20)
                                .background(isSelected ? Color(.curlySurface) : Color.white)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? Color(.curlyGreen).opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button("Назад") {
                            viewModel.previousQuestion()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(viewModel.currentQuestionId == 0)
                        .opacity(viewModel.currentQuestionId == 0 ? 0.5 : 1)

                        Button(viewModel.currentQuestionId + 1 == viewModel.questions.count ? "Результат" : "Далее") {
                            viewModel.nextQuestion()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(question.selectedIndex == nil)
                        .opacity(question.selectedIndex == nil ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    private var progress: CGFloat {
        guard !viewModel.questions.isEmpty else { return 0 }
        return CGFloat(viewModel.currentQuestionId + 1) / CGFloat(viewModel.questions.count)
    }
}
