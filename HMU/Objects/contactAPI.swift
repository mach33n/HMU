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

  //Attempted Singelton that might get changed to dependency injection
  static let shared: contactAPI = {
    //Enables future customizablitity of code
    return contactAPI()
  }()

  private var persistentCont: NSPersistentContainer!

  //Delegate to handle notification responses
  let notificationDelegate = HMUResponseNotificationDelegate()

  private var contactList: [HCContact] = []
  private var currIndex: Int = 0

  private var phrases = ["Hit up ", "Say hi to ", "Keep talking to "]

  private init() {
    persistentCont = self.persistentContainer
  }

  init(container: NSPersistentContainer) {
    persistentCont = container
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
        self.saveContext()
        return true
      } else {
        //Handle errors
        print("Error making NSManaged object: \(Error.self)")
        return false
      }
    } else {
      //Ignore if contact already exists in list
      print("Contact \(contact.familyName) already exists in container")
      return false
    }
  }

  // Remove Contact Functionality
  func removeContact(contact: HCContact) -> Bool {
    //Check if contact existsa
    if(contains(contact: contact)) {
      // Request object to be deleted
      let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
      // Use this to filter data Loading
      // or Potentially make a new method with a predicate argument
      request.predicate = NSPredicate(format: "identifier = %@", contact.identifier)
      request.returnsObjectsAsFaults = false
      do {
        let result = try persistentCont.viewContext.fetch(request)
        for data in result {
          persistentCont.viewContext.delete(data)
        }
        self.saveContext()
        return true
      } catch {
        print("Issue trying to fetch request: " + error.localizedDescription)
        return false
      }
    }
    // Nothing was deleted so we should return false to indicate poor argument input
    print("Poor argument input.")
    return false
  }

  // Functionality to refresh ContactList2
  func loadContacts() -> Bool {
    //Clear current contactList
    self.contactList = []
    // Request object
    let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
    request.returnsObjectsAsFaults = false
    do {
      let result = try persistentCont.viewContext.fetch(request)
      for data in result {
        if (!self.contactListContains(contact: data.transformableContact)) {
          self.contactList.append(data.transformableContact)
        }
      }
      return true
    } catch {
      print("Error saving to container: " + error.localizedDescription)
      return false
    }
  }

  func contains(contact: HCContact) -> Bool {
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

  func makeNotificationForContact(contact: HCContact) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (contacts) in
      if contacts.count > 0 {
        return
      }
      center.removeAllPendingNotificationRequests()

      let content = UNMutableNotificationContent()
      content.title = "HMU"
      content.body = self.phrases[(Int(arc4random()) % (self.phrases.count))] + contact.familyName + " ?"
      content.categoryIdentifier = "alarm"
      content.userInfo = ["PHONE_NUMBER": "\(contact.phoneNumber)", "NAME": "\(contact.name)"]
      content.categoryIdentifier = "NotifResponse"
      content.sound = .default
      content.badge = 1
      // Use for establishing time interval rates
      //        var dateComponents = DateComponents()
      //        dateComponents.hour = 6
      //        dateComponents.minute = 0
      //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      center.add(request)
    }
  }

  private func pullCurrIndex() {
    // Request object to be deleted
    let request = NSFetchRequest<ContactPullContainer>(entityName: "ContactPullContainer")
    request.returnsObjectsAsFaults = false
    do {
      let result = try persistentCont.viewContext.fetch(request)
      if(result.count == 0) {
        createCurrIndex()
      } else {
        self.currIndex = Int(result[0].currIndex)
      }
    } catch {
      print("Error saving to container: " + error.localizedDescription)
    }
  }

  private func saveCurrIndex() -> Bool {
    // Request object to be deleted
    let request = NSFetchRequest<ContactPullContainer>(entityName: "ContactPullContainer")
    // Use this to filter data Loading
    // or Potentially make a new method with a predicate argument
    request.returnsObjectsAsFaults = false
    do {
      let result = try persistentCont.viewContext.fetch(request)
      print("This is the print out \(Int(self.currIndex))")
      result[0].setValue(self.currIndex, forKey: "currIndex")
      self.saveContext()
      return true
    } catch {
      print("Issue trying to fetch request: " + error.localizedDescription)
      return false
    }
  }

  private func createCurrIndex() {
    let entity = NSEntityDescription.entity(forEntityName: "ContactPullContainer", in: persistentCont.viewContext)
    if let TransformableContactContainer = NSManagedObject(entity: entity!, insertInto: persistentCont.viewContext) as? ContactPullContainer {
      TransformableContactContainer.currIndex = 0
      self.saveContext()
    } else {
      //Handle errors
      print("Error making NSManaged object: \(Error.self)")
    }
  }

  func pullContact(_ completion: @escaping (Bool) -> Void) -> Bool {
    if(contactList.count == 0) {
      completion(false)
      return false
    }
    pullCurrIndex()
    if (contactList.count <= currIndex) {
      currIndex = 0
    }
    self.makeNotificationForContact(contact: contactList[currIndex])
    currIndex += 1
    completion(true)
    return saveCurrIndex()
  }

  // MARK: - Core Data stack

  private lazy var persistentContainer: NSPersistentContainer = {
    /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
    let container = NSPersistentContainer(name: "ContactsModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  // MARK: - Notification SetUp
  //Unfinished
  func configureNotification() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
      if let error = error {
        print(error)
        return
      }
    }
    // Not positive if this is the most effective way to register but may not be important.
    if #available(iOS 10.0, *) {
      center.requestAuthorization(options: [.badge, .alert, .sound, .provisional]) { (granted, error) in
        // change navigation screens based on whether user grants access or not.
        if(granted) {
          center.delegate = self.notificationDelegate
          self.setUpNotifActions()
        } else {

        }
      }
    } else {

    }
    UIApplication.shared.registerForRemoteNotifications()

  }

  private func setUpNotifActions() {
    // Define the custom actions.
    let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                            title: "Say Hello", options: .foreground)
    let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                             title: "Not this moment")
    let deleteAction = UNNotificationAction(identifier: "DELETE_ACTION",
                                            title: "Delete Contact", options: [.destructive, .authenticationRequired])

    // Define the notification type
    let meetingInviteCategory =
      UNNotificationCategory(identifier: "NotifResponse",
                             actions: [acceptAction, declineAction, deleteAction],
                             intentIdentifiers: [],
                             hiddenPreviewsBodyPlaceholder: "",
                             options: .customDismissAction)

    // Register the notification type.
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.setNotificationCategories([meetingInviteCategory])
  }

  // MARK: - Testing Functions

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

  func clearContactList() {
    self.contactList = []
  }

  func contactListContains(contact: HCContact) -> Bool {
    return self.contactList.contains(contact)
  }

  func getContactList() -> [HCContact] {
    return self.contactList
  }
}
