import Foundation

struct SignUpUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func callAsFunction(email: String,
                        password: String,
                        username: String) async throws -> AuthResponse {
        guard isValidEmail(email) else {
            throw AuthError.validation(AuthErrors.invalidEmail)
        }

        guard password.count >= 6 else {
            throw AuthError.validation(AuthErrors.passwordTooShort)
        }

        guard username.count >= 2 else {
            throw AuthError.validation(AuthErrors.usernameTooShort)
        }

        guard username.count <= 20 else {
            throw AuthError.validation(AuthErrors.usernameTooLong)
        }

        return try await authRepository.register(
            email: email,
            password: password,
            username: username
        )
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
