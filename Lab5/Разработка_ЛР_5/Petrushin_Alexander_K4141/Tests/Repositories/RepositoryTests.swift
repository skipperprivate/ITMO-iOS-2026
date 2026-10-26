//
//  RepositoryTests.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import XCTest
@testable import Weatherly

final class OpenMeteoMapperTests: XCTestCase {
    private func decodeForecast(_ data: Data = Fixtures.forecastData) throws -> OpenMeteoForecastDTO {
        try JSONDecoder().decode(OpenMeteoForecastDTO.self, from: data)
    }

    func testMapsRealForecastResponse() throws {
        let snapshot = try OpenMeteoMapper.snapshot(from: decodeForecast(), city: TestCities.moscow)

        XCTAssertEqual(snapshot.city, TestCities.moscow)
        XCTAssertEqual(snapshot.hourly.count, 48)
        XCTAssertEqual(snapshot.daily.count, 2)

        let current = snapshot.current
        XCTAssertEqual(current.temperatureCelsius, 11.1)
        XCTAssertEqual(current.feelsLikeCelsius, 9.8)
        XCTAssertEqual(current.condition, .cloudy)
        XCTAssertFalse(current.isDaytime)
        XCTAssertEqual(current.windSpeedKmh, 2.1)
        XCTAssertEqual(current.windGustsKmh, 4.3)
        XCTAssertEqual(current.windDirectionDegrees, 329)
        XCTAssertEqual(current.humidityPercent, 72)
        XCTAssertEqual(current.pressureHPa, 1032.8)
        XCTAssertEqual(current.visibilityKm, 39.32, accuracy: 0.0001)
        XCTAssertEqual(current.updatedAt, Date(timeIntervalSince1970: 1_790_702_100))

        let day = try XCTUnwrap(snapshot.daily.first)
        XCTAssertEqual(day.condition, .fog)
        XCTAssertEqual(day.minTemperatureCelsius, 5.3)
        XCTAssertEqual(day.maxTemperatureCelsius, 15.4)
        XCTAssertEqual(day.uvIndexMax, 3.1)
        XCTAssertEqual(day.sunrise, Date(timeIntervalSince1970: 1_790_652_484))
        XCTAssertEqual(day.sunset, Date(timeIntervalSince1970: 1_790_694_630))
    }

    // The contract the UI relies on: hourly and daily start at local midnight of the city.
    func testSeriesStartAtMidnightInCityTimeZone() throws {
        let snapshot = try OpenMeteoMapper.snapshot(from: decodeForecast(), city: TestCities.moscow)
        let calendar = TestCities.moscow.calendar

        XCTAssertEqual(snapshot.hourly.first?.date, calendar.startOfDay(for: snapshot.current.updatedAt))
        XCTAssertEqual(snapshot.daily.first?.date, calendar.startOfDay(for: snapshot.current.updatedAt))
        XCTAssertNotNil(snapshot.today)
        XCTAssertEqual(snapshot.hourlyItems(on: snapshot.daily[1].date).count, 24)
    }

    func testNullHourIsDroppedAndNullIsDayIsDerivedFromSunTimes() throws {
        let data = try Fixtures.forecastData { json in
            var hourly = json["hourly"] as! [String: Any]
            var temperatures = hourly["temperature_2m"] as! [Any]
            temperatures[0] = NSNull()
            hourly["temperature_2m"] = temperatures
            var isDay = hourly["is_day"] as! [Any]
            isDay[12] = NSNull()
            isDay[2] = NSNull()
            hourly["is_day"] = isDay
            json["hourly"] = hourly
        }

        let snapshot = try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: TestCities.moscow)

