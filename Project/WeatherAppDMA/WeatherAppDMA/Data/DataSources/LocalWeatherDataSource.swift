import Foundation

struct LocalWeatherDataSource: WeatherDataSource {
    let loader: BundleJSONLoader
    let fileName: String

    init(loader: BundleJSONLoader, fileName: String = "weather_mock") {
        self.loader = loader
        self.fileName = fileName
    }

    func loadWeather(for city: String) async throws -> WeatherDTO {
        let file: WeatherFileDTO = try await loader.load(fileName)
        guard let match = file.cities.first(where: {
            $0.city.compare(city, options: .caseInsensitive) == .orderedSame
        }) else {
            throw AppError.cityNotFound(city)
        }
        return match
    }

    func loadCities() async throws -> [CityDTO] {
        let file: WeatherFileDTO = try await loader.load(fileName)
        return file.cities.map {
            CityDTO(
                name: $0.city,
                currentTemperatureC: $0.current.temperatureC,
                condition: $0.current.condition,
                description: $0.current.description
            )
        }
    }
}
