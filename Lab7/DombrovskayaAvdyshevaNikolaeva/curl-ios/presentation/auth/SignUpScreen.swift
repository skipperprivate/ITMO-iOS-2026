import SwiftUI

struct SignUpScreen: View {
    let onSignUp: () -> Void
    let onGoToSignIn: () -> Void

    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("CurlyWave")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()

                VStack(spacing: 24) {
                    Text("Регистрация")
                        .font(.largeTitle)
                        .foregroundStyle(Color.darkGreen)

                    Spacer().frame(height: 10)

                    VStack(spacing: 16) {
                        OutlinedField(title: "Email", text: $email)
                        OutlinedField(title: "Имя", text: $username)

                        PasswordField(
                            title: "Пароль",
                            text: $password,
                            isVisible: $passwordVisible
                        )

                        PasswordField(
                            title: "Подтвердите пароль",
                            text: $confirmPassword,
                            isVisible: $confirmPasswordVisible
                        )

                        Button {
                            onSignUp()
                        } label: {
                            Text("Зарегистрироваться")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                        .background(canSignUp ? Color.lightGreen : Color.lightGreen.opacity(0.5))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(!canSignUp)
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    HStack(spacing: 4) {
                        Text("Уже есть аккаунт?")
                            .foregroundStyle(Color.darkGreen.opacity(0.7))
                        Button("Войти") {
                            onGoToSignIn()
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

    private var canSignUp: Bool {
        !email.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }
}
