//
//  HairTypeRequest.swift
//  curl-ios
//
//  Created by Nadineenik on 02.10.2026.
//

import Foundation

struct HairTypeRequest: Codable{
    let userId: String
    let porosity: String?
    let isColored: Bool?
    let thickness: String?
}
