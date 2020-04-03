//
//  HMUTests.swift
//  HMUTests
//
//  Created by Cameron Bennett on 10/26/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import XCTest
import CoreData
import Contacts

@testable import HMU

class HMUTests: XCTestCase {
  
  var testManager: contactAPI?
  
  //Not sure what this is for
  var saveNotificationCompleteHandler: ((Notification)->())?
  
  lazy var mockContactStoreContainer: NSPersistentContainer = {
    //Create a persistent mock container for test purposes
    let container = NSPersistentContainer(name: "ContactsModel")
    let description = NSPersistentStoreDescription()
    //This prevents overwriting anything in Core Data and limits memory to that allocated to the test
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false // Makes testing environment simpler
    
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
      //Make sure mock container is in memory
      precondition( description.type == NSInMemoryStoreType )
      
      //Handle errors while creating container
      if let error = error {
        fatalError("Create an in-mem coordinator failed \(error)")
      }
    }
    return container
  }()

    override func setUp() {
      super.setUp()
      
      initStubs()
      
      testManager = contactAPI(container: mockContactStoreContainer)
      
      NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }

    override func tearDown() {
      NotificationCenter.default.removeObserver(self)
      
      flushData()
      
      super.tearDown()
    }
  
    func testAddContact() {
      let temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      let temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      print(testManager!.addContact(contact: Joji))
      
      XCTAssertEqual(testManager?.persistentContCount(), 2)
    }
  
    func testContains() {
      let temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      let temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      
      XCTAssertTrue((testManager?.contains(contact: Kacey))!)
      XCTAssertFalse((testManager?.contains(contact: Joji))!)
    }
  
    func testRemove() {
      let temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      let temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      print(testManager!.addContact(contact: Joji))
      
      XCTAssertEqual(testManager?.persistentContCount(), 2)
      
      print(testManager!.removeContact(contact: Joji))
      
      XCTAssertTrue((testManager?.contains(contact: Kacey))!)
      XCTAssertFalse((testManager?.contains(contact: Joji))!)
    }
  
    func testLoad() {
      let temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      let temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      print(testManager!.addContact(contact: Joji))
      print(testManager!.loadContacts())
      XCTAssertEqual(testManager?.getContactList().count, 2)
      testManager!.clearContactList()
      XCTAssertEqual(testManager?.getContactList().count, 0)
      XCTAssertFalse((testManager?.contactListContains(contact: Joji))!)
      XCTAssertEqual(testManager?.persistentContCount(), 2)
      print(testManager!.loadContacts())
      XCTAssertTrue(self.testManager!.contactListContains(contact: Joji))
      XCTAssertTrue(self.testManager!.contactListContains(contact: Kacey))
      XCTAssertEqual(testManager?.getContactList().count, 2)
    }
  
  func testMakeNotifs() {
    let temp2 = CNMutableContact()
    temp2.nickname = "Joji"
    temp2.familyName = "Pink Guy"
    let Joji = HCContact(contact: temp2)
    
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    testManager?.makeNotificationForContact(contact: Joji)
    sleep(5)
    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
      for request in requests {
        let result = request.content.userInfo[AnyHashable("NAME")] as! String
        XCTAssertEqual(result, " Pink Guy")
        return
      }
    }
  }
  
  func testPullContact() {
    let temp = CNMutableContact()
    temp.nickname = "Kacey"
    temp.familyName = "Fields"
    let Kacey = HCContact(contact: temp)
    
    let temp2 = CNMutableContact()
    temp2.nickname = "Joji"
    temp2.familyName = "Pink Guy"
    let Joji = HCContact(contact: temp2)
    
    testManager!.addContact(contact: Kacey)
    testManager!.addContact(contact: Joji)
    testManager!.loadContacts()
    
    testManager?.pullContact({ (success) in
      XCTAssert(success, "All good")
      sleep(5)
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        for request in requests {
          let result = request.content.userInfo[AnyHashable("NAME")] as! String
          XCTAssertEqual(result, " Fields")
        }
      }
    })
    sleep(5)
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    sleep(5)
    testManager?.pullContact({ (success) in
      XCTAssert(success, "All good")
      sleep(5)
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        print(requests)
        for request in requests {
          let result = request.content.userInfo[AnyHashable("NAME")] as! String
          XCTAssertEqual(result, " Pink Guy")
          return
        }
      }
    })
    sleep(5)
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    sleep(5)
    testManager?.pullContact({ (success) in
      XCTAssert(success, "All good")
      sleep(5)
      UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
        for request in requests {
          let result = request.content.userInfo[AnyHashable("NAME")] as! String
          XCTAssertEqual(result, " Fields")
        }
      }
    })
  }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
  
  //Dunno what this does yet
  func contextSaved( notification: Notification ){
    print("\(notification)")
    saveNotificationCompleteHandler?(notification)
  }

}

extension HMUTests {
  func initStubs() {
    do {
      try mockContactStoreContainer.viewContext.save()
    } catch {
      print("creating fakes resulted in error: \(error)")
    }
  }
  
  func flushData() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "TransformableContactContainer")
    let objs = try! mockContactStoreContainer.viewContext.fetch(fetchRequest)
    for case let obj as NSManagedObject in objs {
      mockContactStoreContainer.viewContext.delete(obj)
    }
    
    try! mockContactStoreContainer.viewContext.save()
  }
}
