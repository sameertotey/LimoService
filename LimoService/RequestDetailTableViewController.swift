//
//  RequestDetailTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/7/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestDetailTableViewController: LimoRequestViewController {
    
    var limoRequest: LimoRequest!

    var actionButton: UIButton!
    var action = ""
    
      // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.leftBarButtonItem = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        editing = false
    }
    
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
            println("setting date to \(when)")
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

//        fromLocationLookUp.hidden = true
//        toLocationLookUp.hidden = true
//        numPassengersStepper.enabled = false
//        numBagsStepper.enabled = false
//        limoRequestDatePicker.enabled = false
//        limoRequestDatePicker.hidden = true
        
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
                action = "Close"
            }
        }
        tableView.endUpdates()

    }
    
    func setupEditingFields() {
        println("ready to edit fields")
//        fromLocationLookUp.hidden = false
//        toLocationLookUp.hidden = false
//        numPassengersStepper.enabled = true
//        numBagsStepper.enabled = true
//        limoRequestDatePicker.enabled = true
//        limoRequestDatePicker.hidden = false
    }
    
    @IBAction func actionButtonTouchUpInside(sender: UIButton) {
        println("now take the action that changes the status of the request")
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
            println("will save the limo request record")
            limoRequest.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                if succeeded {
                    self.setupDisplayFields()
                    println("succeeded in saving")
//                    self.displayAlertWithTitle("Request Updated", message: "Your changes were successfully saved")
                } else {
                    println("error while saving the limorequest is \(error)")
                    self.displayAlertWithTitle("Request Update Error", message: "Your changes were not saved")
                }
            })
        }
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

}
