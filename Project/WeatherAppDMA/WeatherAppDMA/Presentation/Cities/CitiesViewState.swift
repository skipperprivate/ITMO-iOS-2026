import Foundation

enum CitiesViewState: Equatable {
    case loading
    case loaded([CitySummary])
    case error(message: String)
}
