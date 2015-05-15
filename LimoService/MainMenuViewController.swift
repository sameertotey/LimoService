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
  
//    var listner: MapLocationSelectViewController!
    
    var comments = ""
    var numBags = 0
    var numPassengers = 1
    var preferredVehicle = "Limo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
     }
  
    func goHome() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
    // MARK: - Navigation
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
