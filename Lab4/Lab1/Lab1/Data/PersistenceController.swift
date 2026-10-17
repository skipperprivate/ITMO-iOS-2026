//
//  PersistenceController.swift
//  Lab1
//
//  Created by Кирилл Матвеев on 01.10.2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NumberRecord")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
            
        } catch {
            print("Save error: \(error)")
        }
        
    }
}
