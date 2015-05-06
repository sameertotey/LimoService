//
//  MainMenuViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController, NumStepperCellDelegate, SegmentControlCellDelegate, TextFieldCellDelegate {
    
    @IBOutlet weak var numPassengersCell: NumStepperCellTableViewCell!
    @IBOutlet weak var numBagsCell: NumStepperCellTableViewCell!
    @IBOutlet weak var preferredVehicleCell: SegmentControlTableViewCell!
    @IBOutlet weak var commentCell: TextFieldCellTableViewCell!
    
  
    var listner: MapLocationSelectViewController!
    
    var comments = "" {
        didSet {
            listner?.specialComments = comments
        }
    }
    var numBags = 0 {
        didSet {
            listner?.numBags = numBags
         }
    }
    var numPassengers = 1 {
        didSet {
            listner?.numPassengers = numPassengers
        }
    }
    var preferredVehicle = "Limo" {
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
        case 1: performSegueWithIdentifier("Profile", sender: nil)
        case 2: performSegueWithIdentifier("History", sender: nil)
        case 3: goHome()
        case 4: performSegueWithIdentifier("Destination", sender: nil)
        case 5: goHome()
        default: break
        }
    }
  
    func goHome() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToHome(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        
        // This is a destination search return
        if let sVC = sourceViewController as? LocationSelectionViewController {
            if let presentingViewController = presentingViewController {
                println("\(presentingViewController)")
                
            }
            listner?.toLocation = sVC.selectedLocation
        }
        
        // This is a history search return
        if let sVC = sourceViewController as? RequestsTableViewController {
            if let presentingViewController = presentingViewController {
                println("\(presentingViewController)")
                
            }
            listner?.limoRequest = sVC.selectedRequest
        }

        goHome()
    }
    
    // MARK: - NumSteppersCellDelegate
    
    func stepperValueUpdated(sender: NumStepperCellTableViewCell) {
        if let value = sender.value, indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
            switch indexPath.section {
            case 1:
                numPassengers = value
            case 2:
                numBags = value
            default:
                println("Unexpected index for stepper cell")
            }
        }
    }
    
      // MARK: - SegmentedControlDelegate
    
    func segmentControlUpdated(sender: SegmentControlTableViewCell) {
        if let vehicle = sender.selection {
            preferredVehicle = vehicle
        }
    }
    
    // MARK: - TextFieldCellDelegate
    func textFieldUpdated(sender: TextFieldCellTableViewCell) {
        if let comment = sender.textField.text {
            comments = comment
        }
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepare for segue")
        if let identifier = segue.identifier {
            switch identifier {
            case "Profile":
                println("segue from main menu to Profile")
                if let toNavVC = segue.destinationViewController as? UINavigationController {
                    if let toVC = (segue.destinationViewController.viewControllers as? [UIViewController])?.first as? UserProfileTableViewController {
                        toVC.modalPresentationStyle = .Custom
                        toVC.transitioningDelegate = self.transitioningDelegate
                    }
                    toNavVC.modalPresentationStyle = .Custom
                    toNavVC.transitioningDelegate = self.transitioningDelegate

                }
                
            case "History":
                if let toNavVC = segue.destinationViewController as? UINavigationController {
                    if let toVC = (segue.destinationViewController.viewControllers as? [UIViewController])?.first as? RequestsTableViewController {
                        toVC.modalPresentationStyle = .Custom
                        toVC.transitioningDelegate = self.transitioningDelegate
                    }
                    toNavVC.modalPresentationStyle = .Custom
                    toNavVC.transitioningDelegate = self.transitioningDelegate
                    
                }
            case "Destination":
                if let toNavVC = segue.destinationViewController as? UINavigationController {
                    toNavVC.modalPresentationStyle = .Custom
                    toNavVC.transitioningDelegate = self.transitioningDelegate
                }
            default:
                break
            }
        }
    }


}
