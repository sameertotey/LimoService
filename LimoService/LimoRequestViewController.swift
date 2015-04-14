//
//  LimoRequestViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoRequestViewController: UITableViewController, LocationCellDelegate, TextFieldCellDelegate, NumStepperCellDelegate, ButtonCellDelegate, DateSelectionDelegate {
    
    var currentUser: PFUser!
    var userFetched = false
    var userRole = ""

    
    // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        configureLookUpSelector()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Configuration
    func configureLookUpSelector() {
        lookUpSelectionController = UIAlertController(
            title: "Choose how you would like to Look Up \(locationSpecifier) Location",
            message: "You can choose any method",
            preferredStyle: .ActionSheet)
        
        let actionAddressLookUp = UIAlertAction(title: "Via Address Look Up",
            style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                /* Ask for address lookup */
                self.performSegueWithIdentifier("Find Address", sender: self.originalLocationText)
        })
        
        let actionLocalSearch = UIAlertAction(title: "Via Local Search",
            style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                /* Send for Local Search */
                self.performSegueWithIdentifier("Search Location", sender: self.originalLocationText)
                
        })
        
        let actionPreviousLocation = UIAlertAction(title: "Via Previous Locations",
            style: .Default,
            handler: {(paramAction:UIAlertAction!) in
                /* Use previous location lookup here */
                self.performSegueWithIdentifier("Select Previous Location", sender: nil)
        })
        
        let actionCancel = UIAlertAction(title: "Cancel",
            style: .Cancel,
            handler: {(paramAction:UIAlertAction!) in
                /* Do nothing here */
        })
        
        lookUpSelectionController!.addAction(actionAddressLookUp)
        lookUpSelectionController!.addAction(actionLocalSearch)
        lookUpSelectionController!.addAction(actionPreviousLocation)
        lookUpSelectionController!.addAction(actionCancel)
    }
    
    // MARK: - Create the Request
    @IBAction func createTheRequest(sender: UIButton) {
        if let from = fromLocation {
            if let user = currentUser {
                let limoRequest = LimoRequest(className: LimoRequest.parseClassName())
                limoRequest["from"] = from
                limoRequest["fromAddress"] = from["address"]
                limoRequest["fromName"] = from["name"]
                if let to = toLocation {
                    limoRequest["to"] = to
                    limoRequest["toAddress"] = to["address"]
                    limoRequest["toName"] = to["name"]
                }
                limoRequest["owner"] = user
                limoRequest["status"] = "New"
                if let dateCell = dateCell {
                    limoRequest["when"] = dateCell.date
                    limoRequest["whenString"] = dateCell.dateString
                }
                limoRequest["numPassengers"] = numPassengers
                limoRequest["numBags"] = numBags
                limoRequest["specialRequests"] = specialComments
                limoRequest.saveInBackgroundWithBlock { (succeeded, error)  in
                    if succeeded {
                        println("Succeed in creating a limo request: \(limoRequest)")
                        let controller = UIAlertController(title: "Request Created", message: "Your limo request has been saved", preferredStyle: .Alert)
                        controller.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                            self.performSegueWithIdentifier("Show Created Request", sender: limoRequest)
                            self.resetFields()
                            })
                        self.presentViewController(controller, animated: true, completion: nil)

                        //                            self.subscibeToChannel(limoRequest.objectId as NSString)
                    } else {
                        println("Received error while creating the request: \(error)")
                    }
                }
            } else {
                displayAlertWithTitle("Incomplete Request", message: "Need User Infomation")
            }
         } else {
            displayAlertWithTitle("Incomplete Request", message: "Need 'From' Location")
        }
    }
    
     
    var lookUpSelectionController:UIAlertController?
    var locationSpecifier = ""
    var originalLocationText = ""
    var fromLocation: LimoUserLocation?
    var toLocation: LimoUserLocation?
    var locationToSave: LimoUserLocation!
    var locationCell: LocationSelectionTableViewCell?
    var dateCell: DateSelectionTableViewCell?

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Profile":
                if segue.destinationViewController is UserProfileTableViewController {
                    let toVC = segue.destinationViewController as! UserProfileTableViewController
                    toVC.currentUser = currentUser
                }
            case "Find Address":
                if segue.destinationViewController is LocationSearchTableViewController {
                    let toVC = segue.destinationViewController as! LocationSearchTableViewController
                    if sender != nil {
                        let text = sender as? String
                        println("Sender String = \(text)")
                        if text != nil {
                            toVC.searchText = text!
                        }
                    }
                }
            case "Search Location":
                if segue.destinationViewController is LocalSearchTableViewController {
                    let toVC = segue.destinationViewController as! LocalSearchTableViewController
                    if sender != nil {
                        let text = sender as? String
                        println("Sender String = \(text)")
                        if text != nil {
                            toVC.searchText = text!
                        }
                    }
                }
            case "Select Previous Location":
                if segue.destinationViewController is PreviousLocationLookupViewController {
                    let toVC = segue.destinationViewController as! PreviousLocationLookupViewController
                    toVC.currentUser = currentUser
                }
             case "Requests":
                if segue.destinationViewController is RequestsTableViewController {
                    let toVC = segue.destinationViewController as! RequestsTableViewController
                    toVC.currentUser = currentUser
                    toVC.userRole = userRole
                }
            case "Show Created Request":
                if segue.destinationViewController is RequestDetailTableViewController {
                    let toVC = segue.destinationViewController as! RequestDetailTableViewController
                    toVC.currentUser = currentUser
                    toVC.userRole = userRole
                    if sender is LimoRequest {
                        toVC.limoRequest = sender as! LimoRequest
                    } else {
                        displayAlertWithTitle("Oops there was a problem", message: "The sender is not a request")
                    }
                }

            default:
                break
            }
        }
    }
    
    // unwind from a location selection
    @IBAction func unwindToUserProfile(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        println("The locationToSave = \(locationToSave)")
        
        if currentUser != nil {
            if sourceViewController is LocationMapViewController {
                let svc: LocationMapViewController = sourceViewController as! LocationMapViewController
                if locationToSave == nil {
                    switch locationSpecifier {
                    case "From":
                        locationToSave = LimoUserLocation()
                        locationToSave["owner"] = currentUser
                        locationToSave["name"] = originalLocationText
                    case "To":
                        locationToSave = LimoUserLocation()
                        locationToSave["owner"] = currentUser
                        locationToSave["name"] = originalLocationText
                    default:
                        break
                    }
                }
                if locationToSave != nil && svc.placemark.location != nil {
                    println("we got save location: \(svc.placemark.location)")
                    let geoPoint = PFGeoPoint(location: svc.placemark.location)
                    locationToSave["location"] = geoPoint
                    if let address = svc.navigationItem.title {
                        locationToSave["address"] = address
                        println("The address reported is \(address)")
                    }
                    locationToSave.saveEventually()
                }
            } else if sourceViewController is PreviousLocationLookupViewController {
                println("returned to .....")
                let svc: PreviousLocationLookupViewController = sourceViewController as! PreviousLocationLookupViewController
                if let returnedLocation = svc.selectedLocation {
                    locationToSave = returnedLocation
                } else {
                    println("Received no location from the previous locations")
                }
            }
            updateLocationDisplay()
        }
    }

    func updateLocationDisplay() {
        if let locationToSave = locationToSave {
            locationCell?.locationAddress = locationToSave["address"] as? String
            // to enable cell height change, we use begin and end Updates around the assignment
            tableView.beginUpdates()
            locationCell?.locationName = locationToSave["name"] as? String
            tableView.endUpdates()
            switch locationSpecifier {
            case "From":
                fromLocation = locationToSave
            case "To":
                toLocation = locationToSave
            default:
                break
            }
        }
     }
   
