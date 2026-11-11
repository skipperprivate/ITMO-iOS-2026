import Foundation

protocol AnalysisRepository {
    func analyzePhoto(imageData: Data) async throws -> String
}
