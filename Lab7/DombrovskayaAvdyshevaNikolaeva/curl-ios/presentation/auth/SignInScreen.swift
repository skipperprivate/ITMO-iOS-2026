import SwiftUI

struct SignInScreen: View {
    let onSignIn: () -> Void
    let onGoToSignUp: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("CurlyWave")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(spacing: 24) {
                    Text("Вход")
                        .font(.largeTitle)
                        .foregroundStyle(Color.darkGreen)

                    Spacer().frame(height: 10)

                    VStack(spacing: 16) {
                        OutlinedField(title: "Email", text: $email)

                        PasswordField(
                            title: "Пароль",
                            text: $password,
                            isVisible: $passwordVisible
                        )

                        Spacer().frame(height: 4)

                        Button {
                            onSignIn()
                        } label: {
                            Text("Войти")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .background(canSignIn ? Color.lightGreen : Color.lightGreen.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        //.disabled(!canSignIn)

                        OrDivider()

                        Button {
                        } label: {
                            HStack(spacing: 8) {
                                Image("google_icon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Войти через Google")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                        }
                        .background(Color.white)
                        .foregroundStyle(Color.darkGreen)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(
                                        colors: [.lightGreen, .darkGreen],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack(spacing: 4) {
                        Text("Еще нет аккаунта?")
                            .foregroundStyle(Color.darkGreen.opacity(0.7))
                        Button("Зарегистрироваться") {
                            onGoToSignUp()
                        }
                        .foregroundStyle(Color.darkGreen)
                        .fontWeight(.bold)
                    }
                    .font(.subheadline)
                }
                .padding(24)
            }
        }
        .background(Color.lightBeige)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }

    private var canSignIn: Bool {
        !email.isEmpty && !password.isEmpty
    }
}
