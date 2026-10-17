//
//  GeneratorViewModel.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 24.09.

import Foundation

final class GenerateNumberViewModel: ObservableObject {
    @Published private var model = GeneratedNumber()
    
    private let userDefaults = UserDefaultsService.shared
    private let persistence = PersistenceController.shared
    
    var numberText: String {
        guard let value = model.value else { return "--" }
        return "\(value)"
    }
    
    init() {
        if let saved = userDefaults.lastRandomNumber {
            model.value = saved
        }
    }
    
    func generateButtonTapped() {
        model.generate()
        
        guard let newValue = model.value else { return }
        
        userDefaults.lastRandomNumber = newValue
        saveToCoreData(value: newValue)
    }
    
    private func saveToCoreData(value: Int) {
        let context = persistence.container.viewContext
        let record = NumberRecord(context: context)
        record.id = UUID()
        record.value = Int64(value)
        record.date = Date()
        persistence.save()
    }
}
