import Foundation

enum AppRoute: Hashable {
    case search
    case eventDetails(Event)
    case settings
}
