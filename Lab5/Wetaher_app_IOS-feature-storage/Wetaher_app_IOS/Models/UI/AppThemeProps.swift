//
//  AppTheme.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 05.10.2026.
//

import SwiftUI

public struct AppThemeProps: Equatable, Hashable {
    public let id: String
    public let title: String
    public let colorScheme: ColorScheme?
}

extension AppThemeProps{
    public static let system = AppThemeProps(
        id: "system",
        title: "Системная",
        colorScheme: nil
    )
    
    public static let light = AppThemeProps(
        id: "light",
        title: "Светлая",
        colorScheme: .light
    )
    
    public static let dark = AppThemeProps(
        id: "dark",
        title: "Тёмная",
        colorScheme: .dark
    )
    
    public static let allCases: [AppThemeProps] = [.system, .light, .dark]
    
    public static func from(id: String?) -> AppThemeProps {
        allCases.first { $0.id == id } ?? .system
    }
}
