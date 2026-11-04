import Foundation

struct TMDBRatingRequestDTO:
    Encodable {

    let value: Double
}

struct TMDBRatingResponseDTO:
    Decodable {

    let statusCode: Int

    let statusMessage: String

    enum CodingKeys:
        String,
        CodingKey {

        case statusCode =
            "status_code"

        case statusMessage =
            "status_message"
    }
}
