import Foundation

final class AnalysisRepositoryImpl: AnalysisRepository {
    private let apiClient: ApiService

    init(apiClient: ApiService = .shared) {
        self.apiClient = apiClient
    }

    func analyzePhoto(imageData: Data) async throws -> String {
        let raw: String = try await apiClient.postMultipart(
            "/analyze",
            fieldName: "file",
            fileName: "photo.jpg",
            mimeType: "image/jpeg",
            fileData: imageData
        )

        guard
            let json = try? JSONSerialization.jsonObject(with: Data(raw.utf8)) as? [String: Any],
            let resultObj = json["result"] as? [String: Any],
            let porosity = (resultObj["porosity"] as? String)?.uppercased()
        else {
            return raw.isEmpty ? "Результат недоступен" : raw
        }

        switch porosity {
        case "HIGH":   return "Высокая пористость"
        case "MEDIUM": return "Средняя пористость"
        case "LOW":    return "Низкая пористость"
        default:       return raw.isEmpty ? "Результат недоступен" : raw
        }
    }
}
