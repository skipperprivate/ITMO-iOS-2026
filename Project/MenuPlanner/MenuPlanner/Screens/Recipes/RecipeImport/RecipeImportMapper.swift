import Foundation

enum RecipeImportMapper {
    static func ingredients(from recipe: VkusVillRecipe) -> [RecipeIngredientDraft] {
        (recipe.ingredients ?? []).map { ingredient in
            let source = ingredient.quantity?.trimmingCharacters(in: .whitespacesAndNewlines)
            let parsed = source.flatMap { parseQuantity($0) }
            return RecipeIngredientDraft(
                name: ingredient.name,
                quantity: parsed.map { String($0.amount) } ?? "",
                unit: parsed?.unit ?? .gram,
                sourceQuantity: parsed == nil ? source.flatMap { $0.isEmpty ? nil : $0 } ?? "не указано" : nil,
                suggestedProductIDs: ingredient.productIDs
            )
        }
    }

    static func instructions(from recipe: VkusVillRecipe) -> String {
        let steps = (recipe.steps ?? []).sorted { $0.stepNumber < $1.stepNumber }
        let method = steps.map { "\($0.stepNumber). \($0.text)" }.joined(separator: "\n")
        return [recipe.description ?? "", method].filter { !$0.isEmpty }.joined(separator: "\n\n")
    }

    static func duration(from cookingTime: String?) -> Int? {
        guard let normalized = cookingTime?.lowercased() else { return nil }
        // A range is only an estimate; retain the original label in the editor.
        let pattern = #/(?:(?:до|более)\s+)?(?:[0-9]+\s*[-–—]\s*)?([0-9]{1,4})\s*(мин(?:ут[аы]?)?\.?|час(?:а|ов)?|ч\.?)/#
        guard let match = normalized.wholeMatch(of: pattern), let value = Int(match.1), value > 0 else { return nil }
        let minutes = match.2.hasPrefix("ч") ? value * 60 : value
        return (1...1_440).contains(minutes) ? minutes : nil
    }

    private static func parseQuantity(_ source: String) -> (amount: Double, unit: MeasurementUnit)? {
        let pattern = #/([0-9]+(?:[.,][0-9]+)?)(?:\s*[/⁄]\s*([0-9]+))?\s*(.+)/#
        guard let match = source.lowercased().wholeMatch(of: pattern),
              let numerator = Double(match.1.replacingOccurrences(of: ",", with: ".")) else { return nil }
        let denominator = match.2.flatMap { Double($0) } ?? 1
        guard numerator > 0, denominator > 0 else { return nil }
        let amount = numerator / denominator
        guard amount.isFinite else { return nil }
        let key = match.3.filter { !$0.isWhitespace && $0 != "." }
        let unit: MeasurementUnit
        switch key {
        case "г", "гр", "грамм", "грамма", "граммов": unit = .gram
        case "кг", "килограмм", "килограмма", "килограммов": unit = .kilogram
        case "мл", "миллилитр", "миллилитра", "миллилитров": unit = .milliliter
        case "л", "литр", "литра", "литров": unit = .liter
        case "шт", "штука", "штуки", "штук": unit = .piece
        case "чл", "чайнаяложка", "чайнойложки", "чайныеложки", "чайныхложек": unit = .teaspoon
        case "стл", "столоваяложка", "столовойложки", "столовыеложки", "столовыхложек": unit = .tablespoon
        default: return nil
        }
        return (amount, unit)
    }
}
