//
//  WeatherErrorEntityMapper.swift
//  Wetaher_app_IOS
//
//  Created by Sergeev Sergey on 27.10.2026.
//

extension WeatherErrorEntity{
    /// Entity → UI.
    func ToUI() -> WeatherErrorUI{
        WeatherErrorUI(
            errorCode: errorCode,
            errorDescription: errorDescription
        )
    }
}
