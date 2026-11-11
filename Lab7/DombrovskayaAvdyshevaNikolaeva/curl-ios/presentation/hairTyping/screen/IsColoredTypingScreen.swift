//
//  IsColoredTypingScreen.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//

import SwiftUI

struct IsColoredTypingScreen: View {
    @StateObject private var viewModel = IsColoredTypingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    private let userId = "current-user-id"
    
    var body: some View {
        ZStack {
            Color(hex: "F8F4ED").ignoresSafeArea()
            
            if let result = viewModel.result {
                resultView(result: result)
            } else {
                questionView
            }
        }
        .navigationTitle("Тест на окрашенность")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "4A5B48"))
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.isSavedSuccess { dismiss() }
            }
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(hex: "EDE9E1")).frame(height: 4)
                        Capsule().fill(Color(hex: "728C6A")).frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .frame(height: 4)
                
                Text("\(viewModel.currentQuestionId + 1)/\(viewModel.questions.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48"))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            if viewModel.currentQuestionId < viewModel.questions.count {
                let question = viewModel.currentQuestion

                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(viewModel.currentQuestionId + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "728C6A"))
                            .frame(width: 28, height: 28)
                            .background(Color(hex: "F8F4ED"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(hex: "728C6A").opacity(0.3), lineWidth: 1))
                        
                        Text(question.topic)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "4A5B48"))
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
                                        .stroke(isSelected ? Color(hex: "728C6A") : Color(hex: "4A5B48").opacity(0.2), lineWidth: 1)
                                        .background(Circle().fill(isSelected ? Color(hex: "728C6A") : Color.clear))
                                        .frame(width: 20, height: 20)
                                        .overlay(Circle().fill(Color.white).frame(width: 8, height: 8).opacity(isSelected ? 1 : 0))

                                    Text(answer.text)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(Color(hex: "4A5B48"))
                                    
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

                    Button {
                        viewModel.calculateResult()
                    } label: {
                        Text("Результат")
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
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func resultView(result: String) -> some View {
        VStack(spacing: 24) {
            Text("Ваш результат")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "4A5B48"))

            Text(result.capitalized)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "728C6A"))

            Spacer()

            Button("Сохранить результат") {
                Task { await viewModel.saveResult(userId: userId) }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(hex: "728C6A"))
            .cornerRadius(30)

            Button("Не сохранять") {
                dismiss()
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
        guard !viewModel.questions.isEmpty else { return 0 }
        return CGFloat(viewModel.currentQuestionId + 1) / CGFloat(viewModel.questions.count)
    }
}
