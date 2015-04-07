//
//  RequestsTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestsTableViewController: PFQueryTableViewController {

    var currentUser: PFUser!
    var userRole = ""
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "LimoRequest"
        self.textKey = "fromString"
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
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        if userRole == "provider" {
            let profileBarButtonItem = UIBarButtonItem(title: "Profile", style: .Bordered, target: self, action: "showProfile")
            self.navigationItem.leftBarButtonItem = profileBarButtonItem
        }
    }
    
    func showProfile() {
        performSegueWithIdentifier("Show Provider Profile", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: "LimoRequest")
        // provider gets to see all New requests, other users see only their own requests
        if userRole == "provider" {
            println("status key")
            query.whereKey("status", equalTo: "New")
        } else {
            println("user key")
            query.whereKey("owner", equalTo: currentUser)            // expect currentUser to be set here
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as RequestsTableViewCell
        
        cell.fromLabel.text = object.valueForKey("fromString") as? String
        cell.toLabel.text = object.valueForKey("toString") as? String
        cell.whenLabel.text = object.valueForKey("whenString") as? String
        cell.statusLabel.text = object.valueForKey("status") as? String
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Show Request Detail") {
            if segue.destinationViewController is RequestDetailViewController {
                let toVC = segue.destinationViewController as RequestDetailViewController
                toVC.currentUser = currentUser
                println("sender is \(sender)")
                if sender is UITableViewCell {
                    let index = tableView.indexPathForCell(sender as UITableViewCell)
                    if let object =  objectAtIndexPath(index){
                        toVC.limoRequest = LimoRequest(withoutDataWithObjectId: object.objectId)
                    } else {
                        alert("did not find the right object")
                    }
                }
            }
            
        }
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        selectedLocation = objectAtIndexPath(indexPath) as? LimoUserLocation
//        performSegueWithIdentifier("Return Selection", sender: nil)
    }
    
    
    // MARK: - Table view data source
    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 0
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

}
