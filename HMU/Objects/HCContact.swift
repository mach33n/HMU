//
//  HCContact.swift
//  HelloContacts
//
//  Created by Simon Mc Neil on 2018-05-08.
//  Copyright © 2018 Simon Mc Neil. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class HCContact: NSObject, NSCoding {

  func encode(with coder: NSCoder) {
    coder.encode(contact, forKey: "contactRoot")
  }

  required init?(coder: NSCoder) {
    self.contact = coder.decodeObject(forKey: "contactRoot") as! CNContact
  }

  private var contact: CNContact

  var contactImage: UIImage?
  
  var isFavorite: Bool?

  var name: String {
    return contact.givenName + " " + contact.familyName
  }

  // the following two scopes use two things called computer properties to provide a proxy to the CNContact istance that is stored in this class.
  var givenName: String {
    return contact.givenName
  }

  var familyName: String {
    return contact.familyName
  }

  init(contact: CNContact) {
    let temp = contact.mutableCopy() as! CNMutableContact
    self.contact = temp
    self.isFavorite = false
    super.init()
  }

  /* This method performs the decoding of the image data. It makes sense that the stored contact has image data
       available and it checks whether the contact image isn't set yet. If this is the case, the image data is decoded and
       assigned to the contactImage. The next time this method is called nothing will happen because contactImage,
       won't be nil since the prefetching already did its job.
     */
  func fetchImageIfNeeded() {
    if contact.imageDataAvailable {
      contactImage = UIImage(data: contact.imageData!)
    }
  }
  
  func getContact() -> CNContact {
    return self.contact
  }
  
  func toggleFavorite() {
    self.isFavorite!.toggle()
  }
  
  // Not neccessary at the moment but could be useful.
  func setNickname(nickname: String) {
    var temp = contact.mutableCopy() as! CNMutableContact
    temp.nickname = nickname
    self.contact = temp
  }

  /* The ?? is called a ni coalescing operator. It used to return a retrieved value or a placeholder string
       If the retrieved value doesn't exist, the placeholder is used instead.
     */
  var emailAddress: String {
    return String(contact.emailAddresses.first?.value ?? "--")
  }

  /* The next phoneNumbers and postalAddresses are arrays of NSValue objects. Since we're only interested in the
       first item available, we use the first property that's defined on the array. When available it returns
       the first element of the array */
  var phoneNumber: String {
    return String(contact.phoneNumbers.first?.value.stringValue ?? "--")
  }

  /* For the address the code is a little more complex. An address has multiple fields, so we extract the ones
      we need, with the same technique that's used for the phone number. Then a string is returned with both values
      seperated by a comma. */
  var address: String {
    let street = contact.postalAddresses.first?.value.street ?? "--"
    let city = contact.postalAddresses.first?.value.city ?? "--"
    return "\(street)-\(city)"
  }
  
  var nickname: String {
    return contact.nickname.isEmpty ? "Tap to add description!" : contact.nickname
  }

  var identifier: String {
    return contact.identifier
  }
  
  var facebook: CNLabeledValue<CNSocialProfile> {
    return contact.socialProfiles.first { (label) -> Bool in
      label.label == CNSocialProfileServiceFacebook
    }!
  }
  
  var twitter: CNLabeledValue<CNSocialProfile> {
    return contact.socialProfiles.first { (label) -> Bool in
      label.label == CNSocialProfileServiceTwitter
    }!
  }
  
  var instagram: CNLabeledValue<CNSocialProfile> {
    return contact.socialProfiles.first { (label) -> Bool in
      label.label == "Instagram"
    }!
  }

  func isEqual(object: HCContact?) -> Bool {
    return identifier == object?.identifier
  }
  
  func updates(object: CNContact?, completion: (Bool)->()) {
    var changesMade = false
    var temp = contact.mutableCopy() as! CNMutableContact
    if (object!.imageDataAvailable || contact.imageData != object?.imageData) {
        temp.imageData = object?.imageData
        changesMade = true
    }
    if (contact.givenName != object?.givenName) {
      temp.givenName = object!.givenName
      changesMade = true
    }
    if (contact.familyName != object?.familyName) {
      temp.familyName = object!.familyName
      changesMade = true
    }
    if (contact.nickname != object?.nickname) {
      temp.nickname = object!.nickname
      changesMade = true
    }
    if (contact.emailAddresses != object?.emailAddresses) {
      temp.emailAddresses = []
      for emails in object!.emailAddresses {
        temp.emailAddresses.append(emails)
      }
      changesMade = true
    }
    if (contact.phoneNumbers != object?.phoneNumbers) {
      temp.phoneNumbers = []
      for numbers in object!.phoneNumbers {
        temp.phoneNumbers.append(numbers)
      }
      changesMade = true
    }
    if (contact.postalAddresses != object?.postalAddresses) {
      temp.postalAddresses = []
      for numbers in object!.postalAddresses {
          temp.postalAddresses.append(numbers)
      }
      changesMade = true
    }
    contact = temp
    completion(changesMade)
  }
}
