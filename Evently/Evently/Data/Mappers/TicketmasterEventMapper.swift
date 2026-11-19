import CryptoKit
import Foundation

enum TicketmasterEventMapper {

    static func map(
        _ dto: TicketmasterEventDTO,
        isFeatured: Bool = false
    ) -> Event? {

        guard let date = parseDate(dto.dates?.start) else {
            return nil
        }

        let venue = dto.embedded?.venues?.first

        let imageURL = dto.images?
            .sorted {
                ($0.width ?? 0) > ($1.width ?? 0)
            }
            .compactMap { URL(string: $0.url) }
            .first

        return Event(
            id: stableUUID(for: dto.id),
            title: dto.name,
            category: mapCategory(dto.classifications),
            venue: venue?.name ?? "Место уточняется",
            city: venue?.city?.name ?? "Город не указан",
            date: date,
            imageURL: imageURL,
            price: mapPrice(dto.priceRanges),
            isFeatured: isFeatured,
            sourceID: dto.id,
            description: detailsDescription(dto),
            address: address(for: venue),
            ticketURL: safeHTTPSURL(dto.url)
        )
    }

    private static func detailsDescription(_ dto: TicketmasterEventDTO) -> String? {
        [dto.description, dto.info, dto.pleaseNote]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    private static func address(for venue: TicketmasterVenueDTO?) -> String? {
        guard let venue else { return nil }

        let parts = [
            venue.address?.line1,
            venue.address?.line2,
            venue.city?.name,
            venue.state?.name,
            venue.postalCode
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private static func safeHTTPSURL(_ rawValue: String?) -> URL? {
        guard let rawValue,
              let url = URL(string: rawValue),
              url.scheme?.lowercased() == "https",
              url.host != nil else {
            return nil
        }
        return url
    }

    private static func parseDate(
        _ start: TicketmasterStartDTO?
    ) -> Date? {

        guard let start else { return nil }

        if let dateTime = start.dateTime {
            let formatter = ISO8601DateFormatter()

            if let date = formatter.date(from: dateTime) {
                return date
            }
        }

        guard let localDate = start.localDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.date(from: localDate)
    }

    private static func mapCategory(
        _ classifications: [TicketmasterClassificationDTO]?
    ) -> EventCategoryRu {

        guard let classification = classifications?.first else {
            return .other
        }

        let segment = classification.segment?.name?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        switch segment {
        case "music":
            return .music

        case "sports":
            return .sport

        case "arts & theatre", "arts & theater":
            return .arts

        case "film":
            return .film

        case "miscellaneous":
            return .miscellaneous

        default:
            return .other
        }
    }

    private static func mapPrice(
        _ prices: [TicketmasterPriceDTO]?
    ) -> String? {

        guard let price = prices?.first,
              let min = price.min else {
            return nil
        }

        let currency = price.currency ?? "USD"

        return "от \(min.formatted()) \(currency)"
    }

    private static func stableUUID(for id: String) -> UUID {
        let digest = SHA256.hash(data: Data(id.utf8))

        let hex = digest.prefix(16)
            .map { String(format: "%02x", $0) }
            .joined()

        let part1 = String(hex.prefix(8))
        let part2 = String(hex.dropFirst(8).prefix(4))
        let part3 = String(hex.dropFirst(12).prefix(4))
        let part4 = String(hex.dropFirst(16).prefix(4))
        let part5 = String(hex.dropFirst(20).prefix(12))

        let uuidString = "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"

        guard let uuid = UUID(uuidString: uuidString) else {
            preconditionFailure("SHA256 produced an invalid UUID")
        }
        return uuid
    }
}
