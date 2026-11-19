import Foundation
@testable import WeatherAppDMA

struct MockGetWeatherForCityUseCase: GetWeatherForCityUseCase {
    let result: Result<Weather, Error>

    func execute(city: String) async throws -> Weather {
        try result.get()
    }
}
