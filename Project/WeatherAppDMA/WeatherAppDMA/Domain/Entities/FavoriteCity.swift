import Foundation

struct FavoriteCity: Identifiable, Equatable, Sendable, Hashable {
    let id: UUID
    let cityName: String
    let addedAt: Date
    var note: String?
    var position: Int

    init(id: UUID = UUID(), cityName: String, addedAt: Date = Date(), note: String? = nil, position: Int = 0) {
        self.id = id
        self.cityName = cityName
        self.addedAt = addedAt
        self.note = note
        self.position = position
    }
}
