//
//  CityResponseError.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 17.10.2026.
//

public struct CityResponseError: Error {
    public let errorId: Int
    public let errorDescription: String
    public var reserveCities: [City] = City.avaliableCities
}
