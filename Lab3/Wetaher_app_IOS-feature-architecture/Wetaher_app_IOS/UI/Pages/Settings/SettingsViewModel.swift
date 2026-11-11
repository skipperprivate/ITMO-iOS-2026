//
//  SettingsViewModel.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import Observation
import SwiftUI

@MainActor
@Observable
public class SettingsViewModel{
    private let weatherRepository: WeatherRepository
    
    public var appTheme: AppThemeProps
    
    init(weatherRepo: WeatherRepository) {
        self.weatherRepository = weatherRepo
        self.appTheme = .system
    }
    
}
