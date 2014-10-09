//
//  learnAddrBook.swift
//  learnAddrBook
//
//  Created by Stanley Chiang on 10/8/14.
//  Copyright (c) 2014 Stanley Chiang. All rights reserved.
//

import Foundation
import CoreData

class Contacts: NSManagedObject {

    @NSManaged var memo: String?
    @NSManaged var name: String
    @NSManaged var phone: String?
    @NSManaged var hasCalled: NSNumber
	@NSManaged var firstTime: NSNumber
}
