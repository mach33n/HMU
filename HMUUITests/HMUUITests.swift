//
//  HMUUITests.swift
//  HMUUITests
//
//  Created by Cameron Bennett on 10/26/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import XCTest

class HMUUITests: XCTestCase {
  
  var app: XCUIApplication!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
      continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
      app = XCUIApplication()
      app.isAccessibilityElement = false

        // reset state
      let defaultsName = Bundle.main.bundleIdentifier!
      UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() {
      app.launch()
      
      XCTAssertTrue(app.buttons["LOG IN"].exists)
      
      app.otherElements["InputView"].textFields["logInInput"].tap()
      app.otherElements["InputView"].textFields["logInInput"].typeText("Here")
      app.otherElements["PassINPUT"].secureTextFields["logInInput"].tap()
      app.otherElements["PassINPUT"].secureTextFields["logInInput"].typeText("HereHere")

      app.buttons["LOG IN"].tap()
      sleep(5)
      XCTAssertFalse(app.buttons["LOG IN"].exists)
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
extension XCUIApplication {
    var isDisplayingLogin: Bool {
      return otherElements["logo"].exists
    }
}
