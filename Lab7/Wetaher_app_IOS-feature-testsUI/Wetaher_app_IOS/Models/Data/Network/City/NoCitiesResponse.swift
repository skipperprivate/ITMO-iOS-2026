//
//  NoCitiesResponse.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

public struct NoCitiesResponse: Codable{
    public let generationtime: Double
    
    enum CodingKeys: String, CodingKey {
            case generationtime = "generationtime_ms"
        }
}
