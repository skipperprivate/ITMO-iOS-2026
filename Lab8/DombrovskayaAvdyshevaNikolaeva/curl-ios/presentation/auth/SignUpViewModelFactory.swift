import Foundation

@MainActor
enum SignUpViewModelFactory {
    static func make() -> SignUpViewModel {
        let repository: AuthRepository = AuthRepositoryImpl()

        return SignUpViewModel(
            signUpUseCase: SignUpUseCase(authRepository: repository),
            validatePasswordUseCase: ValidatePasswordUseCase()
        )
    }
}
