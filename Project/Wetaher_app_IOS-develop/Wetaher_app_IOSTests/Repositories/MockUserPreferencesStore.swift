//
//  MockUserPreferencesStore.swift
//  Wetaher_app_IOSTests
//
//  Created by Sergeev Sergey on 27.10.2026.
//

@testable import Wetaher_app_IOS

// Хранилище настроек в памяти: тесты не пишут в `UserDefaults` и не влияют друг на друга
public final class MockUserPreferencesStore: UserPreferencesStoring {
    public var activeCityID: Int?
    public var favoriteCities: [CityEntity]
    public var themeID: String?

    public init(
        activeCityID: Int? = nil,
        favoriteCities: [CityEntity] = [],
        themeID: String? = nil
    ) {
        self.activeCityID = activeCityID
        self.favoriteCities = favoriteCities
        self.themeID = themeID
    }
}
