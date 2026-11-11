import Foundation
import Combine

@MainActor
final class SignInViewModel: ObservableObject {

    @Published var email: String = "" {
        didSet { errorMessage = nil }
    }

    @Published var password: String = "" {
        didSet {
            errorMessage = nil
            if !password.isEmpty {
                let validation = validatePasswordUseCase.validatePasswordStrength(password)
                passwordError = validation.errorMessage
            } else {
                passwordError = nil
            }
        }
    }

    @Published private(set) var isEmailLoading: Bool = false
    @Published private(set) var isGoogleLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var passwordError: String?

    private let signInUseCase: SignInUseCase
    private let validatePasswordUseCase: ValidatePasswordUseCase

    init(signInUseCase: SignInUseCase,
         validatePasswordUseCase: ValidatePasswordUseCase) {
        self.signInUseCase = signInUseCase
        self.validatePasswordUseCase = validatePasswordUseCase
    }

    func updateEmail(_ value: String) { email = value }
    func updatePassword(_ value: String) { password = value }

    func clearError() {
        errorMessage = nil
        passwordError = nil
    }

    func signIn(onSuccess: @escaping () -> Void) {
        if email.isEmpty || password.isEmpty {
            errorMessage = AuthErrors.fieldsRequired
            return
        }

        let passwordValidation = validatePasswordUseCase.validatePasswordStrength(password)
        if !passwordValidation.successful {
            errorMessage = passwordValidation.errorMessage
            return
        }

        isEmailLoading = true
        Task {
            defer { isEmailLoading = false }
            do {
                _ = try await signInUseCase(email: email, password: password)
                errorMessage = nil
                onSuccess()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? error.localizedDescription
            }
        }
    }
}
