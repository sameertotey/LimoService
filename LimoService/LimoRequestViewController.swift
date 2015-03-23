//
//  LimoRequestViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoRequestViewController: UITableViewController , PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var limoUser: LimoUser?

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var loginOrProfileBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupLoginOrProfileButton()
        configureDatePicker()
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
    }
    
    @IBAction func writeDataTouched(sender: UIButton) {
        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        if let currentUser = PFUser.currentUser() {
            println("Current user is \(currentUser)")
            testObject["username"] = currentUser.username
            testObject["user"] = currentUser
            testObject["abc"] = "123"
        } else
        {
            println("There is no user here")
        }
        testObject.saveEventually()
        
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

}

