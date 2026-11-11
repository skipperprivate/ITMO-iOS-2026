import Foundation
import SwiftData

@Model
class UserProfileEntity {
    @Attribute(.unique) var id: UUID
    var email: String?
    var username: String
    var registrationDate: Date
    var imageUrl: String?
    var dateCached: Date
    
    init(
        id: UUID,
        email: String? = nil,
        username: String,
        registrationDate: Date = Date(),
        imageUrl: String? = nil,
        dateCached: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.registrationDate = registrationDate
        self.imageUrl = imageUrl
        self.dateCached = dateCached
    }
}
