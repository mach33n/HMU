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
  
  //Mock container for Core Data Testing
  lazy var contactStoreModel: NSManagedObjectModel = {
    //Make a model similar to the one I use for my existing Contact List
    let contactStoreModel = NSManagedObjectModel()
    
    // Create the entity
    let entity = NSEntityDescription()
    entity.name = "TransformableContactContainer"
    
    //Create the two properties as attributes
    var properties = Array<NSAttributeDescription>()
    
    let identifierAttribute = NSAttributeDescription()
    identifierAttribute.name = "identifier"
    identifierAttribute.attributeType = .stringAttributeType
    identifierAttribute.isOptional = false
    
    //not sure what this means
    identifierAttribute.isIndexedBySpotlight = true
    properties.append(identifierAttribute)
    
    let transformableContact = NSAttributeDescription()
    transformableContact.name = "transformableContact"
    transformableContact.attributeType = .transformableAttributeType
    transformableContact.isOptional = false
    transformableContact.isIndexedBySpotlight = true
    
    properties.append(transformableContact)
    
    entity.properties = properties
    
    contactStoreModel.entities = [entity]
    
    print("Entities: ")
    print(contactStoreModel.entities)
    return contactStoreModel
  }()
  
  lazy var mockContactStoreContainer: NSPersistentContainer = {
    //Create a persistent mock container for test purposes
    let container = NSPersistentContainer(name: "TransformableContactContainer", managedObjectModel: self.contactStoreModel)
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

//    Dont feel like dealing with private issue here plus I already can tell that my API Initializes implicitly through other tests.
//    func testInitializedAPI() {
//      XCTAssertEqual(testManager?.persistentCont, mockContactStoreContainer)
//    }
  
    func testAddContact() {
      var temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      var temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      print(testManager!.addContact(contact: Joji))
      
      XCTAssertEqual(testManager?.persistentContCount(), 2)
    }
  
    func testContains() {
      var temp = CNMutableContact()
      temp.nickname = "Kacey"
      temp.familyName = "Fields"
      let Kacey = HCContact(contact: temp)
      
      var temp2 = CNMutableContact()
      temp2.nickname = "Joji"
      temp2.familyName = "Pink Guy"
      let Joji = HCContact(contact: temp2)
      
      print(testManager!.addContact(contact: Kacey))
      print(testManager!.addContact(contact: Joji))
      
      XCTAssertTrue((testManager?.contains(contact: Joji))!)
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
