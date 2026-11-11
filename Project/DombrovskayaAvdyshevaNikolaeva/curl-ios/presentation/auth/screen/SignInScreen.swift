import SwiftUI

struct SignInScreen: View {
    let onSignIn: () -> Void
    let onGoToSignUp: () -> Void

    @StateObject private var viewModel: SignInViewModel
    @State private var passwordVisible = false

    init(
        viewModel: SignInViewModel,
        onSignIn: @escaping () -> Void,
        onGoToSignUp: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignIn = onSignIn
        self.onGoToSignUp = onGoToSignUp
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("CurlySignImg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

                VStack(spacing: 24) {
                    Text("Вход")
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

                        PasswordField(
                            title: "Пароль",
                            text: Binding(
                                get: { viewModel.password },
                                set: { viewModel.updatePassword($0) }
                            ),
                            isVisible: $passwordVisible
                        )

                        if let passwordError = viewModel.passwordError {
                            Text(passwordError)
                                .font(.textSerif)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.textSerif)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer().frame(height: 4)

                        Button {
                            viewModel.signIn(onSuccess: onSignIn)
                        } label: {
                            if viewModel.isEmailLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                            } else {
                                Text("Войти")
                                    .font(.bodySerif)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                            }
                        }
                        .background(canSignIn ? Color.curlyDarkGreen : Color.curlyGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(!canSignIn || viewModel.isEmailLoading)
                    }
                    .padding(24)

                    HStack(spacing: 4) {
                        Text("Еще нет аккаунта?")
                            .font(.textSerif)
                            .foregroundStyle(Color.curlyDarkGreen.opacity(0.7))
                        Button("Зарегистрироваться") {
                            onGoToSignUp()
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

    private var canSignIn: Bool {
        !viewModel.email.isEmpty && !viewModel.password.isEmpty
    }
}
