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
  
  private let contact: CNContact
  
  var contactImage: UIImage?
  
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
    self.contact = contact
    super.init()
  }
  
  /* This method performs the decoding of the image data. It makes sense that the stored contact has image data
       available and it checks whether the contact image isn't set yet. If this is the case, the image data is decoded and
       assigned to the contactImage. The next time this method is called nothing will happen because contactImage,
       won't be nil since the prefetching already did its job.
     */
  func fetchImageIfNeeded() {
    if let imageData = contact.imageData, contactImage == nil {
      contactImage = UIImage(data: imageData)
    }
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

  var identifier: String {
    return contact.identifier
  }
  
  func isEqual(object: HCContact?) -> Bool {
    return identifier == object?.identifier
  }

}
