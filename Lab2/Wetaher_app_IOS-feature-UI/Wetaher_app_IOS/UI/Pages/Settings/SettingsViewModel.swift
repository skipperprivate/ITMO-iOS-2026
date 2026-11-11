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
public class SettingsViewModel {
    private let weatherRepository: WeatherRepository
    private static let themeStorageKey = "selected_app_theme"

    public var appTheme: AppThemeProps {
        didSet {
            UserDefaults.standard.set(appTheme.id, forKey: Self.themeStorageKey)
        }
    }

    public init(weatherRepo: WeatherRepository) {
        self.weatherRepository = weatherRepo
        let savedId = UserDefaults.standard.string(forKey: Self.themeStorageKey)
        self.appTheme = AppThemeProps.from(id: savedId)
    }
}
