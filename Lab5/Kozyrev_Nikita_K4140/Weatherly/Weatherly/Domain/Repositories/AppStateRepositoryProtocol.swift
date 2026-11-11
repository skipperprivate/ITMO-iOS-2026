//
//  AppStateRepositoryProtocol.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 03.10.2026.
//

import Foundation

// Small UI state restored on launch; synchronous, since the first frame already needs it.
nonisolated protocol AppStateRepositoryProtocol: Sendable {
    func loadSelectedCityID() -> City.ID?
    func saveSelectedCityID(_ id: City.ID?)
}
