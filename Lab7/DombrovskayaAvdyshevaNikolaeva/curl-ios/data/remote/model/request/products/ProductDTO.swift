import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let brand: String?
    let thumbnail: String
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case price
        case rating
        case brand
        case thumbnail
        case tags
    }
}


