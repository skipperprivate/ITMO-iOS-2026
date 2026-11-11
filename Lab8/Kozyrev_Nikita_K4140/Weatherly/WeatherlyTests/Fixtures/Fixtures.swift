//
//  Fixtures.swift
//  WeatherlyTests
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import Foundation

// Real Open-Meteo responses captured with curl on 29.09.2026 (Moscow, forecast_days=2).
enum Fixtures {
    static let forecastJSON = #"""
{"latitude":55.75,"longitude":37.625,"generationtime_ms":0.37038326263427734,"utc_offset_seconds":10800,"timezone":"Europe/Moscow","timezone_abbreviation":"GMT+3","elevation":151.0,"current_units":{"time":"unixtime","interval":"seconds","temperature_2m":"°C","apparent_temperature":"°C","weather_code":"wmo code","is_day":"","wind_speed_10m":"km/h","wind_gusts_10m":"km/h","wind_direction_10m":"°","relative_humidity_2m":"%","pressure_msl":"hPa","uv_index":"","visibility":"m"},"current":{"time":1790702100,"interval":900,"temperature_2m":11.1,"apparent_temperature":9.8,"weather_code":3,"is_day":0,"wind_speed_10m":2.1,"wind_gusts_10m":4.3,"wind_direction_10m":329,"relative_humidity_2m":72,"pressure_msl":1032.8,"uv_index":0.0,"visibility":39320.0},"hourly_units":{"time":"unixtime","temperature_2m":"°C","weather_code":"wmo code","is_day":"","precipitation_probability":"%"},"hourly":{"time":[1790629200,1790632800,1790636400,1790640000,1790643600,1790647200,1790650800,1790654400,1790658000,1790661600,1790665200,1790668800,1790672400,1790676000,1790679600,1790683200,1790686800,1790690400,1790694000,1790697600,1790701200,1790704800,1790708400,1790712000,1790715600,1790719200,1790722800,1790726400,1790730000,1790733600,1790737200,1790740800,1790744400,1790748000,1790751600,1790755200,1790758800,1790762400,1790766000,1790769600,1790773200,1790776800,1790780400,1790784000,1790787600,1790791200,1790794800,1790798400],"temperature_2m":[7.9,7.6,7.2,6.8,6.5,6.1,5.3,5.4,5.7,7.1,8.8,10.4,12.9,13.8,14.7,15.4,15.3,14.6,13.2,12.0,11.2,10.6,10.1,9.6,9.4,9.0,8.4,7.9,7.6,7.2,6.8,6.7,7.4,9.0,11.0,12.9,14.6,15.9,16.4,16.5,16.3,15.7,14.4,13.3,12.5,12.1,11.3,10.5],"weather_code":[0,1,1,1,1,45,45,3,3,3,3,2,2,2,2,3,0,0,0,0,0,3,3,2,3,3,2,1,1,0,0,0,1,2,2,1,0,1,1,1,1,2,1,1,2,2,0,1],"is_day":[0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0],"precipitation_probability":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},"daily_units":{"time":"unixtime","weather_code":"wmo code","temperature_2m_max":"°C","temperature_2m_min":"°C","precipitation_probability_max":"%","precipitation_sum":"mm","wind_speed_10m_max":"km/h","uv_index_max":"","sunrise":"unixtime","sunset":"unixtime"},"daily":{"time":[1790629200,1790715600],"weather_code":[45,3],"temperature_2m_max":[15.4,16.5],"temperature_2m_min":[5.3,6.7],"precipitation_probability_max":[0,0],"precipitation_sum":[0.0,0.0],"wind_speed_10m_max":[6.8,8.0],"uv_index_max":[3.1,3.05],"sunrise":[1790652484,1790739002],"sunset":[1790694630,1790780871]}}
"""#

    static let geocodingJSON = #"""
{"results":[{"id":551487,"name":"Казань","latitude":55.78874,"longitude":49.12214,"elevation":61.0,"feature_code":"PPLA","country_code":"RU","admin1_id":484048,"admin2_id":862913,"timezone":"Europe/Moscow","population":1243500,"country_id":2017370,"country":"Россия","admin1":"Татарстан","admin2":"Gorodskoy Okrug Kazan’"},{"id":551485,"name":"Казань","latitude":59.16483,"longitude":49.93195,"elevation":168.0,"feature_code":"PPL","country_code":"RU","admin1_id":548389,"timezone":"Europe/Kirov","country_id":2017370,"country":"Россия","admin1":"Кировская Область"}],"generationtime_ms":1.3160706}
"""#

    static let emptyGeocodingJSON = #"{"generationtime_ms":0.12}"#

    static let errorJSON = #"{"error":true,"reason":"Latitude must be in range of -90 to 90°. Given: 200.0."}"#

    static var forecastData: Data { Data(forecastJSON.utf8) }
    // Shortly after the fixture's "current" time.
    static let fetchedAt = Date(timeIntervalSince1970: 1_790_702_200)
    static var geocodingData: Data { Data(geocodingJSON.utf8) }

    // Patches the forecast fixture, e.g. to put nulls where the API may return them.
    static func forecastData(_ patch: (inout [String: Any]) -> Void) throws -> Data {
        var object = try JSONSerialization.jsonObject(with: forecastData) as! [String: Any]
        patch(&object)
        return try JSONSerialization.data(withJSONObject: object)
    }

    static func geocodingData(results: [[String: Any]]) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["results": results])
    }
}
