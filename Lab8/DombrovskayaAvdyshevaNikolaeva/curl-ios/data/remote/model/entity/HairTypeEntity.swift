import SwiftData
import Foundation

@Model
class HairTypeEntity {
    @Attribute(.unique) var userId: String
    var porosity: String?
    var isColored: Bool?
    var thickness: String?
    var dateUpdated: Date
    
    init(userId: String, porosity: String? = nil, isColored: Bool? = nil, thickness: String? = nil, dateUpdated: Date = Date()) {
        self.userId = userId
        self.porosity = porosity
        self.isColored = isColored
        self.thickness = thickness
        self.dateUpdated = dateUpdated
    }
    
    /// Обновить поля из ответа сервера
    func update(from response: HairTypeResponse) {
        self.porosity = response.porosity
        self.isColored = response.isColored
        self.thickness = response.thickness
        self.dateUpdated = Date()
    }
    
    /// Конвертировать в сетевую модель (для отправки на сервер)
    func toRequest() -> HairTypeRequest {
        return HairTypeRequest(
            userId: userId,
            porosity: porosity,
            isColored: isColored,
            thickness: thickness
        )
    }
}
