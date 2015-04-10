//
//  LoginManagerViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LoginManagerViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var currentUser: PFUser! {
        didSet {
            println("Current User = \(currentUser) oldValue = \(oldValue)")
            if currentUser != nil {
                userFetched = false
                userRole = ""
                fetchTheUser()
            }
        }
    }
    var userFetched = false
    var userRole = ""
    
    private struct UIStoryboardConstants {
        static let showRequests = "Show Requests"
        static let makeRequest = "Make a Request"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        route()
    }
    
    func route() {
        if let currentUser = PFUser.currentUser() {
            self.currentUser = currentUser
        } else {
            println("did not find current user")
            login()
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
        
        navigationController?.presentViewController(logInViewController, animated: true) {
            println("Finished with the log in view controller")
        }
    }
    
    func fetchTheUser() {
        currentUser.fetchInBackgroundWithBlock{ (user, error) in
            if error == nil {
                self.userFetched = true
                let installation = PFInstallation.currentInstallation()
                installation["user"] = user
                installation.saveEventually()
                
                if let user = user, limoUserRole = user["role"] as? String {
                    self.userRole = limoUserRole
                    if self.userRole == "provider" {
                        println("This is a provider...")
                        self.performSegueWithIdentifier(UIStoryboardConstants.showRequests, sender: nil)
                    } else {
                        println("This is not a provider")
                        self.performSegueWithIdentifier(UIStoryboardConstants.makeRequest, sender: nil)
                    }
                } else {
                    println("There is no role")
                    self.performSegueWithIdentifier(UIStoryboardConstants.makeRequest, sender: nil)
                }
            } else {
                println("Received error while fetching user: \(error) moving on to login")
                self.login()
//                self.performSegueWithIdentifier(UIStoryboardConstants.showRequests, sender: nil)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
             case "Make a Request":
                if segue.destinationViewController is LimoRequestViewController {
                    let toVC = segue.destinationViewController as! LimoRequestViewController
                    toVC.currentUser = currentUser
                }
            case "Show Requests":
                if segue.destinationViewController is RequestsTableViewController {
                    let toVC = segue.destinationViewController as! RequestsTableViewController
                    toVC.currentUser = currentUser
                    toVC.userRole = userRole
                }
                
            default:
                break
            }
        }
    }

    
    // MARK: - PFLoginViewControllerDelegate
    
    // Sent to the delegate to determine whether the log in request should be submitted to the server.
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        // Check if both fields are completed
        if !username.isEmpty && !password.isEmpty {
            return true // Begin login process
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
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        println("Did login the user \(user)")
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        setupLoginOrProfileButton()
//        navigationController?.popViewControllerAnimated(false)
        currentUser = user
    }
    
    
    // Sent to the delegate when the log in attempt fails.
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Error while failing to log in: \(error)")
    }
    
    
    // Sent to the delegate when the log in screen is dismissed.
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        println("Cancelled the login")
        println("self is \(self)")
//        setupLoginOrProfileButton()
//        navigationController?.popViewControllerAnimated(false)
    }
    
    
    // MARK: - PFSignUpViewControllerDelegate
    
    // Sent to the delegate to determine whether the sign up request should be submitted to the server.
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
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
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        println("Did sign up user")
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
//        setupLoginOrProfileButton()
//        navigationController?.popViewControllerAnimated(false)
        currentUser = user
    }
    
    // Sent to the delegate when the sign up attempt fails.
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up")
    }
    
    // Sent to the delegate when the sign up screen is dismissed.
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User dismissed the signUpViewController")
//        setupLoginOrProfileButton()
//        navigationController?.popViewControllerAnimated(false)
    }


}
