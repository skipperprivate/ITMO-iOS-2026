//
//  CityErrorResponseMapper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 21.10.2026.
//

extension CityResponseError {
    func toUI() -> CityErrorUI {
        CityErrorUI(
            errorId: errorId,
            errorDescription: errorDescription,
            reserveCities: reserveCities
        )
    }
 }
