//
//  MenuPlannerApp.swift
//  MenuPlanner
//
//  Created by FergeS on 21.10.2026.
//

import SwiftUI
import SwiftData

@main
struct MenuPlannerApp: App {
    @State private var userSettings = UserSettings()
    
    var body: some Scene {
        
        WindowGroup {
            Text("Menu Planner")
        }.modelContainer(for: AppSchema.models)
    }
}
