//
//  LocationMapPinView.swift
//  LimoService
//
//  Created by Sameer Totey on 4/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit

class LocationMapPinView: MKAnnotationView {
    
    enum MKPinAnnotationColor : UInt {
        case Red
        case Green
        case Purple
    }
    
    override func prepareForReuse() {
        println("preparing for reuse")
    }
    
   
    var pinColor: MKPinAnnotationColor! {
        didSet {
            if let color = pinColor {
                switch color {
                case .Red:
                    image = UIImage(named: "RedLocationPin")
                case .Green:
                    image = UIImage(named: "GreenLocationPin")
                case .Purple:
                    image = UIImage(named: "PurpleLocationPin")
                }
                centerOffset = CGPointMake(0.0, -15.0)
            }
         }
    }
}
