import SwiftUI

@MainActor
struct RecipeListView<Presenter: RecipeListViewOutput>: View {
    @StateObject private var presenter: Presenter

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        ZStack {
            if presenter.state.recipes.isEmpty && !presenter.state.isLoadingRemote && presenter.state.remoteError == nil
            {
                ContentUnavailableView(
                    "No recipes yet",
                    systemImage: "book.closed",
                    description: Text("Add your first recipe to see it here")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.965, green: 0.973, blue: 0.965))
            } else {
                List {
                    if presenter.state.isLoadingRemote {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Loading recipes…")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let remoteError = presenter.state.remoteError {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(remoteError)
                                .foregroundStyle(.secondary)
                            Button("Retry") {
                                Task { await presenter.loadRemote(force: true) }
                            }
                        }
                    }

                    ForEach(presenter.state.recipes) { recipe in
                        Button {
                            presenter.showRecipe(id: recipe.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recipe.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                HStack(spacing: 12) {
                                    Image(systemName: recipe.id.sourceSymbol)
                                        .accessibilityLabel(recipe.id.sourceAccessibilityLabel)
                                    Label("Ingredients: \(recipe.ingredientCount)", systemImage: "list.bullet")
                                    if let minutes = recipe.cookingTimeMinutes {
                                        Label("\(minutes) min", systemImage: "clock")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        }
                        .swipeActions {
                            if case .local(let id) = recipe.id {
                                Button("Delete", role: .destructive) {
                                    presenter.delete(id: id)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    presenter.load()
                    await presenter.loadRemote(force: true)
                }
                .scrollContentBackground(.hidden)
                .background(Color(red: 0.965, green: 0.973, blue: 0.965))
            }
        }
        .navigationTitle("Recipes")
        .toolbar {
            Button("Add recipe", systemImage: "plus", action: presenter.showNewRecipe)
                .accessibilityIdentifier("recipes.add")
        }
        .onAppear(perform: presenter.load)
        .task { await presenter.loadRemote(force: false) }
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
