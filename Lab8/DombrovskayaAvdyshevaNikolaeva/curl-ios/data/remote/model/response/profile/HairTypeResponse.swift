import Foundation

struct HairTypeResponse: Codable {
    let porosity: String?
    let isColored: Bool?
    let thickness: String?
}

extension HairTypeResponse {
    func toDomain() -> HairType {
        return HairType(
            porosity: porosity,
            isColored: isColored,
            thickness: thickness
        )
    }
}

enum HairPorosity: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    
    var localizedName: String {
        switch self {
        case .low: return "Низкая"
        case .medium: return "Средняя"
        case .high: return "Высокая"
        }
    }
}

enum HairThickness: String, Codable, CaseIterable {
    case thin = "THIN"
    case medium = "MEDIUM"
    case thick = "THICK"
    
    var localizedName: String {
        switch self {
        case .thin: return "Тонкие"
        case .medium: return "Средние"
        case .thick: return "Толстые"
        }
    }
}
