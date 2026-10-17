//
//  Lab1App.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 17.09.2026.
//

import SwiftUI

@main
struct Lab1App: App {
    let persistence = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FirstView()
            }
            .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