        XCTAssertEqual(snapshot.hourly.count, 47)
        XCTAssertEqual(snapshot.hourly.first?.date, Date(timeIntervalSince1970: 1_790_632_800))
        XCTAssertTrue(snapshot.hourly[11].isDaytime, "12:00 is between sunrise and sunset")
        XCTAssertFalse(snapshot.hourly[1].isDaytime, "02:00 is before sunrise")
    }

    func testNullSecondaryMetricsFallBack() throws {
        let data = try Fixtures.forecastData { json in
            var current = json["current"] as! [String: Any]
            current["apparent_temperature"] = NSNull()
            current["wind_gusts_10m"] = NSNull()
            current["uv_index"] = NSNull()
            json["current"] = current
            var daily = json["daily"] as! [String: Any]
            daily["precipitation_probability_max"] = [NSNull(), 40]
            json["daily"] = daily
        }

        let snapshot = try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: TestCities.moscow)

        XCTAssertEqual(snapshot.current.feelsLikeCelsius, snapshot.current.temperatureCelsius)
        XCTAssertEqual(snapshot.current.windGustsKmh, snapshot.current.windSpeedKmh)
        XCTAssertEqual(snapshot.current.uvIndex, 0)
        XCTAssertEqual(snapshot.daily.map(\.precipitationChancePercent), [0, 40])
    }

    func testMissingRequiredCurrentValueFails() throws {
        let data = try Fixtures.forecastData { json in
            var current = json["current"] as! [String: Any]
            current["temperature_2m"] = NSNull()
            json["current"] = current
        }

        XCTAssertThrowsError(try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: TestCities.moscow)) { error in
            XCTAssertEqual(error as? OpenMeteoMappingError, .missingValue("current.temperature_2m"))
        }
    }

    func testSeriesOfDifferentLengthsAreRejected() throws {
        let data = try Fixtures.forecastData { json in
            var daily = json["daily"] as! [String: Any]
            daily["sunset"] = [1_790_694_630]
            json["daily"] = daily
        }

        XCTAssertThrowsError(try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: TestCities.moscow)) { error in
            XCTAssertEqual(error as? OpenMeteoMappingError, .seriesLengthMismatch("daily"))
        }
    }

    func testPolarNightAndPolarDay() throws {
        let midnight: TimeInterval = 1_790_629_200
        let nextMidnight = midnight + 86_400
        let data = try Fixtures.forecastData { json in
            var daily = json["daily"] as! [String: Any]
            daily["sunrise"] = [midnight, nextMidnight]
            daily["sunset"] = [midnight, nextMidnight + 86_400]
            json["daily"] = daily
            var hourly = json["hourly"] as! [String: Any]
            hourly["is_day"] = Array(repeating: NSNull(), count: 48)
            json["hourly"] = hourly
        }

        let snapshot = try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: TestCities.moscow)

        XCTAssertTrue(snapshot.hourly.prefix(24).allSatisfy { !$0.isDaytime }, "polar night")
        XCTAssertTrue(snapshot.hourly.suffix(24).allSatisfy(\.isDaytime), "polar day")
    }

    // Timestamps as the API really returns them across a DST switch: one fixed offset for the whole range.
    func testDayDatesSnapToLocalMidnightAcrossDSTEnd() throws {
        let berlin = City(id: "2950159", name: "Berlin", region: "", country: "", latitude: 52.52, longitude: 13.41, timeZoneIdentifier: "Europe/Berlin")
        let snapshot = try snapshot(for: berlin, dailyTimes: [1_761_429_600, 1_761_516_000])

        XCTAssertEqual(snapshot.daily.map(\.date), [Date(timeIntervalSince1970: 1_761_429_600), Date(timeIntervalSince1970: 1_761_519_600)])
        XCTAssertEqual(Set(snapshot.daily.map { berlin.calendar.component(.day, from: $0.date) }), [26, 27])
    }

    func testDayDatesSnapToLocalMidnightAcrossDSTStart() throws {
        let sydney = City(id: "2147714", name: "Sydney", region: "", country: "", latitude: -33.87, longitude: 151.21, timeZoneIdentifier: "Australia/Sydney")
        let snapshot = try snapshot(for: sydney, dailyTimes: [1_791_036_000, 1_791_122_400])

        XCTAssertEqual(snapshot.daily.map(\.date), [Date(timeIntervalSince1970: 1_791_036_000), Date(timeIntervalSince1970: 1_791_118_800)])
    }

    private func snapshot(for city: City, dailyTimes: [TimeInterval]) throws -> CityWeatherSnapshot {
        let data = try Fixtures.forecastData { json in
            var daily = json["daily"] as! [String: Any]
            daily["time"] = dailyTimes
            json["daily"] = daily
        }
        return try OpenMeteoMapper.snapshot(from: decodeForecast(data), city: city)
    }

    func testWMOCodes() {
        let expected: [Int: WeatherCondition] = [
            0: .clearSky, 1: .mostlyClear, 2: .partlyCloudy, 3: .cloudy,
            45: .fog, 48: .fog,
            51: .drizzle, 55: .drizzle, 57: .drizzle,
            61: .rain, 65: .rain, 67: .rain,
            71: .snow, 75: .snow, 77: .snow, 85: .snow, 86: .snow,
            80: .rainShowers, 82: .rainShowers,
            95: .thunderstorm, 96: .thunderstorm, 99: .thunderstorm,
            58: .drizzle, 42: .fog, -1: .cloudy, 150: .cloudy
        ]
        for (code, condition) in expected {
            XCTAssertEqual(WeatherCondition(wmoCode: code), condition, "WMO \(code)")
        }
    }

    func testMapsRealGeocodingResponse() throws {
        let dto = try JSONDecoder().decode(OpenMeteoGeocodingDTO.self, from: Fixtures.geocodingData)
        let cities = OpenMeteoMapper.cities(from: dto)

        XCTAssertEqual(cities.count, 2)
        XCTAssertEqual(cities[0], City(id: "551487", name: "Казань", region: "Татарстан", country: "Россия", latitude: 55.78874, longitude: 49.12214, timeZoneIdentifier: "Europe/Moscow"))
        XCTAssertEqual(cities[1].timeZoneIdentifier, "Europe/Kirov")
    }

    func testEmptyGeocodingResponseHasNoResultsKey() throws {
        let dto = try JSONDecoder().decode(OpenMeteoGeocodingDTO.self, from: Data(Fixtures.emptyGeocodingJSON.utf8))
        XCTAssertEqual(OpenMeteoMapper.cities(from: dto), [])
    }

    func testGeocodingCleanup() throws {
        let data = try Fixtures.geocodingData(results: [
            ["id": 1, "name": "Москва", "latitude": 55.75, "longitude": 37.61, "timezone": "Europe/Moscow", "country": "Россия", "admin1": "Москва"],
            ["id": 1, "name": "Москва", "latitude": 55.75, "longitude": 37.61, "timezone": "Europe/Moscow"],
            ["id": 2, "name": "Nowhere", "latitude": 10, "longitude": 10],
            ["id": 3, "name": "Badzone", "latitude": 10, "longitude": 10, "timezone": "Mars/Base"],
            ["id": 4, "name": "Tiny", "latitude": 10, "longitude": 10, "timezone": "UTC", "country_code": "XX"]
        ])
        let cities = OpenMeteoMapper.cities(from: try JSONDecoder().decode(OpenMeteoGeocodingDTO.self, from: data))

        XCTAssertEqual(cities.map(\.id), ["1", "4"])
        XCTAssertEqual(cities[0].region, "", "admin1 equal to the name is dropped")
        XCTAssertEqual(cities[0].subtitle, "Россия")
        XCTAssertEqual(cities[1].country, "XX")
    }
}

