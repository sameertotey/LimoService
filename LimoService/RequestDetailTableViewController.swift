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

      // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.leftBarButtonItem = nil
        editing = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
 
    func setupDisplayFields() {
        println("setup display fields")
        removeKeyboardDisplay()
        if let from = limoRequest["from"] as? PFObject {
            fromLocation = from as? LimoUserLocation
            fromLocationTextField.text = limoRequest["fromName"] as? String
            fromLocationTextView.text = limoRequest["fromAddress"] as? String
        }
        if let to = limoRequest["to"] as? PFObject {
            toLocation = to as? LimoUserLocation
            toLocationTextField.text = limoRequest["fromName"] as? String
            toLocationTextView.text = limoRequest["fromAddress"] as? String
        }
        if let when = limoRequest["when"] as? NSDate {
            println("setting date to \(when)")
            limoRequestDatePicker.minimumDate = when
            limoRequestDatePicker.setDate(when, animated: false)
            updateDatePickerLabel()
        }
        
        if let numPassengers = limoRequest["numPassengers"] as? NSNumber {
            numPassengersStepper.value = numPassengers.doubleValue
            numPassengersLabel.text = "\(Int(numPassengersStepper.value))"
        }
        if let numBags = limoRequest["numBags"] as? NSNumber {
            numBagsStepper.value = numBags.doubleValue
            numBagsLabel.text = "\(Int(numBagsStepper.value))"
        }
        
        specialCommentsTextField.text = limoRequest["specialRequests"] as? String
        fromLocationLookUp.hidden = true
        toLocationLookUp.hidden = true
        numPassengersStepper.enabled = false
        numBagsStepper.enabled = false
        limoRequestDatePicker.enabled = false
        limoRequestDatePicker.hidden = true
    }
    
    func setupEditingFields() {
        println("ready to edit fields")
        fromLocationLookUp.hidden = false
        toLocationLookUp.hidden = false
        numPassengersStepper.enabled = true
        numBagsStepper.enabled = true
        limoRequestDatePicker.enabled = true
        limoRequestDatePicker.hidden = false
    }
    
    @IBAction func statusButtonTouchUpInside(sender: UIButton) {
        println("now take the action that changes the status of the request")
        
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
