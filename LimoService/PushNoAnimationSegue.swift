//
//  PushNoAnimationSegue.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

/// This segue only works inside a navigation controller to push the next viewcontroller without animation.
class PushNoAnimationSegue: UIStoryboardSegue {
    override func perform() {
        let source = sourceViewController as! UIViewController
        if let navigation = source.navigationController {
            navigation.pushViewController(destinationViewController as! UIViewController, animated: false)
        }
    }
}
