//
//  QuoteEntity+CoreDataClass.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 08.10.2026.
//
//

import Foundation
import CoreData

@objc(QuoteEntity)
public final class QuoteEntity: NSManagedObject {
    @NSManaged public var id: Int64
    @NSManaged public var content: String
    @NSManaged public var author: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var createdAt: Date
}

extension QuoteEntity {
    func toDomain() -> Quote {
        Quote(id: Int(id), content: content, author: author)
    }
    
    @discardableResult
    static func from(domain quote: Quote,
                     context: NSManagedObjectContext,
                     isFavorite: Bool = true) -> QuoteEntity {
        let entity = QuoteEntity(context: context)
        entity.id = Int64(quote.id)
        entity.content = quote.content
        entity.author = quote.author
        entity.isFavorite = isFavorite
        entity.createdAt = Date()
        return entity
    }
}
