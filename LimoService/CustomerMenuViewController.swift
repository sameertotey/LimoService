//
//  CustomerMenuViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 5/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class CustomerMenuViewController: MainMenuViewController {

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

        numPassengersCell.configureSteppers(Double(numPassengers), minimum: 0, maximum: 10, step: 1)
        numPassengersCell.delegate = self
        numBagsCell.configureSteppers(Double(numBags), minimum: 0, maximum: 10, step: 1)
        numBagsCell.delegate = self
        
        preferredVehicleCell.configureSegmentedControl()
        preferredVehicleCell.delegate = self
        
        commentCell.delegate = self
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0: goHome()
        case 1: performSegueWithIdentifier("Destination", sender: nil)
        case 2: performSegueWithIdentifier("History", sender: nil)
        case 3: performSegueWithIdentifier("Profile", sender: nil)
        case 4: goHome()
        case 5: goHome()
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


    @IBAction func unwindToHome(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        
        // This is a destination search return
        if let sVC = sourceViewController as? LocationSelectionViewController {
            //            if let presentingViewController = presentingViewController {
            //                println("\(presentingViewController)")
            //            }
            listner?.toLocation = sVC.selectedLocation
        }
        
//        // This is a history search return
//        if let sVC = sourceViewController as? RequestsTableViewController {
//            listner?.limoRequest = sVC.selectedRequest
//        }
        goHome()
    }

}
