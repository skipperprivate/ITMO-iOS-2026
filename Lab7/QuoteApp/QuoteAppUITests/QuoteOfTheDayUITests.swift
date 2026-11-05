//
//  QuoteOfTheDayUITests.swift
//  QuoteAppUITests
//
//  Created by Кирилл Матвеев on 22.10.2026.
//

import XCTest

final class QuoteOfTheDayUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }
    
    func test_mainScreen_elementsExist() {
        let quoteText = app.staticTexts["quote_text"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 10))
        
        XCTAssertTrue(app.buttons["favorite_button"].exists)
        XCTAssertTrue(app.buttons["share_button"].exists)
        XCTAssertTrue(app.buttons["refresh_button"].exists)
    }
    
    func test_refreshButton() {
        let quoteText = app.staticTexts["quote_text"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 10))
        
        let initialText = quoteText.label
        
        let refreshButton = app.buttons["refresh_button"]
        XCTAssertTrue(refreshButton.isHittable)
        refreshButton.tap()
        
        let predicate = NSPredicate(format: "label != %@", initialText)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: quoteText)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 10.0)
        
        XCTAssertEqual(result, .completed)
    }
    
    func test_favoriteButton_toggleState() {
        let quoteText = app.staticTexts["quote_text"]
        XCTAssertTrue(quoteText.waitForExistence(timeout: 10))
        
        let favoriteButton = app.buttons["favorite_button"]
        XCTAssertTrue(favoriteButton.exists)
        
        let initialState = favoriteButton.value as? String
        XCTAssertNotNil(initialState)
        
        favoriteButton.tap()
        
        let predicate = NSPredicate(format: "value !=%@", initialState!)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: favoriteButton)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed)
        
        let newState = favoriteButton.value as? String
        XCTAssertNotEqual(initialState, newState)
        
        if initialState == "Not liked" {
            XCTAssertEqual(newState, "Liked")
        } else {
            XCTAssertEqual(newState, "Not liked")
        }
    }
}
