import Foundation

nonisolated struct TicketmasterResponseDTO: Decodable, Sendable {
    let embedded: TicketmasterEmbeddedDTO?
    let page: TicketmasterPageDTO?

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case page
    }
}

nonisolated struct TicketmasterPageDTO: Decodable, Sendable {
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let number: Int
}

nonisolated struct TicketmasterEmbeddedDTO: Decodable, Sendable {
    let events: [TicketmasterEventDTO]?
}

nonisolated struct TicketmasterEventDTO: Decodable, Sendable {
    let id: String
    let name: String
    let dates: TicketmasterDatesDTO?
    let images: [TicketmasterImageDTO]?
    let classifications: [TicketmasterClassificationDTO]?
    let priceRanges: [TicketmasterPriceDTO]?
    let description: String?
    let info: String?
    let pleaseNote: String?
    let url: String?
    let embedded: TicketmasterEventEmbeddedDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, dates, images, classifications, priceRanges
        case description, info, pleaseNote, url
        case embedded = "_embedded"
    }
}

nonisolated struct TicketmasterDatesDTO: Decodable, Sendable {
    let start: TicketmasterStartDTO?
}

nonisolated struct TicketmasterStartDTO: Decodable, Sendable {
    let localDate: String?
    let dateTime: String?
}

nonisolated struct TicketmasterImageDTO: Decodable, Sendable {
    let url: String
    let width: Int?
    let height: Int?
}

nonisolated struct TicketmasterClassificationDTO: Decodable, Sendable {
    let segment: TicketmasterClassificationNameDTO?
    let genre: TicketmasterClassificationNameDTO?
}

nonisolated struct TicketmasterClassificationNameDTO: Decodable, Sendable {
    let name: String?
}

nonisolated struct TicketmasterPriceDTO: Decodable, Sendable {
    let min: Double?
    let max: Double?
    let currency: String?
}

nonisolated struct TicketmasterEventEmbeddedDTO: Decodable, Sendable {
    let venues: [TicketmasterVenueDTO]?
}

nonisolated struct TicketmasterVenueDTO: Decodable, Sendable {
    let name: String?
    let city: TicketmasterCityDTO?
    let address: TicketmasterAddressDTO?
    let state: TicketmasterClassificationNameDTO?
    let postalCode: String?
}

nonisolated struct TicketmasterAddressDTO: Decodable, Sendable {
    let line1: String?
    let line2: String?
}

nonisolated struct TicketmasterCityDTO: Decodable, Sendable {
    let name: String?
}
