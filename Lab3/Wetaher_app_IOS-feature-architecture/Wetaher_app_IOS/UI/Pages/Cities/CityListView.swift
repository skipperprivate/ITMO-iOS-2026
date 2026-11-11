//
//  CityListView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

struct CityListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var savedCitiesWeather: [ForecastUI] = []
    var savedCitiesWeatherError: [String : WeatherErrorUI] = [:]
    
    var cityListWeatherUIState: CityListUIState
    var searchQuery: String
    var searchResults: [City] = []
    
    public var onSelectCity: (City) -> Void
    public var onDeleteCity: (IndexSet) -> Void
    public var onCityAdd: (City) -> Void
    public var isCitySaved: (City) -> Bool
    
    init(savedCitiesWeather: [ForecastUI], savedCitiesWeatherError: [String : WeatherErrorUI], cityListWeatherUIState: CityListUIState, searchQuery: String, searchResults: [City], onSelectCity: @escaping (City) -> Void, onDeleteCity: @escaping (IndexSet) -> Void,
         onCityAdd: @escaping (City) -> Void, isCitySaved: @escaping (City) -> Bool) {
        self.savedCitiesWeather = savedCitiesWeather
        self.savedCitiesWeatherError = savedCitiesWeatherError
        self.cityListWeatherUIState = cityListWeatherUIState
        self.searchQuery = searchQuery
        self.searchResults = searchResults
        self.onSelectCity = onSelectCity
        self.onDeleteCity = onDeleteCity
        self.onCityAdd = onCityAdd
        self.isCitySaved = isCitySaved
    }
    
    var body: some View {
        switch cityListWeatherUIState{
        case .Loading:
            Text("Loading")
        case .Fail:
            Text("City list page: Fail on load")
        case .Success:
            Text("Success")
            Text("\(savedCitiesWeather[0].city.name) " + "\(savedCitiesWeather[0].currentWeather.temperature)")
            if(savedCitiesWeather.count > 1){
                Text("\(savedCitiesWeather[1].city.name) " + "\(savedCitiesWeather[1].currentWeather.temperature)")
            }
        case .Search:
            Text("Search activated")
        }
    }
}
