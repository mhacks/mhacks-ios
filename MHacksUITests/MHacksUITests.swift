//
//  MHacksUITests.swift
//  MHacksUITests
//
//  Created by Connor Krupp on 9/14/17.
//  Copyright © 2017 MHacks. All rights reserved.
//

import XCTest

class MHacksUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func takeScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCUIDevice.shared().orientation = .portrait
        
        let tabBarsQuery = XCUIApplication().tabBars

        // Events
        tabBarsQuery.buttons.element(boundBy: 0).tap()
        
        // Map
        tabBarsQuery.buttons.element(boundBy: 1).tap()
        
        // Countdown
        tabBarsQuery.buttons.element(boundBy: 2).tap()
    }
    
    func screenshot() {
        // create graphics context with screen size
        let screenRect = UIScreen.main.bounds
        UIGraphicsBeginImageContext(screenRect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        UIColor.black.set()
        context.fill(screenRect)
        
        let window = UIApplication.shared.keyWindow
        window?.layer.render(in: context)
        let screenImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        if let image = screenImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
}
