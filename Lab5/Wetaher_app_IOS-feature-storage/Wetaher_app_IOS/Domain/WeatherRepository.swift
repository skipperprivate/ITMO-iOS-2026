//
//  WeatherRepository.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

@MainActor
public protocol WeatherRepository {
    /// Возвращает актуальные данные из сети или последний сохранённый снимок из БД.
    func GetWeatherForSelectedCity(for city: City) async -> Result<WeatherSnapshot, WeatherErrorResponse>

    func SearchCities(query: String) async -> Result<[CityResponse], CityResponseError>
}
