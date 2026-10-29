import SwiftUI

@MainActor
struct RecipeEditorView<Presenter: RecipeEditorViewOutput>: View {
    @StateObject private var presenter: Presenter
    @State private var publicationRequestID = 0

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        Form {
            Section {
                TextField(
                    "For example, an omelet",
                    text: Binding(
                        get: { presenter.state.title },
                        set: presenter.setTitle
                    )
                )
                .accessibilityIdentifier("recipeEditor.title")
            } header: {
                sectionHeader("Name", symbol: "textformat")
            }

            Section {
                ForEach(Array(presenter.state.ingredients.enumerated()), id: \.offset) { index, _ in
                    HStack {
                        TextField(
                            "Ingredient and amount",
                            text: Binding(
                                get: { presenter.state.ingredients[index] },
                                set: { presenter.setIngredient(at: index, to: $0) }
                            )
                        )
                        .accessibilityIdentifier("recipeEditor.ingredient.\(index)")
                        Button(role: .destructive) {
                            presenter.removeIngredient(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Button("Add ingredient", systemImage: "plus", action: presenter.addIngredient)
            } header: {
                sectionHeader("Ingredients", symbol: "carrot")
            } footer: {
                Text("For example: Eggs — 2")
            }

            Section {
                ForEach(Array(presenter.state.steps.enumerated()), id: \.offset) { index, _ in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                        TextField(
                            "Describe this step",
                            text: Binding(
                                get: { presenter.state.steps[index] },
                                set: { presenter.setStep(at: index, to: $0) }
                            ),
                            axis: .vertical
                        )
                        .lineLimit(2...5)
                        .accessibilityIdentifier("recipeEditor.step.\(index)")
                        Button(role: .destructive) {
                            presenter.removeStep(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Button("Add step", systemImage: "plus", action: presenter.addStep)
            } header: {
                sectionHeader("Instructions", symbol: "list.number")
            }

            Section {
                TextField(
                    "Minutes (optional)",
                    text: Binding(
                        get: { presenter.state.cookingTime },
                        set: presenter.setCookingTime
                    )
                )
                .keyboardType(.numberPad)
            } header: {
                sectionHeader("Cooking time", symbol: "clock")
            }
        }
        .disabled(presenter.state.isPublishing)
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.965, green: 0.973, blue: 0.965))
        .navigationTitle(presenter.state.isEditing ? "Edit recipe" : "New recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", action: presenter.cancel)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button(action: presenter.save) {
                    Label(
                        presenter.state.isEditing ? "Save changes" : "Save recipe",
                        systemImage: "checkmark"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("recipeEditor.save")
                .buttonBorderShape(.roundedRectangle(radius: 16))

                Button {
                    publicationRequestID += 1
                } label: {
                    HStack {
                        if presenter.state.isPublishing {
                            ProgressView().accessibilityIdentifier("recipeEditor.publishing")
                        }
                        Text(presenter.state.publishButtonTitle)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("recipeEditor.publish")

            }
            .disabled(presenter.state.isPublishing)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.regularMaterial)
        }
        .task(id: publicationRequestID) {
            guard publicationRequestID > 0 else { return }
            await presenter.publish()
        }
        .errorToast(presenter.state.toast, onDismiss: presenter.dismissToast)
        .onAppear(perform: presenter.load)
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

    private func sectionHeader(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("AccentColor"))
    }
}
