//
//  contactAPI.swift
//  HMU
//
//  Created by Cameron Bennett on 2/23/20.
//  Copyright © 2020 Cameron Bennett. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class contactAPI {
  
  //Attempted Singelton
  static let shared = contactAPI()
  
  private var persistentCont: NSPersistentContainer!
  
  private var contactList: [HCContact] = []
  
  init() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      persistentCont = appDelegate.persistentContainer
    }
  }
  
  init(container: NSPersistentContainer) {
    persistentCont = container
  }
  
  func persistentContCount() -> Int {
    let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
    do {
      return try persistentCont.viewContext.count(for: request)
    }
    catch {
      print("Error accessing persistent container count.")
      return 0
    }
  }
  
  func persistentContCount(predicate: NSPredicate) -> Int {
    let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
    request.predicate = predicate
    do {
      return try persistentCont.viewContext.count(for: request)
    }
    catch {
      print("Error accessing persistent container count.")
      return 0
    }
  }
  
  // Add Contact Functionality
  func addContact(contact: HCContact) -> Bool {
    // Check if contact already exists in contactList
    if(!contains(contact: contact)) {
      //If not then create it and add it to my persistent container
      let entity = NSEntityDescription.entity(forEntityName: "TransformableContactContainer", in: persistentCont.viewContext)
      if let TransformableContactContainer = NSManagedObject(entity: entity!, insertInto: persistentCont.viewContext) as? TransformableContactContainer {
        TransformableContactContainer.identifier = contact.identifier
        TransformableContactContainer.transformableContact = contact
        do {
          try persistentCont.viewContext.save()
        } catch {
          print("Unable to save due to: \(Error.self)")
          return false
        }
      } else {
        //Handle errors
        print("Error saving object: \(Error.self)")
        return false
      }
    } else {
      //Ignore if contact already exists in list
      return false
    }
    return true
  }
  
  func contains(contact: HCContact) -> Bool{
    //Make request for count of a contact object based on its string identifier.
    let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
    
    //Prepopulates our transformablecontactcontainer objects in core data to ensure that we predicate properly
    request.returnsObjectsAsFaults = false
    request.predicate = NSPredicate(format: "identifier = %@", contact.identifier)
    
    //Return true or false based on whether or not the object count is greater than 0
    var contains = false
    print(try! persistentCont.viewContext.count(for: request) > 0)
    contains = try! persistentCont.viewContext.count(for: request) > 0 ? true : false
    return contains
  }
  
}
