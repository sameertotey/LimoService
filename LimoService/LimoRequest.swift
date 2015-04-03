//
//  LimoRequest.swift
//  LimoService
//
//  Created by Sameer Totey on 3/25/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

class LimoRequest: PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String! {
        return "LimoRequest"
    }
    @NSManaged var when: NSDate?
    @NSManaged var whenString: String?
    @NSManaged var from: LimoUserLocation?
    @NSManaged var fromString: String?
    @NSManaged var to: LimoUserLocation?
    @NSManaged var toString: String?
    @NSManaged var owner: LimoUser?
    @NSManaged var comment: String?
    @NSManaged var status: String?
}
