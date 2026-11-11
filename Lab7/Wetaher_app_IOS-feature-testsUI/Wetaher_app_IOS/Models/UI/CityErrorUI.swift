//
//  CityErrorUI.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 21.10.2026.
//

public struct CityErrorUI: Equatable, Hashable, Error {
    public let errorId: Int
    public let errorDescription: String
    public let reserveCities: [City]
}
