//
//  WeatherErrorUI.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 03.10.2026.
//

public struct WeatherErrorUI: Equatable, Hashable, Error{
    let errorCode: Int
    let errorDescription: String
}
