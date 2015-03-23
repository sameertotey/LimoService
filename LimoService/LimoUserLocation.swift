//
//  LimoUserLocation.swift
//  LimoService
//
//  Created by Sameer Totey on 3/16/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

class LimoUserLocation: PFObject, PFSubclassing {
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String! {
        return "LimoUserLocation"
    }
    @NSManaged var name: String?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var address: String?
}
