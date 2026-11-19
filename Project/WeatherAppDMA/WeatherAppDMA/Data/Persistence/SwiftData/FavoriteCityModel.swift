import Foundation
import SwiftData

@Model
final class FavoriteCityModel {
    @Attribute(.unique) var id: UUID
    var cityName: String
    var addedAt: Date
    var note: String?
    var position: Int

    init(id: UUID = UUID(), cityName: String, addedAt: Date = Date(), note: String? = nil, position: Int = 0) {
        self.id = id
        self.cityName = cityName
        self.addedAt = addedAt
        self.note = note
        self.position = position
    }

    func toDomain() -> FavoriteCity {
        FavoriteCity(id: id, cityName: cityName, addedAt: addedAt, note: note, position: position)
    }
}
