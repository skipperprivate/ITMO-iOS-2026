import SwiftUI

struct RecipeDeckView: View {
    let state: RecipeListViewState
    let onOpen: (RecipeRowID) -> Void
    let onFavorite: (RecipeRowState) -> Void
    let onSkip: (RecipeRowState) -> Void
    let onRestart: () -> Void
    let onRefresh: () async -> Void

    @State private var translation: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let recipe = state.recommendations.first {
                    header

                    cardStack

                    HStack(spacing: 32) {
                        actionButton("Пропустить", symbol: "xmark", color: .secondary) {
                            choose(recipe, action: .skip)
                        }
                        actionButton("В избранное", symbol: "heart.fill", color: .green) {
                            choose(recipe, action: .favorite)
                        }
                    }
                    Text("← Пропустить     •     В избранное →")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if !state.isLoadingRemote {
                    ContentUnavailableView {
                        Label("Вы всё посмотрели", systemImage: "checkmark.circle")
                    } description: {
                        Text("Любимые блюда ждут в избранном. Пропущенные можно посмотреть ещё раз.")
                    } actions: {
                        Button("Посмотреть заново", action: onRestart)
                            .buttonStyle(.bordered)
                            .disabled(state.skippedIDs.isEmpty)
                    }
                    .padding(.top, 60)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .refreshable {
            await onRefresh()
        }
    }

    private func actionButton(
        _ title: String,
        symbol: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title2.bold())
                .foregroundStyle(color)
                .frame(width: 64, height: 64)
                .background(Color(.secondarySystemGroupedBackground), in: Circle())
                .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        }
        .accessibilityLabel(title)
    }

    private func choose(_ recipe: RecipeRowState, action: SwipeAction) {
        // Ignore gestures arriving from a card that has already left the deck.
        guard state.recommendations.first?.id == recipe.id else { return }
        translation = 0
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if action == .favorite {
                onFavorite(recipe)
            } else {
                onSkip(recipe)
            }
        }
    }

    private var cardStack: some View {
        ZStack {
            ForEach(
                Array(state.recommendations.prefix(3).enumerated()).reversed(),
                id: \.element.id
            ) { index, item in
                RecipeSwipeCard(
                    recipe: item,
                    isFavorite: false,
                    onOpen: { onOpen(item.id) },
                    onFavorite: { choose(item, action: .favorite) }
                )
                .overlay(alignment: .topTrailing) {
                    if index == 0 && abs(translation) > 25 {
                        Label(
                            translation > 0 ? "В избранное" : "Пропустить",
                            systemImage: translation > 0 ? "heart.fill" : "arrow.left"
                        )
                        .font(.headline)
                        .padding(12)
                        .background(.regularMaterial, in: Capsule())
                        .foregroundStyle(translation > 0 ? Color.green : Color.secondary)
                        .padding(16)
                    }
                }
                .scaleEffect(1 - CGFloat(index) * 0.1, anchor: .bottom)
                .rotationEffect(.degrees(index == 0 ? Double(translation / 22) : Double(index) * -3))
                .offset(x: index == 0 ? translation : 0, y: -CGFloat(index) * 19)
                .opacity(index == 0 ? 1 : 0.80)
                .allowsHitTesting(index == 0)
                .accessibilityHidden(index != 0)
                .zIndex(Double(3 - index))
                .gesture(swipeGesture(for: item))
            }
        }
        .padding(.top, 40)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.8),
            value: state.recommendations.first?.id
        )
    }

    private func swipeGesture(for recipe: RecipeRowState) -> some Gesture {
        DragGesture(minimumDistance: Constants.dragMinimumDistance)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                translation = value.translation.width
            }
            .onEnded { value in
                if abs(value.translation.width) > Constants.swipeThreshold {
                    choose(recipe, action: value.translation.width > 0 ? .favorite : .skip)
                } else {
                    withAnimation(.spring()) {
                        translation = 0
                    }
                }
            }
    }

    private enum SwipeAction {
        case favorite
        case skip
    }

    private enum Constants {
        static let dragMinimumDistance: CGFloat = 25
        static let swipeThreshold: CGFloat = 90
    }

    private var header: some View {
        HStack {
            Text("Найдите своё новое любимое блюдо")
            Spacer()
            Text("\(state.recommendations.count)")
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.top, 20)
    }
}
