import Foundation

struct LogoutUseCase {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func callAsFunction() async throws {
        return await authRepository.logout()
    }
}
