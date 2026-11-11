import Foundation

struct SignInUseCase {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    func callAsFunction(email: String, password: String) async throws -> AuthResponse {
        guard isValidEmail(email) else {
            throw AuthError.validation(AuthErrors.invalidEmail)
        }

        guard !password.isEmpty else {
            throw AuthError.validation(AuthErrors.passwordEmpty)
        }

        return try await authRepository.login(email: email, password: password)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
