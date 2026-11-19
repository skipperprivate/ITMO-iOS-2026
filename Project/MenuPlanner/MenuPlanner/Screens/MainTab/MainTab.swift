import Foundation

enum MainTab: String, CaseIterable, Identifiable {
    case menu
    case recipes
    case shopping

    var id: Self { self }

    var title: String {
        switch self {
        case .menu: "Меню"
        case .recipes: "Рецепты"
        case .shopping: "Покупки"
        }
    }

    var iconName: String {
        switch self {
        case .menu: "TabCalendar"
        case .recipes: "TabBook"
        case .shopping: "TabBag"
        }
    }
}
