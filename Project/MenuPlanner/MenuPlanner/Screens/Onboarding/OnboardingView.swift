//
//  OnboardingView.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import SwiftUI

struct OnboardingView: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                brand
                welcomeMessage
                shoppingExample
                instructions
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            startButton
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(AppColors.background)
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    private var brand: some View {
        HStack(spacing: 8) {
            Image("logo")

            Text("ПО ПОРЦИЯМ")
                .font(AppFonts.smallStrong)
                .foregroundStyle(AppColors.accent)
        }
        .frame(minHeight: 24)
    }

    private var welcomeMessage: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Меню на неделю.\nПокупки без суеты.")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.primaryText)

            Text("Планируй, что приготовить.\nОстальное соберём в список.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var shoppingExample: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("МЕНЬШЕ ПЛАНОВ В ГОЛОВЕ")
                .font(AppFonts.micro)
                .foregroundStyle(AppColors.warm)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                horizontalExample
                verticalExample
            }

            Text("Одинаковые продукты складываем")
                .font(AppFonts.small)
                .foregroundStyle(AppColors.warm)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.warmSoft, in: RoundedRectangle(cornerRadius: 28))
    }

    private var horizontalExample: some View {
        HStack(spacing: 0) {
            mealPreview
                .frame(width: 136)

            Spacer(minLength: 10)
            conversionArrow
            Spacer(minLength: 10)

            shoppingPreview
                .frame(width: 136)
        }
    }

    private var verticalExample: some View {
        VStack(spacing: 12) {
            mealPreview
            conversionArrow
                .rotationEffect(.degrees(90))
            shoppingPreview
        }
    }

    private var conversionArrow: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(AppColors.warm)
            .frame(width: 20, height: 20)
    }

    private var mealPreview: some View {
        VStack(spacing: 8) {
            Text("СРЕДА · УЖИН")
                .foregroundStyle(AppColors.secondaryText)

            Image("Salmon")

            Text("Лосось с рисом")
                .foregroundStyle(AppColors.primaryText)
        }
        .font(AppFonts.micro)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 136)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var shoppingPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ПОКУПКИ")
                .font(AppFonts.micro)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            shoppingRow("Лосось · 600 г")
            shoppingRow("Рис · 320 г")
            shoppingRow("Огурцы · 3 шт.")
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func shoppingRow(_ text: String) -> some View {
        HStack(spacing: 6) {
            Image("product_checkbox")

            Text(text)
                .font(AppFonts.micro)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minHeight: 24)
    }

    private var instructions: some View {
        VStack(spacing: 12) {
            instruction(
                number: "01",
                title: "Выбери блюда",
                description: "Распредели их по дням недели."
            )
            instruction(
                number: "02",
                title: "Укажи порции",
                description: "Посчитаем продукты на всех."
            )
            instruction(
                number: "03",
                title: "Забери список покупок",
                description: "Объединим всё и учтём запасы."
            )
        }
    }

    private func instruction(number: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(AppFonts.smallStrong)
                .foregroundStyle(AppColors.accent)
                .frame(width: 32, height: 32)
                .background(AppColors.accentSoft, in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.strong)
                    .foregroundStyle(AppColors.primaryText)

                Text(description)
                    .font(AppFonts.small)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 56)
    }

    private var startButton: some View {
        Button {
            viewModel.completeOnboarding()
        } label: {
            Text("Составить меню")
                .font(AppFonts.strong)
                .foregroundStyle(AppColors.onAccent)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(AppColors.accent, in: RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("onboarding.start")
    }
}

#Preview("Обучение") {
    let defaults = UserDefaults(
        suiteName: "MenuPlanner.Preview.Onboarding"
    )!

    let settings = UserSettings(defaults: defaults)
    settings.hasCompletedOnboarding = false

    return OnboardingView(viewModel: OnboardingViewModel(userSettings: settings))
}
