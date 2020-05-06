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
  
  // Make Login UI Tests

    func testLogin() {
      app.launch()
      
      XCTAssertTrue(app.buttons["LOG IN"].exists)
      
      app.otherElements["InputView"].textFields["logInInput"].tap()
      
      app.otherElements["InputView"].textFields["logInInput"].typeText("Here")
      
      app.otherElements["PassINPUT"].secureTextFields["logInInput"].tap()
      
      app.otherElements["PassINPUT"].secureTextFields["logInInput"].typeText("HereHere")
      
      sleep(10)
      
      app.buttons["LOG IN"].tap()
      
      sleep(10)
      
      XCTAssertFalse(app.buttons["LOG IN"].exists)
    }
  
    func testSignUp() {
      app.launch()
      
      app.buttons["SIGN UP"].tap()
      
      XCTAssertTrue(app.buttons["SIGN UP"].exists)
      
      app.otherElements["SignInputView"].textFields["logInInput"].tap()
      
      app.otherElements["SignInputView"].textFields["logInInput"].typeText("Here")
      
      app.otherElements["SignPassINPUT"].secureTextFields["logInInput"].tap()
      
      app.otherElements["SignPassINPUT"].secureTextFields["logInInput"].typeText("HereHere")
      
      app.otherElements["ConfirmPassINPUT"].secureTextFields["logInInput"].tap()
      
      app.otherElements["ConfirmPassINPUT"].secureTextFields["logInInput"].typeText("HereHere")
      
      sleep(10)
      
      app.buttons["SIGN UP"].tap()
      
      sleep(10)
      
      let contactTable = app.tables.firstMatch
      var cell = contactTable.cells.allElementsBoundByIndex[1]
      cell.tap()
      
      cell = contactTable.cells.allElementsBoundByIndex[3]
      cell.tap()
      
      let rightNavBar = app.navigationBars.children(matching: .button).allElementsBoundByIndex[1]
      rightNavBar.tap()
      
      sleep(15)
      
      XCTAssertFalse(app.buttons["SIGN UP"].exists)
    }
  
    func testOpenBackView() {
      
      let app = XCUIApplication()
      app/*@START_MENU_TOKEN@*/.otherElements["InputView"]/*[[".otherElements[\"logo\"].otherElements[\"InputView\"]",".otherElements[\"InputView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element.children(matching: .other).element.tap()
      app/*@START_MENU_TOKEN@*/.textFields["logInInput"]/*[[".otherElements[\"logo\"]",".otherElements[\"InputView\"].textFields[\"logInInput\"]",".textFields[\"logInInput\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
      XCUIDevice.shared.orientation = .portrait
      
      let shiftButton = app/*@START_MENU_TOKEN@*/.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      shiftButton.tap()
      
      let hKey = app/*@START_MENU_TOKEN@*/.keys["H"]/*[[".keyboards.keys[\"H\"]",".keys[\"H\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      hKey.tap()
      
      let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      eKey.tap()
      eKey.tap()
      
      let rKey = app/*@START_MENU_TOKEN@*/.keys["r"]/*[[".keyboards.keys[\"r\"]",".keys[\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
      rKey.tap()
      eKey.tap()
      app/*@START_MENU_TOKEN@*/.staticTexts["Password"]/*[[".otherElements[\"logo\"]",".otherElements[\"PassINPUT\"].staticTexts[\"Password\"]",".staticTexts[\"Password\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
      shiftButton.tap()
      hKey.tap()
      eKey.tap()
      rKey.tap()
      eKey.tap()
      shiftButton.tap()
      hKey.tap()
      eKey.tap()
      rKey.tap()
      eKey.tap()
      eKey.tap()
      app/*@START_MENU_TOKEN@*/.buttons["LOG IN"]/*[[".otherElements[\"logo\"].buttons[\"LOG IN\"]",".buttons[\"LOG IN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      
      let collectionViewsQuery = app.collectionViews
      collectionViewsQuery.cells.children(matching: .other).element.children(matching: .other).element(boundBy: 1).swipeUp()
      collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["messageButton"]/*[[".cells",".buttons[\"chat\"]",".buttons[\"messageButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
      
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