final class OpenMeteoWeatherRepositoryTests: XCTestCase {
    func testSnapshotRequestsCityCoordinatesAndZone() async throws {
        let client = StubNetworkClient { _ in Fixtures.forecastData }
        let repository = OpenMeteoWeatherRepository(client: client)

        let snapshot = try await repository.snapshot(for: TestCities.kazan)

        XCTAssertEqual(snapshot.city, TestCities.kazan)
        let request = try XCTUnwrap(client.requests.first)
        XCTAssertEqual(request.queryValue("latitude"), "55.7887")
        XCTAssertEqual(request.queryValue("timezone"), "Europe/Moscow")
    }

    func testErrorsAreTranslatedToRepositoryErrors() async {
        await assertSnapshotThrows(.offline) { _ in throw NetworkError.notConnected }
        await assertSnapshotThrows(.serviceUnavailable) { _ in throw NetworkError.httpStatus(code: 500, message: nil) }
        await assertSnapshotThrows(.invalidData) { _ in throw NetworkError.decodingFailed("x") }
        await assertSnapshotThrows(.invalidData) { _ in
            try Fixtures.forecastData { json in
                var current = json["current"] as! [String: Any]
                current["weather_code"] = NSNull()
                json["current"] = current
            }
        }
    }

    func testSnapshotsKeepInputOrderUnderConcurrency() async throws {
        let cities = [TestCities.moscow, TestCities.kazan, TestCities.sochi, TestCities.moscow, TestCities.kazan]
        let client = StubNetworkClient { _ in Fixtures.forecastData }
        let repository = OpenMeteoWeatherRepository(client: client)

        let snapshots = try await repository.snapshots(for: cities)

        XCTAssertEqual(snapshots.map(\.city), cities)
        XCTAssertEqual(client.requests.count, cities.count)
    }

