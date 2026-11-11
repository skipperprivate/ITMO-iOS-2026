import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    
    let id: Int
    let name: String
    let ingredients: [String]
    let instructions: [String]
    
    let prepTimeMinutes: Int
    let cookTimeMinutes: Int
    
    let servings: Int
    let difficulty: String
    let cuisine: String
    
    let caloriesPerServing: Int
    let image: String
    let tags: [String]
    
    var totalTime: Int {
        prepTimeMinutes + cookTimeMinutes
    }
    
    var difficultyText: String {
        switch difficulty.lowercased() {
        case "easy":
            return "Легко"
        case "medium":
            return "Средне"
        case "hard":
            return "Сложно"
        default:
            return difficulty
        }
    }
    
    var cuisineText: String {
        switch cuisine.lowercased() {
        case "italian":
            return "Итальянская"
        case "japanese":
            return "Японская"
        case "mexican":
            return "Мексиканская"
        case "american":
            return "Американская"
        case "indian":
            return "Индийская"
        case "thai":
            return "Тайская"
        case "greek":
            return "Греческая"
        case "korean":
            return "Корейская"
        default:
            return cuisine
        }
    }
}

struct RecipesResponse: Codable {
    let recipes: [Recipe]
    let total: Int
    let skip: Int
    let limit: Int
}
