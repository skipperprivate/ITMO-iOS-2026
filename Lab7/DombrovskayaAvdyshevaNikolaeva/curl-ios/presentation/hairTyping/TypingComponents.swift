//
//  TypingComponents.swift
//  curl-ios
//
//  Created by Nadineenik on 19.10.2026.
//Чтобы код не дублировался, сделаем кастомный прогресс-бар и экран результата, которые принимают цвет в качестве параметра.

import SwiftUI

struct TypingProgressBar: View {
    let current: Int
    let total: Int
    let color: Color
    
    var body: some View {
        let progress = CGFloat(current + 1) / CGFloat(total)
        
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.lightBeige)
                .frame(height: 20)
            
            Capsule()
                .fill(color)
                .frame(width: UIScreen.main.bounds.width * progress - 80, height: 20)
                .overlay(
                    Text("\(current + 1)/\(total)")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(Color.lightBeige)
                )
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}

struct TypingResultView: View {
    let resultTitle: String
    let themeColor: Color
    let onSave: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Ваш результат:")
                .font(.title)
                .foregroundStyle(Color.lightBeige)
            
            Text(resultTitle.capitalized)
                .font(.largeTitle.bold())
                .foregroundStyle(themeColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.lightBeige)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(spacing: 16) {
                Button(action: onSave) {
                    Text("Сохранить результат")
                        .font(.headline)
                        .foregroundStyle(Color.lightBeige)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: onSkip) {
                    Text("Не сохранять")
                        .font(.headline)
                        .foregroundStyle(Color.lightBeige)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.lightBeige, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
    }
}
