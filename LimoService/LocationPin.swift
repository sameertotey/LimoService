//
//  LocationPin.swift
//  LimoService
//
//  Created by Sameer Totey on 4/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import AddressBookUI

class LocationPin: NSObject, MKAnnotation {
    
    var _coordinate: CLLocationCoordinate2D?
      
    // make coordinate get & set (for draggable annotations)
    var coordinate: CLLocationCoordinate2D {
        get { return _coordinate! }
        set {
            _coordinate = newValue
        }
    }

    var title: String! = "Searching Location...."
    var subtitle: String! 
    
 }
