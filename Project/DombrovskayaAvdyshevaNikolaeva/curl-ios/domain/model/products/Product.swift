import Foundation

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let tags: [String]
    let imageUrl: URL?
    
    init(id: UUID, name: String, description: String, tags: [String], imageUrlString: String?) {
        self.id = id
        self.name = name
        self.description = description
        self.tags = tags
        self.imageUrl = imageUrlString.flatMap { URL(string: $0) }
    }
}
