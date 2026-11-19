//
//  AppFonts.swift
//  MenuPlanner
//
//  Created by FergeS on 31/10/2026.
//
import SwiftUI

enum AppFonts {
    static let display = Font.custom("Onest-SemiBold", fixedSize: 34)

    static let title = Font.custom("Onest-SemiBold", fixedSize: 28)

    static let section = Font.custom("Onest-SemiBold", fixedSize: 20)

    static let card = Font.custom("Onest-Medium", fixedSize: 17)

    static let body = Font.system(size: 16, weight: .regular)
    static let strong = Font.system(size: 16, weight: .semibold)

    static let small = Font.system(size: 13, weight: .regular)
    static let smallStrong = Font.system(size: 13, weight: .semibold)

    static let micro = Font.system(size: 11, weight: .medium)
}
