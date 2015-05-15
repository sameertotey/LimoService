//
//  RequestDetailTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/7/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestDetailTableViewController: LimoRequestViewController {
    
    var limoRequest: LimoRequest! {
        didSet {
            limoRequest.fetchFromLocalDatastoreInBackgroundWithBlock { [unowned self](object, error) -> Void in
                println("fetched from local datastore")
                self.setupDisplayFields()
            }
        }
    }

    weak var actionButton: UIButton!
    var action = ""
    var enabled: Bool = false {
        didSet {
            whenCell.enabled = enabled
            fromCell.enabled = enabled
            toCell.enabled = enabled
            numPassengersCell.enabled = enabled
            numBagsCell.enabled = enabled
            specialCommentsCell.enabled = enabled
        }
    }
    
      // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        println("load \(__FILE__)")

//        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil

//        editing = false
    }
    
    deinit {
        println("deallocing \(__FILE__)")
    }
    
    // Constants for Storyboard/ViewControllers
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "RequestDetail"
    }

    // MARK: Factory Methods to return the parent navigation controller
    
//    class func forRequest(limorequest: LimoRequest) -> RequestDetailTableViewController {
//        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
//        let navController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as! UINavigationController
//        let viewController = navController.viewControllers?.first as! RequestDetailTableViewController
//        viewController.limoRequest = limorequest
//        return viewController
//    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
 
    func setupDisplayFields() {
        println("setup display fields")
        tableView.beginUpdates()
        if let from = limoRequest["from"] as? PFObject {
            fromLocation = from as? LimoUserLocation
            fromCell.locationName = limoRequest["fromName"] as? String
            fromCell.locationAddress = limoRequest["fromAddress"] as? String
        }
        if let to = limoRequest["to"] as? PFObject {
            toLocation = to as? LimoUserLocation
            toCell.locationName = limoRequest["toName"] as? String
            toCell.locationAddress = limoRequest["toAddress"] as? String
        }
        if let when = limoRequest["when"] as? NSDate {
            whenCell.date = when
        }
        if let numPassengers = limoRequest["numPassengers"] as? NSNumber {
            numPassengersCell.value = numPassengers.integerValue
        }
        if let numBags = limoRequest["numBags"] as? NSNumber {
            numBagsCell.value = numBags.integerValue
        }
        if let specialComment = limoRequest["specialRequests"] as? String {
            specialCommentsCell.textString = specialComment
        }
        actionButton = actionButtonCell.button
        
        if let status = limoRequest["status"] as? String {
            switch (status, userRole) {
            case ("New", "provider"):
                actionButton.setTitle("Accept this Request", forState: .Normal)
                action = "Accept"
            case ("New", _ ):
                actionButton.setTitle("Cancel this Request", forState: .Normal)
                action = "Cancel"
            case ("Accepted", "provider"):
                actionButton.setTitle("Close this Request", forState: .Normal)
                action = "Close"
            default:
                actionButton.setTitle("Action Not Avail. Yet", forState: .Normal)
                action = "None"
            }
        }
        enabled = false
        tableView.endUpdates()
    }
    
    func setupEditingFields() {
        println("ready to edit fields")
        enabled = true
//        fromLocationLookUp.hidden = false
//        toLocationLookUp.hidden = false
//        numPassengersStepper.enabled = true
//        numBagsStepper.enabled = true
//        limoRequestDatePicker.enabled = true
//        limoRequestDatePicker.hidden = false
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            setupEditingFields()
        } else {
            if limoRequest.isDirty() {
                println("will save the limo request record")
                limoRequest.saveEventually()
            }
            setupDisplayFields()
        }
    }
    
    // text field delegate optional methods
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editing
    }

    // MARK: - ButtonCell delegate
    
    override func buttonTouched(sender: ButtonCellTableViewCell) {
        //
        switch action {
        case "Accept":
            limoRequest["status"] = "Accepted"
            println("current user is \(currentUser)")
            if let user = currentUser {
                limoRequest["assignedTo"] = user
            }
        case "Cancel":
            limoRequest["status"] = "Cancelled"
        case "Close":
            limoRequest["status"] = "Closed"
        default:
            break
        }

        if limoRequest.isDirty() {
            limoRequest.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if succeeded {
                    self.setupDisplayFields()
                } else {
                    println("error while saving the limorequest is \(error)")
                    self.displayAlertWithTitle("Request Update Error", message: "Your changes were not saved")
                }
            })
        }
    }

}
