import SwiftUI

struct SignUpScreen: View {
    let onSignUp: () -> Void
    let onGoToSignIn: () -> Void

    @StateObject private var viewModel: SignUpViewModel
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false

    init(
        viewModel: SignUpViewModel,
        onSignUp: @escaping () -> Void,
        onGoToSignIn: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignUp = onSignUp
        self.onGoToSignIn = onGoToSignIn
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("CurlySignImg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

                VStack(spacing: 24) {
                    Text("Регистрация")
                        .font(.displaySerif)
                        .foregroundStyle(Color.curlyGreen)

                    VStack(spacing: 16) {
                        OutlinedField(
                            title: "Email",
                            text: Binding(
                                get: { viewModel.email },
                                set: { viewModel.updateEmail($0) }
                            )
                        )

                        OutlinedField(
                            title: "Имя",
                            text: Binding(
                                get: { viewModel.username },
                                set: { viewModel.updateUsername($0) }
                            )
                        )

                        PasswordField(
                            title: "Пароль",
                            text: Binding(
                                get: { viewModel.password },
                                set: { viewModel.updatePassword($0) }
                            ),
                            isVisible: $passwordVisible
                        )

                        PasswordField(
                            title: "Подтвердите пароль",
                            text: Binding(
                                get: { viewModel.confirmPassword },
                                set: { viewModel.updateConfirmPassword($0) }
                            ),
                            isVisible: $confirmPasswordVisible
                        )

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.textSerif)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            viewModel.signUp(onSuccess: onSignUp)
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                            } else {
                                Text("Зарегистрироваться")
                                    .font(.bodySerif)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                            }
                        }
                        .background(canSignUp ? Color.curlyDarkGreen : Color.curlyGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(!canSignUp || viewModel.isLoading)
                    }
                    .padding(24)

                    HStack(spacing: 4) {
                        Text("Уже есть аккаунт?")
                            .font(.textSerif)
                            .foregroundStyle(Color.curlyDarkGreen.opacity(0.7))
                        Button("Войти") {
                            onGoToSignIn()
                        }
                        .foregroundStyle(Color.curlyDarkGreen)
                        .fontWeight(.bold)
                        .font(.textSerif)
                    }
                    .font(.subheadline)
                }
                .padding(24)
            }
        }
        .background(Color.curlySurface)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }

    private var canSignUp: Bool {
        !viewModel.email.isEmpty &&
        !viewModel.username.isEmpty &&
        !viewModel.password.isEmpty &&
        !viewModel.confirmPassword.isEmpty
    }
}
