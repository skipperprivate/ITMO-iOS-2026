import XCTest
@testable import SomeWeather

@MainActor
final class WeatherAppTests: XCTestCase {

    func testWeatherCodeIsConvertedToTextAndIcon() {
        XCTAssertEqual(WeatherPresentation.description(for: 0), "Ясно")
        XCTAssertEqual(WeatherPresentation.symbol(for: 0, isDay: true), "sun.max.fill")
        XCTAssertEqual(WeatherPresentation.symbol(for: 0, isDay: false), "moon.stars.fill")

        XCTAssertEqual(WeatherPresentation.description(for: 999), "Нет данных")
        XCTAssertEqual(WeatherPresentation.symbol(for: 999), "questionmark.circle")
    }

    func testTemperatureCelsiusAndFahrenheit() {
        let settings = SettingsStore(defaults: UserDefaults(suiteName: "WeatherAppTests")!)
        let model = WeatherViewModel(repository: nil, settings: settings)

        model.useFahrenheit = false
        XCTAssertEqual(model.temperatureText(0), "0 °C")
        XCTAssertEqual(model.temperatureText(12.5), "13 °C")

        model.useFahrenheit = true
        XCTAssertEqual(model.temperatureText(0), "32 °F")
        XCTAssertEqual(model.temperatureText(20), "68 °F")
    }
}
