import Foundation

enum RecipeFormatting {
    static func count(_ value: Int, one: String, few: String, many: String) -> String {
        let ending: String
        
        switch (value % 100, value % 10) {
            case (11...14, _): ending = many
            case (_, 1): ending = one
            case (_, 2...4): ending = few
            default: ending = many
        }
        
        return "\(value) \(ending)"
    }

    static func quantity(_ value: Double, unit: MeasurementUnit) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0...2)))) \(unit.title)"
    }
}
