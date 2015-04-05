//
//  LoginManagerViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LoginManagerViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var ownerController: LimoRequestViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
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
        
        navigationController?.presentViewController(logInViewController, animated: true) {
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
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        setupLoginOrProfileButton()
        navigationController?.popViewControllerAnimated(false)
    }
    
    
    // Sent to the delegate when the log in attempt fails.
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Error while failing to log in: \(error)")
    }
    
    
    // Sent to the delegate when the log in screen is dismissed.
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        println("Cancelled the login")
        println("self is \(self)")
//        setupLoginOrProfileButton()
        navigationController?.popViewControllerAnimated(false)
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
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        setupLoginOrProfileButton()
        navigationController?.popViewControllerAnimated(false)
    }
    
    // Sent to the delegate when the sign up attempt fails.
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    // Sent to the delegate when the sign up screen is dismissed.
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signUpViewController")
//        setupLoginOrProfileButton()
        navigationController?.popViewControllerAnimated(false)
    }


}
