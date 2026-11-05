//
//  QuoteEntity+CoreDataProperties.swift
//  QuoteApp
//
//  Created by Кирилл Матвеев on 08.10.2026.
//
//

import Foundation
import CoreData


extension QuoteEntity : Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteEntity> {
        NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
    }
}
