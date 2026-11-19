import SwiftUI

@MainActor
struct ProfileView<Presenter: ProfileViewOutput>: View {
    @StateObject private var presenter: Presenter

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        Form {
            if let username = presenter.state.username {
                Section {
                    Text("Hello, \(username)!")
                        .font(.title2.bold())
                        .padding(.vertical, 10)
                }
                Section {
                    Button("Recipes", systemImage: "book.closed", action: presenter.showRecipes)
                    Button("Sign out", role: .destructive, action: presenter.signOut)
                }
            } else {
                Section {
                    TextField(
                        "Name",
                        text: Binding(
                            get: { presenter.state.inputName },
                            set: presenter.setName
                        )
                    )

                    SecureField(
                        "Password",
                        text: Binding(
                            get: { presenter.state.inputPassword },
                            set: presenter.setPassword
                        )
                    )
                } header: {
                    Text("Demo sign in")
                } footer: {
                    Text("Any non-empty password works. This account is not connected to a server.")
                }
                Section {
                    Button("Sign in", action: presenter.signIn)
                        .frame(maxWidth: .infinity)
                }
            }
            Section {
                Button("Проверка сети", systemImage: "network", action: presenter.showNetworkExamples)
                    .accessibilityIdentifier("profile.networkExamples")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(red: 0.965, green: 0.973, blue: 0.965))
        .navigationTitle("Profile")
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
}