//    func saveTextIfNeeded(textField: UITextField) {
//        switch textField {
//        case toLocationTextField:
//            if toLocation != nil {
//                toLocation!["name"] = textField.text
//                toLocation!.saveEventually()
//            }
//        case fromLocationTextField:
//            if fromLocation != nil {
//                fromLocation!["name"] = textField.text
//                fromLocation!.saveEventually()
//            }
//        default:
//            break
//        }
//    }
    
    // additonal fields
    
    var specialComments = ""
    var numBags = 0
    var numPassengers = 1
    
    
    // MARK:- Helpers
    
    func resetFields() {
        locationSpecifier = ""
        originalLocationText = ""
        fromLocation = nil
        toLocation = nil
        locationCell = nil
    }
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        controller.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        })
        presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - TableView delegate
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // All sections only have 1 row each
        return 1
    }
    
    struct Constants {
        static let LocationIdentifier = "Location"
        static let DateIdentifier = "Date"
        static let ButtonIdentifier = "Button"
        static let NumberStepperIdentifier = "Stepper Number"
        static let TextFieldIdentifier = "Text Field"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        switch indexPath.section {
        case 0, 3:
            cell = tableView.dequeueReusableCellWithIdentifier(Constants.LocationIdentifier, forIndexPath: indexPath) as! LocationSelectionTableViewCell
            if let locationCell = cell as? LocationSelectionTableViewCell {
                locationCell.delegate = self
             }
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(Constants.DateIdentifier, forIndexPath: indexPath) as! DateSelectionTableViewCell
            if let dateCell = cell as? DateSelectionTableViewCell {
                dateCell.configureDatePicker()
                dateCell.delegate = self
                self.dateCell = dateCell
                dateCell.viewExpanded = false
            }
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(Constants.ButtonIdentifier, forIndexPath: indexPath) as! ButtonCellTableViewCell
            if let buttonCell = cell as? ButtonCellTableViewCell {
                buttonCell.delegate = self
            }
        case 4, 5:
            cell = tableView.dequeueReusableCellWithIdentifier(Constants.NumberStepperIdentifier, forIndexPath: indexPath) as! NumStepperCellTableViewCell
            if let stepperCell = cell as? NumStepperCellTableViewCell {
                stepperCell.configureSteppers(1, minimum: 0, maximum: 10, step: 1)
                stepperCell.delegate = self
            }
        case 6:
            cell = tableView.dequeueReusableCellWithIdentifier(Constants.TextFieldIdentifier, forIndexPath: indexPath) as! TextFieldCellTableViewCell
            (cell as? TextFieldCellTableViewCell)?.delegate = self
        default:
            break
        }
    
        // Configure the cell...
    
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Pickup Location"
        case 1: return "When"
        case 2: return " "
        case 3: return "To"
        case 4: return "Num Passengers"
        case 5: return "Num Bags"
        case 6: return "Specail Request"
        default: return "Title for \(section)"
        }
    }
    
    // MARK: - LocationCell delegate
    
    func lookupTouched(sender: LocationSelectionTableViewCell) {
        //
        if let indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
            locationCell = sender
            originalLocationText = sender.locationNameTextField.text
            
            switch indexPath.section {
            case 0:
                locationSpecifier = "From"
                locationToSave = fromLocation
                presentViewController(lookUpSelectionController!, animated: true) {
                    println("finished presenting the lookup selector")
                }
                
            case 3:
                println("To location touched")
                locationSpecifier = "To"
                locationToSave = toLocation
                presentViewController(lookUpSelectionController!, animated: true) {
                    println("finished presenting the lookup selector")
                }
                
            default:
                println("Unexpected index for location cell")
            }
        }
    }
    
    func locationTextFieldUpdated(sender: LocationSelectionTableViewCell) {
        //
        
    }
    
    // MARK: - TextFieldCell delegate
    func textFieldUpdated(sender: TextFieldCellTableViewCell) {
        //
        
    }
    
    // MARK: - NumSteppersCell delegate
    
    func stepperValueUpdated(sender: NumStepperCellTableViewCell) {
        if let value = sender.value, indexPath = tableView.indexPathForCell(sender as UITableViewCell) {
            switch indexPath.section {
            case 4:
                numPassengers = value
            case 5:
                numBags = value
            default:
                println("Unexpected index for stepper cell")
            }
        }
    }
    
    // MARK: - ButtonCell delegate
    
    func buttonTouched(sender: ButtonCellTableViewCell) {
        //
    }
    
    // MARK: - DateSelection delegate
    
    func dateUpdated(sender: DateSelectionTableViewCell) {
        //
    }
    
    func dateButtonToggled(sender: DateSelectionTableViewCell)  {
        // to enable cell height change, we use begin and end Updates around the assignment
        println("delegate of the toggle date button")
        
        tableView.beginUpdates()
        sender.viewExpanded = !sender.viewExpanded
        tableView.endUpdates()

    }
    
    
}

