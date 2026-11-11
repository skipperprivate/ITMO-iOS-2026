//
//  CityUIHelper.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 18.10.2026.
//

import Foundation

public enum CityUIHelper{
    
    public static func localTime(timeZone: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        if let timeZone = TimeZone(identifier: timeZone) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: Date())
    }
}
