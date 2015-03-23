//
//  UserProfileTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class UserProfileTableViewController: UITableViewController, UITextFieldDelegate {

    var limoUser: LimoUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        displayCurrentValues()
    }

    func displayCurrentValues() {
        firstNameTextField.text = limoUser.firstName
        middleNameTextField.text = limoUser.middleName
        lastNameTextField.text = limoUser.lastName
        phoneNumberTextField.text = limoUser.phoneNumer
        emailTextFeild.text = limoUser.user?.email
        if let location = limoUser.homeLocation {
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
        if let location = limoUser.preferredDestination {
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

    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var numRows: Int
        switch section {
        case 0:
            numRows = 3
        case 1:
            numRows = 1
        default:
            numRows = 0
        }
        return numRows
    }

*/
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
            limoUser.firstName = textField.text
        case middleNameTextField:
            limoUser.middleName = textField.text
        case lastNameTextField:
            limoUser.lastName = textField.text
        case phoneNumberTextField:
            limoUser.phoneNumer = textField.text
        case emailTextFeild:
            limoUser.user?.email = textField.text
            limoUser.user?.saveEventually()
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
        if limoUser.isDirty() {
            limoUser.saveEventually()
        }
    }
    
    func setHomeLocation(text: String!) {
        println("The home location is : \(limoUser.homeLocation) :text - \(text)")
        
        if let homeLocation = limoUser.homeLocation {
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
            limoUser.homeLocation = LimoUserLocation()
            limoUser.homeLocation?.name = text
        }
        
    }
    
    func setpreferredDestination(text: String!) {
        println("The prefered destination location is : \(limoUser.preferredDestination) :text - \(text)")
        
        if let preferredDestinationLocation = limoUser.preferredDestination {
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
            limoUser.preferredDestination = LimoUserLocation()
            limoUser.preferredDestination?.name = text
        }
        
    }

    func textFieldDidEndEditing(textField: UITextField) {
        saveTextFieldToLimoUser(textField)
    }
    
    @IBAction func homeLocationGeoCodeButtonTouchUpInside(sender: UIButton) {
        if let locationToSave = limoUser.homeLocation {
            self.locationToSave = locationToSave
            println("The locationToSave = \(locationToSave)")
            performSegueWithIdentifier("ShowGeoCoding", sender: locationToSave["name"] as? String)
        } else {
            println("There is no location to save")
        }
    }
    
    @IBAction func preferredDestinationGeoCodeButtonTouchUpInside(sender: UIButton) {
        if let locationToSave = limoUser.preferredDestination {
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
                homeLocationTextView.text = svc.navigationItem.title
                locationToSave.saveEventually()
            }
        }
        displayCurrentValues()
    }
}
