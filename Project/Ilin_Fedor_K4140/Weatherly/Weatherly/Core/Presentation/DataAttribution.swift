//
//  DataAttribution.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation

// Open-Meteo data is CC BY 4.0: a credit link must sit next to the shown data.
enum DataAttribution {
    static let title = "Данные: Open-Meteo.com"
    static let license = "CC BY 4.0"
    // Constant literal: parsing cannot fail.
    static let url = URL(string: "https://open-meteo.com/")!
}
