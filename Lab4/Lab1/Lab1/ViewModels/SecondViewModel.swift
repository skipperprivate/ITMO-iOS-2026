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
    
    private let persistence = PersistenceController.shared
    
    func load() {
        let request: NSFetchRequest<NumberRecord> = NumberRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NumberRecord.date, ascending: false)]
        
        do {
            records = try persistence.container.viewContext.fetch(request)
        } catch {
            print("Error: \(error)")
            records = []
        }
    }
    
    func deleteAll() {
        let context = persistence.container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NumberRecord.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            records = []
        } catch {
            print("Delete error: \(error)")
        }
    }
}
