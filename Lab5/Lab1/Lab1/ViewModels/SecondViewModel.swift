//
//  SecondViewModel.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import Foundation
import CoreData

@MainActor
class SecondViewModel: ObservableObject {
    @Published var records: [NumberRecord] = []
    @Published var isLoading: Bool = false
    
    private let persistence = PersistenceController.shared
    
    func load() {
        Task {
            isLoading = true
            let fetched = await persistence.fetch()
            self.records = fetched
            isLoading = false
        }
    }
    
    func deleteAll() {
        Task {
            await persistence.deleteAll()
            self.records = []
        }
    }
}
