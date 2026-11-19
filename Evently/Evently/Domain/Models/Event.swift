import Foundation

struct Event: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let category: EventCategoryRu
    let venue: String
    let city: String
    let date: Date
    let imageURL: URL?
    let price: String?
    let isFeatured: Bool
    let sourceID: String?
    let description: String?
    let address: String?
    let ticketURL: URL?

    init(
        id: UUID = UUID(),
        title: String,
        category: EventCategoryRu,
        venue: String,
        city: String,
        date: Date,
        imageURL: URL? = nil,
        price: String? = nil,
        isFeatured: Bool = false,
        sourceID: String? = nil,
        description: String? = nil,
        address: String? = nil,
        ticketURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.venue = venue
        self.city = city
        self.date = date
        self.imageURL = imageURL
        self.price = price
        self.isFeatured = isFeatured
        self.sourceID = sourceID
        self.description = description
        self.address = address
        self.ticketURL = ticketURL
    }
}
enum EventCategoryRu: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all = "Все"
    case music = "Музыка"
    case sport = "Спорт"
    case arts = "Искусство и театр"
    case film = "Кино"
    case miscellaneous = "Развлечения"
    case other = "Другое"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .all:
            return "square.grid.2x2.fill"
        case .music:
            return "music.note"
        case .sport:
            return "sportscourt.fill"
        case .arts:
            return "theatermasks.fill"
        case .film:
            return "film.fill"
        case .miscellaneous:
            return "sparkles"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}