    func testSnapshotsSkipFailedCities() async throws {
        let client = StubNetworkClient { request in
            if request.queryValue("latitude") == "55.7887" { throw NetworkError.timedOut }
            return Fixtures.forecastData
        }
        let repository = OpenMeteoWeatherRepository(client: client)

        let snapshots = try await repository.snapshots(for: [TestCities.moscow, TestCities.kazan, TestCities.sochi])

        XCTAssertEqual(snapshots.map(\.city), [TestCities.moscow, TestCities.sochi])
    }

    func testSnapshotsThrowWhenEveryCityFails() async {
        let repository = OpenMeteoWeatherRepository(client: StubNetworkClient { _ in throw NetworkError.notConnected })

        do {
            _ = try await repository.snapshots(for: [TestCities.moscow, TestCities.kazan])
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .offline)
        }
    }

    func testSnapshotsOfNoCitiesMakeNoRequests() async throws {
        let client = StubNetworkClient { _ in Fixtures.forecastData }
        let snapshots = try await OpenMeteoWeatherRepository(client: client).snapshots(for: [])

        XCTAssertTrue(snapshots.isEmpty)
        XCTAssertTrue(client.requests.isEmpty)
    }

    private func assertSnapshotThrows(
        _ expected: RepositoryError,
        file: StaticString = #filePath,
        line: UInt = #line,
        handler: @escaping StubNetworkClient.Handler
    ) async {
        let repository = OpenMeteoWeatherRepository(client: StubNetworkClient(handler: handler))
        do {
            _ = try await repository.snapshot(for: TestCities.moscow)
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? RepositoryError, expected, file: file, line: line)
        }
    }
}

final class OpenMeteoGeocodingRepositoryTests: XCTestCase {
    func testShortQueriesDoNotHitTheNetwork() async throws {
        let client = StubNetworkClient { _ in Fixtures.geocodingData }
        let repository = OpenMeteoGeocodingRepository(client: client)

        let results = [
            try await repository.searchCities(matching: ""),
            try await repository.searchCities(matching: "   "),
            try await repository.searchCities(matching: " к ")
        ]

        XCTAssertTrue(results.allSatisfy(\.isEmpty))
        XCTAssertTrue(client.requests.isEmpty)
    }

    func testSingleWordQueryIsNormalisedAndSentOnce() async throws {
        let client = StubNetworkClient { _ in Fixtures.geocodingData }

        let cities = try await OpenMeteoGeocodingRepository(client: client).searchCities(matching: "  Казань\n")

        XCTAssertEqual(cities.first?.name, "Казань")
        XCTAssertEqual(client.requests.map { $0.queryValue("name") }, ["Казань"])
    }

    func testMultiWordQueryAlsoTriesHyphenatedSpelling() async throws {
        let rostov = ["id": 501175, "name": "Ростов-на-Дону", "latitude": 47.23, "longitude": 39.72, "timezone": "Europe/Moscow", "country": "Россия"] as [String: Any]
        let client = StubNetworkClient { request in
            request.queryValue("name") == "ростов-на-дону"
                ? try Fixtures.geocodingData(results: [rostov])
                : Data(Fixtures.emptyGeocodingJSON.utf8)
        }

        let cities = try await OpenMeteoGeocodingRepository(client: client).searchCities(matching: "ростов  на дону")

        XCTAssertEqual(cities.map(\.name), ["Ростов-на-Дону"])
        XCTAssertEqual(Set(client.requests.compactMap { $0.queryValue("name") }), ["ростов на дону", "ростов-на-дону"])
    }

    func testSpacedResultsComeFirstAndDuplicatesAreMerged() async throws {
        let client = StubNetworkClient { _ in Fixtures.geocodingData }

        let cities = try await OpenMeteoGeocodingRepository(client: client).searchCities(matching: "нижний новгород")

        XCTAssertEqual(cities.map(\.id), ["551487", "551485"])
    }

    func testOneFailedSpellingStillReturnsTheOther() async throws {
        let client = StubNetworkClient { request in
            if request.queryValue("name")?.contains("-") == true { throw NetworkError.timedOut }
            return Fixtures.geocodingData
        }

        let cities = try await OpenMeteoGeocodingRepository(client: client).searchCities(matching: "нижний новгород")

        XCTAssertEqual(cities.count, 2)
    }

    func testFailureIsTranslated() async {
        let repository = OpenMeteoGeocodingRepository(client: StubNetworkClient { _ in throw NetworkError.notConnected })

        do {
            _ = try await repository.searchCities(matching: "нижний новгород")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? RepositoryError, .offline)
        }
    }
}
