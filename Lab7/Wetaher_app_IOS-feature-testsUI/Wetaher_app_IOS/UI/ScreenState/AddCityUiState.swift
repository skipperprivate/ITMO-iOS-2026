//
//  AddCityUiState.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 21.10.2026.
//

public enum AddCityUIState: Equatable, Hashable {
    case Loading
    case Success([City])
    case Fail(CityErrorUI)
    case Search
}
