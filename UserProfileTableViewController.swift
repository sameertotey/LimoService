//
//  UserProfileTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController, UITextFieldDelegate {

    var currentUser: PFUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // using the rootview controller's currentUser instead of setting it in the prepare for segue
        currentUser = (navigationController?.viewControllers[0] as LoginManagerViewController).currentUser
        displayCurrentValues()
    }

    func displayCurrentValues() {
        firstNameTextField.text = currentUser["firstName"] as? String
        middleNameTextField.text = currentUser["middleName"] as? String
        lastNameTextField.text = currentUser["lastName"] as? String
        phoneNumberTextField.text = currentUser["phoneNumer"] as? String
        emailTextFeild.text = currentUser["email"] as? String
        setupFacebookButton()
        if let location = currentUser["homeLocation"] as? LimoUserLocation {
            location.fetchIfNeededInBackgroundWithBlock{ (fetchedLocation, error) in
                if error == nil {
                    if let locName = fetchedLocation["name"] as? String {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.homeLocationTextField.text = locName
                        }
                    } else {
                        println("Empty name for homeLocation")
                    }
                    if let locAddress = fetchedLocation["address"] as? String {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.homeLocationTextView.text = locAddress
                        }
                    } else {
                        println("Empty address for homeLocation")
                    }
                    
                } else {
                    println("Got error for home location = \(error) ")
                }
            }
        }
        if let location = currentUser["preferredDestination"] as? LimoUserLocation {
            println("Location is \(location)")
            location.fetchIfNeededInBackgroundWithBlock{ (fetchedLocation, error) in
                if error == nil {
                    println("Found the location \(fetchedLocation)")
                    if let locName = fetchedLocation["name"] as? String {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.preferredDestinationTextField.text = locName
                        }
                    } else {
                        println("Empty name")
                    }
                    if let locAddress = fetchedLocation["address"] as? String {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.preferredDestinationTextView.text = locAddress
                        }
                    } else {
                        println("Empty address")
                    }
                    
                } else {
                    println("Got error \(error)")
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextFeild: UITextField!
    
    @IBOutlet weak var homeLocationTextField: UITextField!
    @IBOutlet weak var homeLocationTextView: UITextView!
    
    @IBOutlet weak var preferredDestinationTextField: UITextField!
    @IBOutlet weak var preferredDestinationTextView: UITextView!
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        saveTextFieldToLimoUser(textField)
        return false
    }

    func saveTextFieldToLimoUser(textField: UITextField) {
        switch textField {
        case firstNameTextField:
            currentUser["firstName"] = textField.text
        case middleNameTextField:
            currentUser["middleName"] = textField.text
        case lastNameTextField:
            currentUser["lastName"] = textField.text
        case phoneNumberTextField:
            currentUser["phoneNumer"] = textField.text
        case emailTextFeild:
            currentUser["email"] = textField.text
        case homeLocationTextField:
            setHomeLocation(textField.text)
        case preferredDestinationTextField:
            setpreferredDestination(textField.text)
            
            //        case maximumBetAmountTextField:
            //            if let number = NSNumberFormatter().numberFromString(textField.text) {
            //                gameConfiguration.maximumBet = number.doubleValue
            //                if gameConfiguration.maximumBet < gameConfiguration.minimumBet {
            //                    gameConfiguration.maximumBet = gameConfiguration.minimumBet
            //                }
            //            }
            
        default: break
            
        }
        if currentUser.isDirty() {
            currentUser.saveEventually()
        }
    }
    
    func setHomeLocation(text: String!) {
        
        if let homeLocation = currentUser["homeLocation"] as? LimoUserLocation {
            homeLocation.fetchIfNeededInBackgroundWithBlock({ (location, error)in
                if error == nil {
                    println("Found the location: \(location)")
                    location["name"] = text
                    location.saveEventually()
                } else {
                    println("Got error \(error)")
                }
            })
        } else {
            let homeLocation = LimoUserLocation()
            homeLocation["owner"] = currentUser
            homeLocation["name"] = text
            currentUser["homeLocation"] = homeLocation
        }
    }
    
    func setpreferredDestination(text: String!) {
        
        if let preferredDestinationLocation = currentUser["preferredDestination"] as? LimoUserLocation {
            preferredDestinationLocation.fetchIfNeededInBackgroundWithBlock({ (location, error)in
                if error == nil {
                    println("Found the location: \(location)")
                    location["name"] = text
                    location.saveEventually()
                } else {
                    println("Got error \(error)")
                }
            })
        } else {
            let preferredDestination = LimoUserLocation()
            preferredDestination["owner"] = currentUser
            preferredDestination["name"] = text
            currentUser["preferredDestination"] = preferredDestination
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        saveTextFieldToLimoUser(textField)
    }
    
    @IBAction func homeLocationGeoCodeButtonTouchUpInside(sender: UIButton) {
        if let locationToSave = currentUser["homeLocation"] as? LimoUserLocation {
            self.locationToSave = locationToSave
            println("The locationToSave = \(locationToSave)")
            performSegueWithIdentifier("ShowGeoCoding", sender: locationToSave["name"] as? String)
        } else {
            println("There is no location to save")
        }
    }
    
    @IBAction func preferredDestinationGeoCodeButtonTouchUpInside(sender: UIButton) {
        if let locationToSave = currentUser["preferredDestination"] as? LimoUserLocation {
            self.locationToSave = locationToSave
            println("The locationToSave = \(locationToSave)")
            performSegueWithIdentifier("ShowGeoCoding", sender: locationToSave["name"] as? String)
        } else {
            println("There is no location to save")
        }

    }
    
    var locationToSave: LimoUserLocation!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowGeoCoding":
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
            default:
                break
            }
        }
    }
    
    // logoff
    @IBAction func logoffButtonTouched(sender: UIButton) {
        PFUser.logOut()
        let installation = PFInstallation.currentInstallation()
        installation.removeObjectForKey("user")
        installation.saveEventually()
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    // facebook
    @IBOutlet weak var facebookButton: UIButton!
    
    func setupFacebookButton() {
        // Check if user is cached and linked to Facebook, if so, set title to unLink
        if let user = PFUser.currentUser() {
            if PFFacebookUtils.isLinkedWithUser(user) {
                println("connected with facebook")
                facebookButton.setTitle("Refresh", forState: .Normal)
            } else {
                println("not connected with facebook")
                facebookButton.setTitle("Link", forState: .Normal)
            }
        }
    }
    
    @IBAction func facebookButtonTouched(sender: UIButton) {
        if let titleText = sender.titleForState(.Normal) {
            if titleText == "Refresh" {
                println("going to refresh the facebook info")
                retrieveFaceboolInfo()
            } else {
                PFFacebookUtils.linkUser(PFUser.currentUser(), permissions: ["public_profile", "email"], block: { (succeeded, error) in
                    if succeeded {
                        self.retrieveFaceboolInfo()
                        self.facebookButton.setTitle("Refresh", forState: .Normal)
                    } else {
                        println("Failed to link User with Facebook. Received error \(error)")
                    }
                })
            }
        }
    }

    // get information from Facebook and update the user record
    func retrieveFaceboolInfo() {
        // Send request to Facebook
        let request = FBRequest.requestForMe()
        request.startWithCompletionHandler({ (connection, result, error) -> Void in
            if error != nil {
                println("Failed to retrieve information from Facebook. Received error \(error)")
            } else {
                var userData = result as [NSString: NSString]
                if let facebookID = userData["id"] {
                    
                }
                if let firstName = userData["first_name"] {
                    self.firstNameTextField.text = firstName
                    self.currentUser["firstName"] = firstName
                }
                if let lastName = userData["last_name"] {
                    self.lastNameTextField.text = lastName
                    self.currentUser["lastName"] = lastName
                }
                if let email = userData["email"] {
                    self.emailTextFeild.text = email
                    self.currentUser["email"] = email
                }
                if self.currentUser.isDirty() {
                    self.currentUser.saveEventually()
                }
            }
            
        })

    }
    
    // twitter
    @IBOutlet weak var twitterButton: UIButton!
    
    func setupTwitterButton() {
        // Check if user is cached and linked to Facebook, if so, set title to unLink
        if let user = PFUser.currentUser() {
            if PFTwitterUtils.isLinkedWithUser(user) {
                println("connected with twitter")
                twitterButton.setTitle("Refresh", forState: .Normal)
            } else {
                println("not connected with twitter")
                twitterButton.setTitle("Link", forState: .Normal)
            }
        }
    }
    
    @IBAction func twitterButtonTouched(sender: UIButton) {
        if let titleText = sender.titleForState(.Normal) {
            if titleText == "Refresh" {
                println("going to refresh the twitter info")
            } else {
                PFTwitterUtils.linkUser(PFUser.currentUser(), block: { (succeeded, error) in
                    if succeeded {
                        self.twitterButton.setTitle("Refresh", forState: .Normal)
                    } else {
                        println("Failed to link User with Twitter. Received error \(error)")
                    }
                })
            }
        }
    }

    // unwind from a location selection
    @IBAction func unwindToUserProfile(sender: UIStoryboardSegue)
    {
        let sourceViewController: AnyObject = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        println("The locationToSave = \(locationToSave)")

        if sourceViewController is LocationMapViewController {
            let svc: LocationMapViewController = sourceViewController as LocationMapViewController
            if locationToSave != nil && svc.placemark.location != nil {
                println("we got save location: \(svc.placemark.location)")
                let geoPoint = PFGeoPoint(location: svc.placemark.location)
                locationToSave["location"] = geoPoint
                locationToSave["address"] = svc.navigationItem.title
                println("The address reported is \(svc.navigationItem.title)")
                locationToSave.saveEventually()
            }
        }
        displayCurrentValues()
    }
}
