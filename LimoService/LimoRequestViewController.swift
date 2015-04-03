//
//  LimoRequestViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoRequestViewController: UITableViewController, UITextFieldDelegate {
    
    var limoUser: LimoUser?

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var loginOrProfileBarButtonItem: UIBarButtonItem!
    
    // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginOrProfileButton()
        configureDatePicker()
        configureLookUpSelector()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("View did appear")
        setupLoginOrProfileButton()
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
            println("is linked with anon")
            self.enableSignUpButton()
        } else {
            println("is NOT linked with anon")
            self.enableLogOutButton()
        }
        removeKeyboardDisplay()
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
                if let limoUser = self.limoUser {
                    self.performSegueWithIdentifier("Select Previous Location", sender: limoUser)
                }
        })
        
        let actionCancel = UIAlertAction(title: "Cancel",
            style: .Destructive,
            handler: {(paramAction:UIAlertAction!) in
                /* Do nothing here */
        })
        
        lookUpSelectionController!.addAction(actionAddressLookUp)
        lookUpSelectionController!.addAction(actionLocalSearch)
        lookUpSelectionController!.addAction(actionPreviousLocation)
        lookUpSelectionController!.addAction(actionCancel)
    }
    
    func setupLoginOrProfileButton() {
        if let currentUser = PFUser.currentUser() {
            println("Current user is : \(currentUser)")
            let installation = PFInstallation.currentInstallation()
            installation["user"] = currentUser
            installation.saveEventually()

            loginOrProfileBarButtonItem.title = "Profile"
            loginOrProfileBarButtonItem.enabled = false
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            var query = LimoUser.query()
            query.whereKey("user", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved = \(objects.count) limoUser. This should be 1 or 0")
                    // Assume the first object is the associated limoUser
                    if let limoUser = objects.first as? LimoUser {
                        self.limoUser = limoUser
                    } else {
                        println("Going to create a new LimoUser because we have 0")
                        self.limoUser = LimoUser()
                        if let limoUser = self.limoUser {
                            println("Created a new LimoUser = \(self.limoUser)")
                            limoUser.user = currentUser
                            currentUser.saveInBackground()    // only needed to ensure the user is updated if needed
                            limoUser.saveEventually()
                        } else {
                            println("LimoUser creation failed")
                        }
                    }

                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.loginOrProfileBarButtonItem.enabled = true
            }
        } else {
            println("did not find current user")
            loginOrProfileBarButtonItem.title = "Login"
        }
    }
    
    @IBAction func loginOrProfileTarget(sender: UIBarButtonItem) {
        if sender.title == "Login" {
            login()
        } else {
            performSegueWithIdentifier("Show Profile", sender: nil)
        }
    }
    
    func configureDatePicker() {
        limoRequestDatePicker.datePickerMode = .DateAndTime
        
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 7 days from now.
        let now = NSDate()
        limoRequestDatePicker.minimumDate = now
        
        let currentCalendar = NSCalendar.currentCalendar()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 7
        
        let sevenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        limoRequestDatePicker.maximumDate = sevenDaysFromNow
        
        limoRequestDatePicker.minuteInterval = 2
        
        limoRequestDatePicker.addTarget(self, action: "updateDatePickerLabel", forControlEvents: .ValueChanged)
        
        updateDatePickerLabel()
    }
    
    func enableSignUpButton() {
        signUpButton.enabled = true
    }
    
    func enableLogOutButton() {
        logoutButton.enabled = true
    }
    
    @IBAction func signUpTouched(sender: UIButton) {
        login()
    }
    
    @IBAction func logoutTouched(sender: UIButton) {
        PFUser.logOut()
        let installation = PFInstallation.currentInstallation()
        installation.removeObjectForKey("user")
        installation.saveEventually()
        setupLoginOrProfileButton()
    }
    
    @IBAction func writeDataTouched(sender: UIButton) {
        if let from = fromLocation {
            if let to = toLocation {
                if let user = limoUser {
                    let limoRequest = LimoRequest()
                    limoRequest["from"] = from
                    limoRequest["fromString"] = from["address"]
                    limoRequest["to"] = to
                    limoRequest["toString"] = to["address"]
                    limoRequest["owner"] = user
                    limoRequest["status"] = "New"
                    limoRequest["when"] = limoRequestDatePicker.date
                    limoRequest["whenString"] = dateFormatter.stringFromDate(limoRequestDatePicker.date)
                    limoRequest.saveInBackgroundWithBlock { (succeeded, error)  in
                        if succeeded {
                            println("Succeed in creating a limo request : \(limoRequest)")
                            println("Channel is : \(limoRequest.objectId)")
                            self.subscibeToChannel(limoRequest.objectId as NSString)
                        } else {
                            println("Received error \(error)")
                        }
                    }
                } else {
                    displayAlertWithTitle("Incomplete Request", message: "Need User Infomation")
                }
            } else {
                displayAlertWithTitle("Incomplete Request", message: "Need 'To' Location")
            }
        } else {
            displayAlertWithTitle("Incomplete Request", message: "Need 'From' Location")
        }
    }
    
    func subscibeToChannel(channelName: NSString) {
        // When users indicate they are Giants fans, we subscribe them to that channel.
        let currentInstallation = PFInstallation.currentInstallation()
        let newChannel = "C\(channelName)"
        currentInstallation.addUniqueObject(newChannel, forKey: "channels")
        currentInstallation.saveInBackground()
        println("Added channel \(newChannel)")
    }
    
    func login() {
        performSegueWithIdentifier("Login", sender: nil)
     }
    
    
    @IBOutlet weak var limoRequestDatePicker: UIDatePicker!
    @IBOutlet weak var limoRequestDateLabel: UILabel!
    
    /// A date formatter to format the `date` property of `datePicker`.
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter
        }()
    
    func updateDatePickerLabel() {
        limoRequestDateLabel.text = dateFormatter.stringFromDate(limoRequestDatePicker.date)
    }

    var lookUpSelectionController:UIAlertController?
   
    var locationSpecifier = ""
    var originalLocationText = ""
    var fromLocation: LimoUserLocation?
    var toLocation: LimoUserLocation?

    @IBOutlet weak var fromLocationTextField: UITextField!
    @IBOutlet weak var toLocationTextField: UITextField!
    @IBOutlet weak var fromLocationTextView: UITextView!
    @IBOutlet weak var toLocationTextView: UITextView!
    @IBOutlet weak var fromLocationLookUp: UIButton!
    @IBOutlet weak var toLocationLookUp: UIButton!
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveTextIfNeeded(textField)
        return false
    }

    
    @IBAction func locationLookUpTouchUpInside(sender: UIButton) {
        switch sender {
        case fromLocationLookUp:
            locationSpecifier = "From"
            originalLocationText = fromLocationTextField.text
            locationToSave = fromLocation
            presentViewController(lookUpSelectionController!, animated: true) {
                println("finished presenting the lookup selector")
            }
        case toLocationLookUp:
            locationSpecifier = "To"
            originalLocationText = toLocationTextField.text
            locationToSave = toLocation
            presentViewController(lookUpSelectionController!, animated: true) {
                println("finished presenting the lookup selector")
            }

        default:
            break
        }
        
    }
    
    var locationToSave: LimoUserLocation!
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Profile":
                if segue.destinationViewController is UserProfileTableViewController {
                    let toVC = segue.destinationViewController as UserProfileTableViewController
                    toVC.limoUser = limoUser
                }
            case "Find Address":
                if segue.destinationViewController is LocationSearchTableViewController {
                    let toVC = segue.destinationViewController as LocationSearchTableViewController
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
                    let toVC = segue.destinationViewController as LocalSearchTableViewController
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
                    let toVC = segue.destinationViewController as PreviousLocationLookupViewController
                    if sender is LimoUser {
                        toVC.limoUser = sender as LimoUser
                    }
                }
            case "Login":
                if segue.destinationViewController is LoginManagerViewController {
                    let toVC = segue.destinationViewController as LoginManagerViewController
                    toVC.ownerController = self
                    println("calling login")
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
        
        if limoUser != nil {
            if sourceViewController is LocationMapViewController {
                let svc: LocationMapViewController = sourceViewController as LocationMapViewController
                if locationToSave == nil {
                    switch locationSpecifier {
                    case "From":
                        locationToSave = LimoUserLocation()
                        locationToSave["owner"] = limoUser
                        locationToSave["name"] = originalLocationText
                    case "To":
                        locationToSave = LimoUserLocation()
                        locationToSave["owner"] = limoUser
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
                let svc: PreviousLocationLookupViewController = sourceViewController as PreviousLocationLookupViewController
                if let returnedLocation = svc.selectedLocation {
                    locationToSave = returnedLocation
                } else {
                    displayAlertWithTitle("Some thing did not work", message: "Got no location from selecting previous location")
                }
            }
            updateLocationDisplay()
        }
    }

    func updateLocationDisplay() {
        switch locationSpecifier {
        case "From":
            if locationToSave["address"] is String {
                fromLocationTextView.text = locationToSave["address"] as String
            }
            if locationToSave["name"] is String {
                fromLocationTextField.text = locationToSave["name"] as String
            }
            fromLocation = locationToSave
        case "To":
            if locationToSave["address"] is String {
                toLocationTextView.text = locationToSave["address"] as String
            }
            if locationToSave["name"] is String {
                toLocationTextField.text = locationToSave["name"] as String
            }
            toLocation = locationToSave
        default:
            break
        }
    }
    
    func saveTextIfNeeded(textField: UITextField) {
        switch textField {
        case toLocationTextField:
            if toLocation != nil {
                toLocation!["name"] = textField.text
                toLocation!.saveEventually()
            }
        case fromLocationTextField:
            if fromLocation != nil {
                fromLocation!["name"] = textField.text
                fromLocation!.saveEventually()
            }
        default:
            break
        }
    }
    
    // MARK: - Helpers
    
    func removeKeyboardDisplay() {
        // This has to be called from ViewDidAppear because it does not work from unwind segue
        switch locationSpecifier {
        case "From":
            fromLocationTextField.resignFirstResponder()
        case "To":
            toLocationTextField.resignFirstResponder()
        default:
            break
        }
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

    
}

