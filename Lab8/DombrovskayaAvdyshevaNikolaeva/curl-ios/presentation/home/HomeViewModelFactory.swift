@MainActor
enum HomeViewModelFactory {
    static func make(router: HomeRouter) -> HomeViewModel {
        let repository: AuthRepository = AuthRepositoryImpl()

        return HomeViewModel(
            logoutUseCase: LogoutUseCase(authRepository: repository),
            router: router
        )
    }
}
