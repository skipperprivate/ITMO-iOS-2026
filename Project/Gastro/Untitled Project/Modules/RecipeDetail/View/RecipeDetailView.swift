import SwiftUI

@MainActor
struct RecipeDetailView<Presenter: RecipeDetailViewOutput>: View {
    @StateObject private var presenter: Presenter
    @State private var showsDeleteConfirmation = false

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        Group {
            if presenter.state.isLoaded {
                List {
                    if let minutes = presenter.state.cookingTimeMinutes {
                        Section {
                            Label("Cooking time: \(minutes) min", systemImage: "clock")
                        }
                    }
                    Section("Ingredients") {
                        ForEach(Array(presenter.state.ingredients.enumerated()), id: \.offset) { _, ingredient in
                            Text(ingredient)
                        }
                    }
                    Section("Instructions") {
                        ForEach(Array(presenter.state.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .foregroundStyle(Color("AccentColor"))
                                    .fontWeight(.bold)
                                Text(step)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    Section {
                        Button("Delete recipe", role: .destructive) {
                            showsDeleteConfirmation = true
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.965, green: 0.973, blue: 0.965))
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.965, green: 0.973, blue: 0.965))
            }
        }
        .navigationTitle(presenter.state.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Edit", action: presenter.edit)
                .accessibilityIdentifier("recipeDetail.edit")
                .disabled(!presenter.state.isLoaded)
        }
        .onAppear(perform: presenter.load)
        .confirmationDialog("Delete this recipe?", isPresented: $showsDeleteConfirmation) {
            Button("Delete", role: .destructive, action: presenter.delete)
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { presenter.state.error != nil },
                set: { if !$0 { presenter.clearError() } }
            )
        ) {
            Button("OK", role: .cancel, action: presenter.clearError)
        } message: {
            Text(presenter.state.error ?? "")
        }
    }
}
