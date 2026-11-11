import Foundation

enum AuthErrors {
    static let invalidEmail = "Неверный формат email"

    static let passwordEmpty = "Пароль не может быть пустым"
    static let passwordTooShort = "Пароль должен содержать минимум 6 символов"
    static let passwordTooLong = "Пароль должен содержать не более 20 символов"
    static let passwordNonLatin = "Пароль может содержать любые символы, но буквы только латинские"
    static let passwordsDontMatch = "Пароли не совпадают"

    static let usernameTooShort = "Имя должно содержать минимум 2 символа"
    static let usernameTooLong = "Имя должно содержать не более 20 символов"

    static let googleTokenEmpty = "Google token отсутствует"

    static let fieldsRequired = "Пожалуйста, заполните все поля"
    static let registrationFailed = "Ошибка регистрации"
    static let loginFailed = "Ошибка входа"
    static let googleLoginFailed = "Ошибка Google входа"
    static let networkError = "Ошибка сети"
}
