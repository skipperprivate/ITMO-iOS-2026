//
//  Typography.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 27.09.2026.
//

import SwiftUI
import UIKit
import CoreText

// Carlito ships only Regular and Bold, so tokens pick one explicitly instead of .weight().
enum AppFont {
    static let regularName = "Carlito-Regular"
    static let boldName = "Carlito-Bold"

    // Registered in code: the generated Info.plist has no UIAppFonts entry.
    static func register() {
        for name in [regularName, boldName] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
        if let title = UIFont(name: boldName, size: 19), let largeTitle = UIFont(name: boldName, size: 36) {
            UINavigationBar.appearance().titleTextAttributes = [.font: title]
            UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitle]
        }
    }

    static func regular(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(regularName, size: size, relativeTo: style)
    }

    static func bold(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(boldName, size: size, relativeTo: style)
    }
}

// Carlito has a small x-height, so sizes sit a notch above SF.
extension Font {
    static let wxHero = AppFont.bold(112, relativeTo: .largeTitle)
    static let wxDisplay = AppFont.bold(76, relativeTo: .largeTitle)
    static let wxDisplaySecondary = AppFont.bold(48, relativeTo: .largeTitle)
    static let wxValue = AppFont.bold(34, relativeTo: .title)
    static let wxTitle = AppFont.bold(30, relativeTo: .title)
    static let wxTitle2 = AppFont.bold(25, relativeTo: .title2)
    static let wxTitle3 = AppFont.bold(22, relativeTo: .title3)
    static let wxTitle3Regular = AppFont.regular(22, relativeTo: .title3)
    static let wxHeadline = AppFont.bold(18, relativeTo: .headline)
    static let wxBody = AppFont.regular(18, relativeTo: .body)
    static let wxBodyBold = AppFont.bold(18, relativeTo: .body)
    static let wxSubheadline = AppFont.regular(16, relativeTo: .subheadline)
    static let wxSubheadlineBold = AppFont.bold(16, relativeTo: .subheadline)
    static let wxCaption = AppFont.regular(14, relativeTo: .caption)
    static let wxCaptionBold = AppFont.bold(14, relativeTo: .caption)
    static let wxMicro = AppFont.bold(12.5, relativeTo: .caption2)
}
