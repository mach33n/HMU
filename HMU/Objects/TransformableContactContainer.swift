//
//  TransformableContainer.swift
//  HMU
//
//  Created by Cameron Bennett on 12/31/19.
//  Copyright © 2019 Cameron Bennett. All rights reserved.
//

import Foundation
import CoreData

class TransformableContactContainer: NSManagedObject {
  @NSManaged var identifier: String
  @NSManaged var transformableContact: HCContact
}
