//
//  ContactList.swift
//  HMU
//
//  Created by Cameron Bennett on 10/27/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import Foundation
import Contacts
import CoreData
import UIKit


struct ContactList {
  typealias LoadDataCompletion = (Bool) -> ()
  static var contactList: [HCContact] = []
  static var currentContact = 0
  static var phrases = ["Hit up ", "Say hi to ", "Keep talking to "]
  static var store = CNContactStore()

  /*
     Method for adding contact to data model and storage container given name and phone number.
     Future Critique:
     Add more paramaters to CNContacts to be stored.
  */
  static public func addContact(name: String, phoneNumber: String) {
    // Might be more efficient way of initializing and checking for contact in contact list
    let temp = CNMutableContact.init()
    temp.familyName = name
    temp.phoneNumbers[0] = CNLabeledValue.init(label: "CNPhoneNumber", value: CNPhoneNumber.init(stringValue: phoneNumber))
    if(!ContactList.contactList.contains(where: { (con) -> Bool in
      con.familyName == name
    })) {
      print("Data save result: \(saveData(contact: HCContact.init(contact: temp)))")
    }
  }

  /*
     Method for adding contact to data model and storage container given name and phone number.
     Future Critique:
     Add more paramaters to CNContacts to be stored.
  */
  static public func addContact(contact: CNContact) {
    if(!ContactList.contactList.contains(where: { (con) -> Bool in
      con.familyName == contact.familyName
    })) {
      print("Data save result: \(saveData(contact: HCContact.init(contact: contact)))")
    }
  }

  /*
     Method for adding contact to data model and storage container given HCContact
  */
  static public func addContact(contact: HCContact) {
    if(!ContactList.contactList.contains(where: { (con) -> Bool in
      con.familyName == contact.familyName
    })) {
      print("Data save result: \(saveData(contact: contact))")
    }
  }

