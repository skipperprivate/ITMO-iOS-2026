import Foundation

struct ValidatePasswordUseCase {

    func callAsFunction(_ password: String, _ confirmPassword: String) -> ValidationResult {
        if password.count < 6 {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordTooShort)
        }
        if password.count > 20 {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordTooLong)
        }
        if containsNonLatinLetters(password) {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordNonLatin)
        }
        if password != confirmPassword {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordsDontMatch)
        }
        return ValidationResult(successful: true)
    }

    func validatePasswordStrength(_ password: String) -> ValidationResult {
        if password.count < 6 {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordTooShort)
        }
        if password.count > 20 {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordTooLong)
        }
        if containsNonLatinLetters(password) {
            return ValidationResult(successful: false, errorMessage: AuthErrors.passwordNonLatin)
        }
        return ValidationResult(successful: true)
    }

    private func containsNonLatinLetters(_ text: String) -> Bool {
        text.contains { character in
            character.isLetter && !isLatinLetter(character)
        }
    }

    private func isLatinLetter(_ character: Character) -> Bool {
        ("a"..."z").contains(character) || ("A"..."Z").contains(character)
    }
}

struct ValidationResult {
    let successful: Bool
    let errorMessage: String?

    init(successful: Bool, errorMessage: String? = nil) {
        self.successful = successful
        self.errorMessage = errorMessage
    }
}
