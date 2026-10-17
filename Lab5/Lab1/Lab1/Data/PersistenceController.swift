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
    
    func save(value: Int) async {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        await context.perform {
            let record = NumberRecord(context: context)
            record.id = UUID()
            record.value = Int64(value)
            record.date = Date()
        
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func fetch() async -> [NumberRecord] {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return await context.perform {
            let request = NumberRecord.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \NumberRecord.date, ascending: false)
            ]
            
            do {
                let records = try context.fetch(request)
                
                return records.map {
                    self.container.viewContext.object(with: $0.objectID) as! NumberRecord
                }
            } catch {
                print("Fetch error: \(error)")
                return []
            }
        }
    }
    
    func deleteAll() async {
        let context = container.newBackgroundContext()
        await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = NumberRecord.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let ids = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: [NSDeletedObjectsKey: ids],
                        into: [self.container.viewContext]
                    )
                }
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}
