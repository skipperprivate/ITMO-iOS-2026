import Foundation

protocol HairTypesRepository {
    func updateHairType(userId: String, request: HairTypeRequest) async throws
    func getHairType(userId: String) async throws -> HairTypeResponse
}

final class HairTypesRepositoryImpl: HairTypesRepository {
    private let apiService = ApiService.shared
    private let userDefaultsService = UserDefaultsService.shared
    
    func updateHairType(userId: String, request: HairTypeRequest) async throws {
        let path = "/hairtypes/\(userId)"
        let token = await AuthManager.shared.getAccessToken()
        try await apiService.put(path, body: request, token: token)
    }
    
    func getHairType(userId: String) async throws -> HairTypeResponse {
        let path = "/hairtypes/\(userId)"
        _ = await AuthManager.shared.getAccessToken()
        let hairType: HairTypeResponse = try await apiService.get(path)
        return hairType
    }
}
