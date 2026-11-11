//
//  Item.swift
//  curl-ios
//
//  Created by ITMO.coworking on 02.10.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
