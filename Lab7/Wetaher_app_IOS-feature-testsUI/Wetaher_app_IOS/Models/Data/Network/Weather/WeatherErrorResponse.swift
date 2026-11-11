//
//  WeatherError.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

public struct WeatherErrorResponse: Error{
    let errorCode: Int
    let errorDescription: String
}
