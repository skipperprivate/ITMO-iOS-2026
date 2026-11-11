import Foundation

@MainActor
enum SignInViewModelFactory {
    static func make() -> SignInViewModel {
        let repository: AuthRepository = AuthRepositoryImpl()

        return SignInViewModel(
            signInUseCase: SignInUseCase(authRepository: repository),
            validatePasswordUseCase: ValidatePasswordUseCase()
        )
    }
}
