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
   
    static var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()
    
    var _coordinate: CLLocationCoordinate2D?
      
    // make coordinate get & set (for draggable annotations)
    var coordinate: CLLocationCoordinate2D {
        get { return _coordinate! }
        set {
            _coordinate = newValue
            reverseGeoCode()
        }
    }

    var title: String! = "Searching Location...."
    var subtitle: String! 
    
    
    func reverseGeoCode() {
        // cancel previous in flight geocoding
        LocationPin.geoCoder.cancelGeocode()
        let location = CLLocation(latitude: _coordinate!.latitude, longitude: _coordinate!.longitude)
         UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        LocationPin.geoCoder.reverseGeocodeLocation(location)
            { placemarks, error in
                if error == nil {
                    println("received \(placemarks.count) results")
                    if let firstPlacemark = placemarks.first as? CLPlacemark {
                        self.title = firstPlacemark.name
//                        self.subtitle = String(map((ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).generate()) {
//                            $0 == "\n" ? "," : $0
//                            })
                        self.subtitle = (ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).componentsSeparatedByString("\n")[1]
                        
                    }
                    
                    for placemark in placemarks {
                        println("The name of the location is \(placemark.name)")
                        println("\(ABCreateStringWithAddressDictionary(placemark.addressDictionary, false) as NSString)")
                    }
                    
                } else {
                    println("Error in geocoding: \(error)")
                    
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}
