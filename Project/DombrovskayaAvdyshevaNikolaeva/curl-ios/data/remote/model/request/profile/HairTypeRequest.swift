import Foundation

struct HairTypeRequest: Codable {
    let userId: String
    let porosity: String?
    let isColored: Bool?
    let thickness: String?

    init(
        userId: String,
        porosity: String? = nil,
        isColored: Bool? = nil,
        thickness: String? = nil
    ) {
        self.userId = userId
        self.porosity = porosity
        self.isColored = isColored
        self.thickness = thickness
    }
}
