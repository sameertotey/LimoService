//
//  LimoRequestViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoRequestViewController: UITableViewController, UITextFieldDelegate {
    
    var currentUser: PFUser!
    var userFetched = false
    var userRole = ""

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var loginOrProfileBarButtonItem: UIBarButtonItem!
    
    // MARK: - View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginOrProfileButton()
        configureDatePicker()
        configureLookUpSelector()
        configureSteppers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("View did appear")
        setupLoginOrProfileButton()
        if currentUser != nil {
            if !userFetched {
                currentUser.fetchInBackgroundWithBlock({ (user, error) in
                    if error == nil {
                        self.userFetched = true
                        let installation = PFInstallation.currentInstallation()
                        installation["user"] = self.currentUser
                        installation.saveEventually()
                        let limoUser = user as PFObject
                        
                        if let limoUserRole = limoUser["role"] as String? {
                            self.userRole = limoUserRole
                            if self.userRole == "provider" {
                                println("This is a provider...")
                                if self.navigationController?.topViewController == self {
                                    self.performSegueWithIdentifier("Requests", sender: nil)
                                }
                            } else {
                                println("This is not a provider")
                            }
                        }
                    } else {
                        println("Received error \(error)")
                    }
                })
            }
            if let role = currentUser["role"] as? String {
                userRole = role
            }
            if userRole == "provider" {
                println("This is a provider...")
                self.performSegueWithIdentifier("Requests", sender: nil)
            } else {
                println("This is not a provider")
            }
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
                self.performSegueWithIdentifier("Select Previous Location", sender: nil)
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
            self.currentUser = currentUser
            loginOrProfileBarButtonItem.title = "Profile"
            self.loginOrProfileBarButtonItem.enabled = true
        } else {
            println("did not find current user")
            login()
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
    
    @IBAction func createTheRequest(sender: UIButton) {
        if let from = fromLocation {
            if let to = toLocation {
                if let user = currentUser {
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
                            self.resetLocationsAndDate()
                            self.performSegueWithIdentifier("Requests", sender: nil)
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
    var locationToSave: LimoUserLocation!

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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Profile":
                if segue.destinationViewController is UserProfileTableViewController {
                    let toVC = segue.destinationViewController as UserProfileTableViewController
                    toVC.currentUser = currentUser
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
                    toVC.currentUser = currentUser
                }
            case "Login":
                if segue.destinationViewController is LoginManagerViewController {
                    let toVC = segue.destinationViewController as LoginManagerViewController
                    toVC.ownerController = self
                    println("calling login")
                }
            case "Requests":
                if segue.destinationViewController is RequestsTableViewController {
                    let toVC = segue.destinationViewController as RequestsTableViewController
                    toVC.currentUser = currentUser
                    toVC.userRole = userRole
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
                let svc: LocationMapViewController = sourceViewController as LocationMapViewController
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
    
    // Num passengers
    
    @IBOutlet weak var numPassengersStepper: UIStepper!
    @IBOutlet weak var numPassengersLabel: UILabel!
    
    @IBOutlet weak var numBagsStepper: UIStepper!
    @IBOutlet weak var numBagsLabel: UILabel!
    
    func configureSteppers() {
        numPassengersStepper.value = 1
        numPassengersStepper.minimumValue = 0
        numPassengersStepper.maximumValue = 10
        numPassengersStepper.stepValue = 1
        
        numBagsStepper.value = 0
        numBagsStepper.minimumValue = 0
        numBagsStepper.maximumValue = 10
        numBagsStepper.stepValue = 1
        
        numPassengersLabel.text = "\(Int(numPassengersStepper.value))"
        numBagsLabel.text = "\(Int(numBagsStepper.value))"
    }

    @IBAction func stepperValueChanged(sender: UIStepper) {
        switch sender {
        case numPassengersStepper:
            numPassengersLabel.text = "\(Int(numPassengersStepper.value))"
        case numBagsStepper:
            numBagsLabel.text = "\(Int(numBagsStepper.value))"
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
    
    func resetLocationsAndDate() {
        locationSpecifier = ""
        originalLocationText = ""
        fromLocation = nil
        toLocation = nil
        configureDatePicker()
        fromLocationTextField.text = ""
        toLocationTextField.text = ""
        fromLocationTextView.text = ""
        toLocationTextView.text = ""
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

