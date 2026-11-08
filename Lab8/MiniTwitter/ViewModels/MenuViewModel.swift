import Foundation

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

final class MenuViewModel {
    let menuItems = [
        MenuItem(title: "Главная лента", iconName: "house.fill"),
        MenuItem(title: "Популярное", iconName: "flame.fill"),
        MenuItem(title: "Подписки", iconName: "person.2.fill")
    ]
}
