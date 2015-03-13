//
//  ViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/11/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        signUpButton.enabled = false
//        logoutButton.enabled = false
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
        } else
        {
            println("There is no user here")
        }
        testObject.saveInBackground()

    }
    
    func login() {
        // Create the log in view controller
        var logInViewController = PFLogInViewController()
        logInViewController.delegate = self // Set ourselves as the delegate
        
        // add the facebook field to the login controller
        logInViewController.fields = .Default |  .Facebook | .Twitter
        
        // Create the sign up view controller
        var signUpViewController = PFSignUpViewController()
        signUpViewController.delegate = self // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        logInViewController.signUpController = signUpViewController
        
        // Present the log in view controller
        modalTransitionStyle = .FlipHorizontal
        modalPresentationStyle = .FullScreen
        presentViewController(logInViewController, animated: true) {
            println("Finished with the log in view controller")
        }
    }
    
    
    
    // MARK: - PFLoginViewControllerDelegate
    
    // Sent to the delegate to determine whether the log in request should be submitted to the server.
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        // Check if both fields are completed
        if let username1 = username {
            if let password1 = password {
                if !username1.isEmpty && !password1.isEmpty {
                    return true // Begin login process
                }
            }
        }
        // Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Missing Information", message: "Make sure you fill out all of the information!", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
//        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            //Code for launching the camera goes here
//        }
//        actionSheetController.addAction(takePictureAction)
//        //Create and add a second option action
//        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
//            //Code for picking from camera roll goes here
//        }
//        actionSheetController.addAction(choosePictureAction)
//        
//        //We need to provide a popover sourceView when using it on iPad
//        actionSheetController.popoverPresentationController?.sourceView = sender as UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
        return false
    }
    
    // Sent to the delegate when a PFUser is logged in.
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        dismissViewControllerAnimated(true, completion: nil)
        println("Did login the user \(user)")
    }
    
    
    // Sent to the delegate when the log in attempt fails.
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Error while failing to log in: \(error)")
    }
    
    
    // Sent to the delegate when the log in screen is dismissed.
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        println("Cancelled the login")
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
            let actionSheetController: UIAlertController = UIAlertController(title: "Missing Information", message: "Make sure you fill out all of the information!", preferredStyle: .ActionSheet)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            //Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)

        }
        
        return informationComplete
    }
    
    
    // Sent to the delegate when a PFUser is signed up.
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        println("Did sign up user")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Sent to the delegate when the sign up attempt fails.
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    
    // Sent to the delegate when the sign up screen is dismissed.
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signUpViewController")
    }

}

