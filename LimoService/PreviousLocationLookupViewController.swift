//
//  PreviousLocationLookupViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/1/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class PreviousLocationLookupViewController: PFQueryTableViewController {
    
    var limoUser: LimoUser!
    var selectedLocation: LimoUserLocation?

    override init!(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "LimoUserLocation"
//        self.textKey = "address"
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 20
        
    }
    
    private func alert(message : String) {
        let alert = UIAlertController(title: "Oops something went wrong.", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default) { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }
        alert.addAction(settings)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: "LimoUserLocation")
        query.whereKey("owner", equalTo: limoUser)            // expect limoUser to be set here
        query.orderByDescending("createdAt")
        query.limit = 200;

        return query
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject! {
        var obj : PFObject? = nil
        if(indexPath.row < self.objects.count){
            obj = self.objects[indexPath.row] as? PFObject
        }
        return obj
    }
    
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as LocationLookupTableViewCell
        
        cell.nameLabel.text = object.valueForKey("name") as? String
        cell.addressLabel.text = object.valueForKey("address") as? String
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "return the Location"){
            
        }
    }

    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedLocation = objectAtIndexPath(indexPath) as? LimoUserLocation
        performSegueWithIdentifier("Return Selection", sender: nil)
    }
    
}