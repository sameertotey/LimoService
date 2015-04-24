//
//  CustomNavigationController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/22/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    var notifier: NavBarNotificationDelegate?
    
    override var navigationBarHidden: Bool {
        get {
            return super.navigationBarHidden
        }
        set {
            super.navigationBarHidden = newValue
            notifier?.navigationBarStatusUpdated(newValue)
        }
    }
}

