//
//  NetworkClient.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 15.10.2026.
//
import Foundation

public class NetworkClient {

    public init () {

    }

    func getCityWeather(city: City)async -> Result<WeatherResponse, WeatherErrorResponse> {

        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(city.latitude)&longitude=\(city.longitude)&hourly=temperature_2m,weather_code,is_day,precipitation_probability&current=temperature_2m,apparent_temperature,weather_code,is_day,wind_speed_10m,wind_direction_10m,wind_gusts_10m,relative_humidity_2m,dew_point_2m,pressure_msl,visibility&daily=temperature_2m_max,temperature_2m_min,weather_code,uv_index_max,sunrise,sunset,precipitation_probability_mean") else {
            return .failure(WeatherErrorResponse(errorCode: 13, errorDescription: "Ошибка конвертации URL-запроса"))
        } // "52.52""13.41"

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(WeatherErrorResponse(errorCode: -1, errorDescription: "Некорректный HTTP-ответ"))
            }
            let statusCode = httpResponse.statusCode

            guard (200...299).contains(statusCode)
            else {
                let standardDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                // let bodyDescription = String(data: data, encoding: .utf8)

                return .failure(WeatherErrorResponse(
                    errorCode: statusCode,
                    errorDescription: "Ошибка сервера: HTTP \(statusCode) \(standardDescription)"
                ))
            }

            print(String(data: data, encoding: .utf8) ?? "No data")

            let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return .success(weather)
        }
        catch {
            return .failure(WeatherErrorResponse(errorCode: 600, errorDescription: "\(error)"))
        }
    }

    func getCityLatLongByName(cityName: String, isLatinName: Bool) async -> Result<PossibleCitiesResponse, CityResponseError> {

        var language = (isLatinName == true) ? "en": "ru"

        guard let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(cityName)&count=3&language=\(language)&format=json")
                else {
            return .failure(CityResponseError(errorId: 13, errorDescription: "Ошибка конвертации URL-запроса"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            do {
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(CityResponseError(errorId: -1, errorDescription: "Некорректный HTTP-ответ"))
                }
                let statusCode = httpResponse.statusCode

                guard (200...299).contains(statusCode)
                        else {
                    let standardDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    // let bodyDescription = String(data: data, encoding: .utf8)

                    return .failure(CityResponseError(
                        errorId: statusCode,
                        errorDescription: "Ошибка сервера: HTTP \(statusCode) \(standardDescription)"
                    ))
                }

                print(String(data: data, encoding: .utf8) ?? "No data")

                let cities = try JSONDecoder().decode(PossibleCitiesResponse.self, from: data)
                return .success(cities)
            } catch {
                // Case when decoding failed because city wasn't found
                do {
                    let noCities = try JSONDecoder().decode(NoCitiesResponse.self, from: data)

                    return .failure(CityResponseError(errorId: 604, errorDescription: "Не удалось обнаружить такой город в нашей базе"))
                }catch {

                    // Case when there is some parcing error
                    return .failure(CityResponseError(errorId: 600, errorDescription: "\(error)"))
                }

            }
        }catch {
            return .failure(CityResponseError(errorId: 700, errorDescription: "Не получилось установить соединение с сервером спустя 1000мс."))
        }
    }

}
