//
//  ProviderMenuViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 5/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ProviderMenuViewController: MainMenuViewController {
    var listner: MapLocationSelectViewController!
    
    override var comments: String {
        didSet {
            listner?.specialComments = comments
        }
    }
    override var numBags: Int {
        didSet {
            listner?.numBags = numBags
        }
    }
    override var numPassengers: Int {
        didSet {
            listner?.numPassengers = numPassengers
        }
    }
    override var preferredVehicle: String {
        didSet {
            listner?.preferredVehicle = preferredVehicle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0: goHome()
        case 1: performSegueWithIdentifier("Profile", sender: nil)
        case 2: goHome()
        case 3: goHome()
        default: break
        }
    }
    

    // MARK: - Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        println("prepare for segue")
//        if let identifier = segue.identifier {
//            switch identifier {
//            case "Profile":
//                println("segue from main menu to Profile")
//                if let toNavVC = segue.destinationViewController as? UINavigationController {
//                    if let toVC = (segue.destinationViewController.viewControllers as? [UIViewController])?.first as? UserProfileTableViewController {
//                        toVC.modalPresentationStyle = .Custom
//                        toVC.transitioningDelegate = self.transitioningDelegate
//                    }
//                    toNavVC.modalPresentationStyle = .Custom
//                    toNavVC.transitioningDelegate = self.transitioningDelegate
//                }
//                
//            case "History":
//                if let toNavVC = segue.destinationViewController as? UINavigationController {
//                    if let toVC = (segue.destinationViewController.viewControllers as? [UIViewController])?.first as? RequestsTableViewController {
//                        toVC.modalPresentationStyle = .Custom
//                        toVC.transitioningDelegate = self.transitioningDelegate
//                    }
//                    toNavVC.modalPresentationStyle = .Custom
//                    toNavVC.transitioningDelegate = self.transitioningDelegate
//                }
//            case "Destination":
//                if let toNavVC = segue.destinationViewController as? UINavigationController {
//                    toNavVC.modalPresentationStyle = .Custom
//                    toNavVC.transitioningDelegate = self.transitioningDelegate
//                }
//            default:
//                break
//            }
//        }
//    }
    
    
}
