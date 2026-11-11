//
//  TestChecker.swift
//  Wetaher_app_IOS
//
//  Created by Roman Zyuzin on 29.10.2026.
//
import Foundation

public struct TestChecker {

    public static var isRunningTests: Bool {
        get {
            return NSClassFromString("XCTest") != nil
        }
    }

}
