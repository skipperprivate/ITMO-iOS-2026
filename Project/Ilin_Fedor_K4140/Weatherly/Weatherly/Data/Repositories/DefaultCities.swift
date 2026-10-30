//
//  DefaultCities.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// First-launch favourites until geolocation (stage 4). Exact GeoNames records as the
// Open-Meteo geocoder returns them (/v1/get?id=…), mapped like OpenMeteoMapper does,
// so a later search yields equal City values and the star shows them as already added.
nonisolated enum DefaultCities {
    static let moscow = City(
        id: "524901",
        name: "Москва",
        region: "",
        country: "Россия",
        latitude: 55.75204,
        longitude: 37.61781,
        timeZoneIdentifier: "Europe/Moscow"
    )

    static let saintPetersburg = City(
        id: "498817",
        name: "Санкт-Петербург",
        region: "",
        country: "Россия",
        latitude: 59.93863,
        longitude: 30.31413,
        timeZoneIdentifier: "Europe/Moscow"
    )

    static let sochi = City(
        id: "491422",
        name: "Сочи",
        region: "Краснодарский край",
        country: "Россия",
        latitude: 43.59699,
        longitude: 39.72477,
        timeZoneIdentifier: "Europe/Moscow"
    )

    static let all: [City] = [moscow, saintPetersburg, sochi]
}
