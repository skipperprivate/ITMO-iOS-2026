import Foundation
import Combine

@MainActor
final class SignUpViewModel: ObservableObject {

    @Published var email: String = "" { didSet { errorMessage = nil } }
    @Published var username: String = "" { didSet { errorMessage = nil } }
    @Published var password: String = "" { didSet { errorMessage = nil } }
    @Published var confirmPassword: String = "" { didSet { errorMessage = nil } }

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let signUpUseCase: SignUpUseCase
    private let validatePasswordUseCase: ValidatePasswordUseCase

    init(signUpUseCase: SignUpUseCase,
         validatePasswordUseCase: ValidatePasswordUseCase) {
        self.signUpUseCase = signUpUseCase
        self.validatePasswordUseCase = validatePasswordUseCase
    }

    func updateEmail(_ value: String) { email = value }
    func updateUsername(_ value: String) { username = value }
    func updatePassword(_ value: String) { password = value }
    func updateConfirmPassword(_ value: String) { confirmPassword = value }

    func clearError() { errorMessage = nil }

    func signUp(onSuccess: @escaping () -> Void) {
        if username.count > 20 {
            errorMessage = AuthErrors.usernameTooLong
            return
        }
        if username.count < 2 {
            errorMessage = AuthErrors.usernameTooShort
            return
        }

        let passwordValidation = validatePasswordUseCase(password, confirmPassword)
        if !passwordValidation.successful {
            errorMessage = passwordValidation.errorMessage
            return
        }

        if email.isEmpty || username.isEmpty {
            errorMessage = AuthErrors.fieldsRequired
            return
        }

        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                _ = try await signUpUseCase(
                    email: email,
                    password: password,
                    username: username
                )
                errorMessage = nil
                onSuccess()
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? error.localizedDescription
            }
        }
    }
}
