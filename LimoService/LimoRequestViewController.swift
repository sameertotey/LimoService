//
//  LimoRequestViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoRequestViewController: UITableViewController , PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITextFieldDelegate {
    
    var limoUser: LimoUser?

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var loginOrProfileBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupLoginOrProfileButton()
        configureDatePicker()
        configureLookUpSelector()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("View did appear")
        if let currentUser = PFUser.currentUser() {
            println("Found current user")
            println("Current user is : \(currentUser)")
        } else {
            println("did not find current user")
        }
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
            println("is linked with anon")
            self.enableSignUpButton()
        } else {
            println("is NOT linked with anon")
            self.enableLogOutButton()
        }
    }

    func setupLoginOrProfileButton() {
        if let currentUser = PFUser.currentUser() {
            println("Found current user")
            println("Current user is : \(currentUser)")
            
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
                            currentUser.saveInBackground()    // only needed to ensure the user is updated is needed
                            limoUser.saveEventually()
                        } else {
                            println("LimoUser creation failed")
                        }
                    }

                    if let objects = objects as? [PFObject] {
                        println("Print all the LimoUser objects for the current user ---")
                        for object in objects {
                            println(object.objectId)
                        }
                        println("End LimoUser objects")
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

            default:
                break
            }
        }
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
        setupLoginOrProfileButton()
    }
    
    @IBAction func writeDataTouched(sender: UIButton) {
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        if let currentUser = PFUser.currentUser() {
//            println("Current user is \(currentUser)")
//            testObject["username"] = currentUser.username
//            testObject["user"] = currentUser
//            testObject["abc"] = "123"
//        } else
//        {
//            println("There is no user here")
//        }
//        testObject.saveEventually()
        if let from = fromLocation {
            if let to = toLocation {
                if let user = limoUser {
                    let limoRequest = LimoRequest()
                    limoRequest["from"] = from
                    limoRequest["to"] = to
                    limoRequest["owner"] = user
                    limoRequest["status"] = "New"
                    limoRequest["when"] = limoRequestDatePicker.date
                    limoRequest.saveInBackgroundWithBlock({ (succeeded, error)  in
                        if succeeded {
                            println("Succeed in creating a limo request")
                        } else {
                            println("Received error \(error)")
                        }
                    })
                }
            }
        }
        
        
    }
    
    func login() {
        // Create the log in view controller
        var logInViewController = LimoUserLogInViewController()
        logInViewController.delegate = self // Set ourselves as the delegate
        
        // add the facebook field to the login controller
        logInViewController.fields = .Default |  .Facebook | .Twitter
        
        // Create the sign up view controller
        var signUpViewController = LimoUserSignUpViewController()
        signUpViewController.delegate = self // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        logInViewController.signUpController = signUpViewController
        
        logInViewController.emailAsUsername = true
        // Present the log in view controller
        logInViewController.modalTransitionStyle = .CoverVertical
        logInViewController.modalPresentationStyle = .FullScreen
        presentViewController(logInViewController, animated: true) {
            println("Finished with the log in view controller")
        }
    }
    
    
    
    // MARK: - PFLoginViewControllerDelegate
    
    // Sent to the delegate to determine whether the log in request should be submitted to the server.

    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        // Check if both fields are completed
        if let username = username {
            if let password = password {
                if !username.isEmpty && !password.isEmpty {
                    return true // Begin login process
                }
            }
        }
        // Create the AlertController
        let alertController: UIAlertController = UIAlertController(title: "Missing Information", message: "Make sure you fill out both username and password information!", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController.addAction(OKAction)
        //Create and add first option action
        
        //Present the AlertController
        alertController.modalTransitionStyle = .CoverVertical
        alertController.modalPresentationStyle = .FullScreen
        logInController.presentViewController(alertController, animated: true, completion: nil)
        
        return false
    }
    
    // Sent to the delegate when a PFUser is logged in.
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("Did login the user \(user)")
        dismissViewControllerAnimated(true, completion: nil)
        setupLoginOrProfileButton()
    }
    
    
    // Sent to the delegate when the log in attempt fails.
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Error while failing to log in: \(error)")
    }
    
    
    // Sent to the delegate when the log in screen is dismissed.
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        println("Cancelled the login")
        setupLoginOrProfileButton()
    }
    
    
    // MARK: - PFSignUpViewControllerDelegate
    
    // Sent to the delegate to determine whether the sign up request should be submitted to the server.
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        var informationComplete = true
        // loop through all of the submitted data
        for (key, value) in info {
            if let stringValue = value as? String {
                if stringValue.isEmpty {
                    informationComplete = false
                    break
                }
            } else {
                // we have a nil
                informationComplete = false
                break
            }
        }
        // Display an alert if a field wasn't completed
        if !informationComplete {
            // Create the AlertController
            let alertController: UIAlertController = UIAlertController(title: "Missing Information", message: "Make sure you fill out all required fields!", preferredStyle: .Alert)
            
            //Create and add the Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            //Create and add first option action
            
            //Present the AlertController
            alertController.modalTransitionStyle = .CoverVertical
            alertController.modalPresentationStyle = .FullScreen
            signUpController.presentViewController(alertController, animated: true, completion: nil)
        }
        
        return informationComplete
    }

    // Sent to the delegate when a PFUser is signed up.
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        println("Did sign up user")
        dismissViewControllerAnimated(true, completion: nil)
        setupLoginOrProfileButton()
    }
    
    // Sent to the delegate when the sign up attempt fails.
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    // Sent to the delegate when the sign up screen is dismissed.
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signUpViewController")
        setupLoginOrProfileButton()
    }
    
    @IBOutlet weak var limoRequestDatePicker: UIDatePicker!
    @IBOutlet weak var limoRequestDateLabel: UILabel!
    
    // MARK: Configuration
    
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
//        saveTextFieldToLimoUser(textField)
        return false
    }

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
    
    // unwind from a location selection
    @IBAction func unwindToUserProfile(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        println("The locationToSave = \(locationToSave)")
        
        if sourceViewController is LocationMapViewController {
            let svc: LocationMapViewController = sourceViewController as LocationMapViewController
            if locationToSave == nil {
                switch locationSpecifier {
                case "From":
                    locationToSave = LimoUserLocation()
                    locationToSave["owner"] = limoUser
                    locationToSave["name"] = originalLocationText
                    fromLocation = locationToSave
                case "To":
                    locationToSave = LimoUserLocation()
                    locationToSave["owner"] = limoUser
                    locationToSave["name"] = originalLocationText
                    toLocation = locationToSave
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
        }
        updateLocationDisplay()
    }

    func updateLocationDisplay() {
        switch locationSpecifier {
        case "From":
            if locationToSave["address"] is String {
                fromLocationTextView.text = locationToSave["address"] as String
            }
        case "To":
            if locationToSave["address"] is String {
                toLocationTextView.text = locationToSave["address"] as String
            }

        default:
            break
        }
    }
    
}

