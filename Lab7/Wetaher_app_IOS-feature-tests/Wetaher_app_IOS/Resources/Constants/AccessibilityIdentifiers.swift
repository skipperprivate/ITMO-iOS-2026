//
//  AccessibilityIdentifiers.swift
//  Wetaher_app_IOS
//

import Foundation

public enum AccessibilityIdentifiers {
    public enum Main {
        public static let settingsButton = "main_settings_button"
        public static let cityListButton = "main_city_list_button"
        public static let cityTitle = "main_current_city_title"
        public static let temperature = "main_current_temperature"
        public static let condition = "main_current_condition"
        public static let feelsLike = "main_current_feels_like"
        public static let scrollView = "main_weather_scroll_view"
    }

    public enum Metrics {
        public static let wind = "metric_card_wind"
        public static let pressure = "metric_card_pressure"
        public static let humidity = "metric_card_humidity"
        public static let uv = "metric_card_uv"
        public static let sun = "metric_card_sun"
        public static let visibility = "metric_card_visibility"
    }

    public enum Settings {
        public static let themePicker = "settings_theme_picker"
        public static let doneButton = "settings_done_button"
    }

    public enum CityList {
        public static let addButton = "city_list_add_button"
        public static let doneButton = "city_list_done_button"
        public static func cityCard(_ cityName: String) -> String {
            return "city_card_\(cityName)"
        }
    }

    public enum AddCity {
        public static let searchField = "add_city_search_field"
        public static let doneButton = "add_city_done_button"
        public static func resultRow(_ cityName: String) -> String {
            return "add_city_row_\(cityName)"
        }
        public static func toggleButton(_ cityName: String) -> String {
            return "add_city_toggle_\(cityName)"
        }
    }
}
