//
//  MainMenuViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController, NumStepperCellDelegate {
    
    @IBOutlet weak var numPassengersCell: NumStepperCellTableViewCell!
    @IBOutlet weak var numBagsCell: NumStepperCellTableViewCell!
    
    var specialComments = ""
    var numBags = 0 {
        didSet {
            if let mainVC = presentingViewController as? MapLocationSelectViewController {
                mainVC.numBags = numBags
            }
        }
    }
    var numPassengers = 1 {
        didSet {
            if let mainVC = presentingViewController as? MapLocationSelectViewController {
                mainVC.numPassengers = numPassengers
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        numPassengersCell.configureSteppers(Double(numPassengers), minimum: 0, maximum: 10, step: 1)
        numPassengersCell.delegate = self
        numBagsCell.configureSteppers(Double(numBags), minimum: 0, maximum: 10, step: 1)
        numBagsCell.delegate = self

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0: goHome()
        case 1: performSegueWithIdentifier("Profile", sender: nil)
        case 4: goHome()
        case 5: goHome()
        default: break
        }
    }
  
    func goHome() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // unwind a logoff
    @IBAction func unwindToHome(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        goHome()
    }
    
    // MARK: - NumSteppersCell delegate
    
    func stepperValueUpdated(sender: NumStepperCellTableViewCell) {
        if let value = sender.value, indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
            switch indexPath.row {
            case 4:
                numPassengers = value
            case 5:
                numBags = value
            default:
                println("Unexpected index for stepper cell")
            }
        }
    }


}
