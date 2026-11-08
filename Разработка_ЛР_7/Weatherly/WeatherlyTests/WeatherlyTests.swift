// Unit tests for domain models and settings conversions.
import XCTest
@testable import Weatherly

final class WeatherlyTests: XCTestCase {
    func testTemperatureConversionFromCelsiusToFahrenheit() {
        XCTAssertEqual(TemperatureUnit.celsius.convert(fromCelsius: 20), 20, accuracy: 0.001)
        XCTAssertEqual(TemperatureUnit.fahrenheit.convert(fromCelsius: 0), 32, accuracy: 0.001)
        XCTAssertEqual(TemperatureUnit.fahrenheit.convert(fromCelsius: 100), 212, accuracy: 0.001)
    }

    func testWindSpeedConversions() {
        XCTAssertEqual(WindSpeedUnit.kilometersPerHour.convert(fromKmh: 36), 36, accuracy: 0.001)
        XCTAssertEqual(WindSpeedUnit.metersPerSecond.convert(fromKmh: 36), 10, accuracy: 0.001)
        XCTAssertEqual(WindSpeedUnit.milesPerHour.convert(fromKmh: 1.609344), 1, accuracy: 0.001)
        XCTAssertEqual(WindSpeedUnit.knots.convert(fromKmh: 1.852), 1, accuracy: 0.001)
    }

    func testPressureConversions() {
        XCTAssertEqual(PressureUnit.hectopascals.convert(fromHPa: 1000), 1000, accuracy: 0.001)
        XCTAssertEqual(PressureUnit.millimetersOfMercury.convert(fromHPa: 1000), 750.062, accuracy: 0.001)
        XCTAssertEqual(PressureUnit.inchesOfMercury.convert(fromHPa: 1000), 29.53, accuracy: 0.001)
    }

    func testDefaultSettingsAreStable() {
        let settings = AppSettings.default
        XCTAssertEqual(settings.temperatureUnit, .celsius)
        XCTAssertEqual(settings.windSpeedUnit, .metersPerSecond)
        XCTAssertEqual(settings.pressureUnit, .millimetersOfMercury)
        XCTAssertEqual(settings.theme, .auto)
    }

    func testSettingsCodableRoundTrip() throws {
        let original = AppSettings(temperatureUnit: .fahrenheit, windSpeedUnit: .knots, pressureUnit: .hectopascals, theme: .dark)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func testUnknownSettingsValuesFallBackToDefaults() throws {
        let data = Data(#"{"temperatureUnit":"kelvin","windSpeedUnit":"unknown","pressureUnit":"unknown","theme":"neon"}"#.utf8)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)
        XCTAssertEqual(decoded, .default)
    }

    func testCitySubtitleOmitsEmptyRegion() {
        let city = City(id: "1", name: "Москва", region: "", country: "Россия", latitude: 55.75, longitude: 37.61, timeZoneIdentifier: "Europe/Moscow")
        XCTAssertEqual(city.subtitle, "Россия")
    }

    func testCityCalendarUsesCityTimeZone() {
        let city = City(id: "1", name: "Токио", region: "", country: "Япония", latitude: 35.68, longitude: 139.69, timeZoneIdentifier: "Asia/Tokyo")
        XCTAssertEqual(city.calendar.timeZone.identifier, "Asia/Tokyo")
    }
}
