//
//  AppTheme.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 05.10.2026.
//

import Foundation
import SwiftUI

public struct AppThemeProps: Equatable, Hashable {
    public let title: String
    public let colorScheme: ColorScheme?
}

extension AppThemeProps {
    public static let system = AppThemeProps(
        title: "Системная", colorScheme: .none)

    public static let light = AppThemeProps(
        title: "Светлая", colorScheme: .light)

    public static let dark = AppThemeProps(
        title: "Тёмная", colorScheme: .dark)

    public static let allCases: [AppThemeProps] = [.system, .light, .dark]
}
