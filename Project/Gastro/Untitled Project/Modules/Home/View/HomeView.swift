import SwiftUI

@MainActor
struct HomeView<Presenter: HomeViewOutput>: View {
    @StateObject private var presenter: Presenter

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What shall we cook today?")
                .font(.title2.bold())
                .padding(.bottom, 12)

            Button(action: presenter.showRecipes) {
                menuCard(
                    title: "Recipes",
                    subtitle: "Saved: \(presenter.state.recipeCount)",
                    symbol: "book.closed"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.recipes")

            Button(action: presenter.showProfile) {
                menuCard(
                    title: "Profile",
                    subtitle: "Sign in or view your name",
                    symbol: "person.crop.circle"
                )
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home.profile")

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.965, green: 0.973, blue: 0.965))
        .navigationTitle("Gastro")
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

    private func menuCard(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color("AccentColor"))
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}
