//
//  SettingsView.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 02.10.2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var currentColorScheme: ColorScheme?
    
    let onColorThemeChange: (AppThemeProps) -> Void

    init(currentColorScheme: ColorScheme?, onColorThemeChange: @escaping (AppThemeProps) -> Void) {
        self.currentColorScheme = currentColorScheme
        self.onColorThemeChange = onColorThemeChange
    }
    
    var body: some View {
        Text("Settings page")
    }
}
