//
//  LimoUser.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

class LimoUser : PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String! {
        return "LimoUser"
    }
    @NSManaged var firstName: String?
    @NSManaged var middleName: String?
    @NSManaged var lastName: String?
    
    @NSManaged var phoneNumer: String?
    @NSManaged var user: PFUser?
    
    @NSManaged var homeLocation: LimoUserLocation?

    var billingAddressStreet: String?
    var billingAddressStreetPrefix: String?
    var billingAddressStreetSuffix: String?
    var billingAddressAdditionalInfo: String?
    var billingAddressCity: String?
    var billingAddressZip: String?
    var billingAddressState: String?
    
    var creditCardType: String?
    var creditCardNumber: String?
    var creditCardExp: String?
    
    var prefferredDestination: String?
}