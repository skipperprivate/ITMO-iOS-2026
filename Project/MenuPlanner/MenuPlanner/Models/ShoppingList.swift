//
//  ShoppingList.swift
//  MenuPlanner
//
//  Created by FergeS on 28/10/2026.
//
import SwiftData
import Foundation

@Model
final class ShoppingList {
    private(set) var id: UUID
    var weekStart: Date
    
    @Relationship(deleteRule: .cascade)
    var items: [ShoppingItem]
    
    init(
        id: UUID = UUID(),
        weekStart: Date,
        items: [ShoppingItem] = []
    ) {
        self.id = id
        self.weekStart = weekStart
        self.items = items
    }
}
