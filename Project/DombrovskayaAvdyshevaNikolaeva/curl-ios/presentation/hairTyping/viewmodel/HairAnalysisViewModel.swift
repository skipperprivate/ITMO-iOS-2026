import Foundation
import Combine

@MainActor
final class HairAnalysisViewModel: ObservableObject {
    @Published private(set) var result: String?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var saved: Bool?

    private let analysisRepository: AnalysisRepository
    private let hairTypesRepository: HairTypesRepository
    private let userDefaultsService: UserDefaultsService

    init(
        analysisRepository: AnalysisRepository = AnalysisRepositoryImpl(),
        hairTypesRepository: HairTypesRepository = HairTypesRepositoryImpl(),
        userDefaultsService: UserDefaultsService = .shared
    ) {
        self.analysisRepository = analysisRepository
        self.hairTypesRepository = hairTypesRepository
        self.userDefaultsService = userDefaultsService
    }

    func analyze(imageData: Data) {
        isLoading = true
        error = nil
        result = nil

        Task {
            defer { isLoading = false }
            do {
                result = try await analysisRepository.analyzePhoto(imageData: imageData)
            } catch {
                self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func saveResult() {
        guard let porosityResult = result?.uppercased() else { return }

        let porosityCode: String?
        switch porosityResult {
        case "ВЫСОКАЯ ПОРИСТОСТЬ": porosityCode = UserDefaultsService.PorosityDbOptions.high
        case "СРЕДНЯЯ ПОРИСТОСТЬ": porosityCode = UserDefaultsService.PorosityDbOptions.medium
        case "НИЗКАЯ ПОРИСТОСТЬ":  porosityCode = UserDefaultsService.PorosityDbOptions.low
        default: porosityCode = nil
        }

        guard let userId = AuthManager.shared.getUserId() else {
            saved = false
            return
        }

        Task {
            do {
                try await hairTypesRepository.updateHairType(
                    userId: userId,
                    request: HairTypeRequest(userId: userId, porosity: porosityCode)
                )

                if let porosityCode {
                    userDefaultsService.hairPorosity = userDefaultsService.porosityFromDbCode(dbCode: porosityCode)
                }

                saved = true
            } catch {
                saved = false
            }
        }
    }

    func clearSaved() {
        saved = nil
    }
}
