import Foundation

struct TMDBGuestSessionDTO:
    Decodable {

    let success: Bool

    let guestSessionID: String

    let expiresAt: String

    enum CodingKeys:
        String,
        CodingKey {

        case success

        case guestSessionID =
            "guest_session_id"

        case expiresAt =
            "expires_at"
    }
}
