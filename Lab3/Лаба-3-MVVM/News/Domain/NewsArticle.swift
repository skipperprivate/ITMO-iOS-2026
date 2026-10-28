// описание данных в приложении

import Foundation

struct NewsArticle: Identifiable, Equatable, Sendable {
    let id: Int
    let title: String
    let body: String
}
