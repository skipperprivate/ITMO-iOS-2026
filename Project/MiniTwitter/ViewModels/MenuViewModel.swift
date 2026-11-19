import Foundation

struct MenuItem: Identifiable {
    var id: FeedSort { sort }
    let title: String
    let iconName: String
    let sort: FeedSort
}

final class MenuViewModel {
    let menuItems = [
        MenuItem(title: "Главная лента", iconName: "house.fill", sort: .latest),
        MenuItem(title: "Популярное", iconName: "flame.fill", sort: .popular)
    ]
}
