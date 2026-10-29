struct News: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String
    var isFavorite: Bool = false
}