  static public func deleteContact(number: String, completion: @escaping LoadDataCompletion) {
    OperationQueue().addOperation { [unowned store] in
      let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber.init(stringValue: number))
      let toFetch = [CNContactEmailAddressesKey]

      do {

        let contacts = try store.unifiedContacts(matching: predicate,
                                                 keysToFetch: toFetch as [CNKeyDescriptor])

        guard contacts.count > 0 else {
          print("No contacts found")
          return
        }

        //only do this to the first contact matching our criteria
        guard let contact = contacts.first else {
          return
        }

        let req = CNSaveRequest()
        if let mutableContact = contact.mutableCopy() as? CNMutableContact {
          req.delete(mutableContact)

          do {
            try store.execute(req)
            print("Successfully deleted the user")
            contactList.removeAll { (contact) -> Bool in
              return contact.identifier == number
            }
            completion(true)
          } catch let error {
            print("Error = \(error)")
            completion(false)
          }

        } else {
          //Handle busted mutable copy of contact
          completion(false)
        }

      } catch let err {
        print(err)
      }
    }
  }

  /*
    Method for saving contact data to core Data model given a HCContact
  */
  static private func saveData(contact: HCContact) -> Bool {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      let context = appDelegate.persistentContainer.viewContext

      func someEntityExists(id: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransformableContactContainer")
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", id)

        var results: [NSManagedObject] = []

        do {
          results = try context.fetch(fetchRequest)
        }
        catch {
          print("error executing fetch request: \(error)")
        }

        return results.count > 0
      }

      if !someEntityExists(id: contact.identifier) {
        let entity = NSEntityDescription.entity(forEntityName: "TransformableContactContainer", in: context)
        if let transformableContactContainer = NSManagedObject(entity: entity!, insertInto: context) as? TransformableContactContainer {
          transformableContactContainer.identifier = contact.identifier
          transformableContactContainer.transformableContact = contact
        } else {
          print("Error saving object")
        }
      }

      do {
        try context.save()
      } catch {
        print("Failed saving")
        return false
      }
      return true
    } else {
      return false
    }
  }

  static public func removeFromContainer(contact: HCContact, completion: @escaping LoadDataCompletion) {
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
        // Use this to filter data Loading
        // or Potentially make a new method with a predicate argument
        request.predicate = NSPredicate(format: "identifier = %@", contact.identifier)
        request.returnsObjectsAsFaults = false
        do {
          let result = try context.fetch(request)

          for data in result {
            if(ContactList.contactList.contains(where: { (con) -> Bool in
              con.identifier == data.identifier })) {
              context.delete(data)
              try context.save()
            }
          }
          completion(true)
        } catch {
          completion(false)
        }
      } else {
        completion(false)
      }
    }
  }

  static public func loadAllData(completion: @escaping LoadDataCompletion) -> HCContact? {
    var contact: HCContact? = nil
    DispatchQueue.main.async {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<TransformableContactContainer>(entityName: "TransformableContactContainer")
        // Use this to filter data Loading
        // or Potentially make a new method with a predicate argument
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
          let result = try context.fetch(request)

          for data in result {
            if(!ContactList.contactList.contains(where: { (con) -> Bool in
              con.identifier == data.identifier })) {
              contactList.append(data.transformableContact)
              contact = data.transformableContact
            }
          }
          completion(true)
        } catch {
          completion(false)
        }
      } else {
        completion(false)
      }
    }
    return contact
  }

  static public func retrieveContacts(contacts: Set<String>, completion: @escaping (Bool) -> Void) {
    let keysToFetch = [
      CNContactGivenNameKey as CNKeyDescriptor, //gets contact name
      CNContactFamilyNameKey as CNKeyDescriptor, //gets contact family name
      CNContactImageDataKey as CNKeyDescriptor, //gets contacts image.
      CNContactImageDataAvailableKey as CNKeyDescriptor, //checks if contact image is available
      CNContactEmailAddressesKey as CNKeyDescriptor, //gets contacts email
      CNContactPhoneNumbersKey as CNKeyDescriptor, //gets phoneNumber
      CNContactPostalAddressesKey as CNKeyDescriptor //gets contacts address
    ]

    //gets all types of contacts
    var allContainers: [CNContainer] = []
    do {
      allContainers = try store.containers(matching: nil)
    } catch {
      print("Error fetching containers")
    }

    for container in allContainers {
      //When fetching a list of contacts we use a predicate. It's main purpose is to set up a filter for the contacts database.
      let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

      do {
        //unifiedContact gets the contact information according to the predicate we set and the keys we created.
        let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch).map {
          (contact) -> HCContact in
          return HCContact(contact: contact)
        }

        for con in containerResults {
          if ((contacts.contains(con.identifier)) && !contactList.contains(where: { (contact) -> Bool in
              contact.identifier == con.identifier
            })) {
            ContactList.addContact(contact: con)
          }
        }

        ContactList.loadAllData { (loaded) in
          if loaded {
            completion(true)
          }
        }
      } catch {
        print("Error fetching results for container")
      }
    }
  }

  static public func pullContact(_ completion: @escaping (Bool) -> Void) {
    loadAllData { success in
      if (success) {
        if(contactList.count == 0) {
          completion(false)
          return
        }
        if (contactList.count <= currentContact) {
          currentContact = 0
        }
        makeNotif(contact: contactList[currentContact])
        currentContact += 1
      }
      completion(true)
    }

  }

  static private func makeNotif(contact: HCContact) {
    let center = UNUserNotificationCenter.current()
    center.getPendingNotificationRequests { (contacts) in
      if contacts.count > 0 {
        return
      }
      center.removeAllPendingNotificationRequests()

      let content = UNMutableNotificationContent()
      content.title = "HMU"
      content.body = phrases[(Int(arc4random()) % (phrases.count))] + contact.familyName + " ?"
      content.categoryIdentifier = "alarm"
      content.userInfo = ["PHONE_NUMBER": "\(contact.phoneNumber)"]
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
}
