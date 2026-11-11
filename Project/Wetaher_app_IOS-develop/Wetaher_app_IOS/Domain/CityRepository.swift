//
//  CityRepository.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 11.11.2026.
//

@MainActor
public protocol CityRepository {

    func SearchCities(query: String) async -> Result<[CityResponse], CityResponseError>

    // Сохранённые избранные города. При первом запуске список заполняется городами по умолчанию
    func LoadSavedCities() -> [CityEntity]

    // Добавляет город в избранное. Повторное добавление игнорируется
    func AddFavoriteCity(_ city: City)

    // Удаляет город из избранного и очищает его прогноз в БД
    func RemoveFavoriteCity(cityID: Int)

    // Идентификатор последнего просмотренного города
    func LoadActiveCityID() -> Int?

    // Запоминает последний просмотренный город
    func SetActiveCity(_ cityID: Int)
}
