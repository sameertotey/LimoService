//
//  RequestsTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestsTableViewController: PFQueryTableViewController {

    weak var currentUser: PFUser!
    var userRole = ""
    var selectedRequest: LimoRequest?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        parseClassName = "LimoRequest"
        textKey = "fromString"
        pullToRefreshEnabled = true
        objectsPerPage = 20
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
        currentUser = (rootVC?.viewControllers[0] as! LoginManagerViewController).currentUser

        
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
        println("loading \(__FILE__)")
        configureToolbar() 

        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        let profileBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: "showProfile")

        if userRole == "provider" {
            self.navigationItem.leftBarButtonItem = profileBarButtonItem
        } else {
            self.navigationItem.rightBarButtonItem = profileBarButtonItem
        }
        let homeBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain, target: self, action: "goHome")
        navigationItem.leftBarButtonItem = homeBarButtonItem
        
    }
    
    func goHome() {
        println("go home")
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    deinit {
        println("deallocing \(__FILE__)")
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.toolbarHidden = true
    }

    func configureToolbar() {
        navigationController?.toolbarHidden = false
        let profileBarButtonItem = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: "showProfile")
        setToolbarItems([profileBarButtonItem], animated: false)
    }

    func showProfile() {
        performSegueWithIdentifier("Show Provider Profile", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func queryForTable() -> PFQuery {
//        let query = PFQuery(className: "LimoRequest")
        if let query = LimoRequest.query() {
            // provider gets to see all New requests and requests assignedTo, other users see only their own requests
            if userRole == "provider" {
                println("status key")
                query.whereKey("status", equalTo: "New")
                let assignedToQuery = PFQuery(className: "LimoRequest")
                assignedToQuery.whereKey("assignedTo", equalTo: currentUser)
                let newQuery = PFQuery.orQueryWithSubqueries([assignedToQuery, query])
                newQuery.orderByDescending("createdAt")
                newQuery.limit = 200;
                return newQuery
            } else {
                println("user key")
                query.whereKey("owner", equalTo: currentUser)            // expect currentUser to be set here
                query.orderByDescending("createdAt")
                query.limit = 200;
                return query
            }
        } else {
            return  PFQuery(className: "LimoRequest")    // need this because of optional unwrapping
        }
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath!) -> PFObject? {
        var obj : PFObject? = nil
        if let allObjects = self.objects {
            if indexPath.row < allObjects.count {
                obj = allObjects[indexPath.row] as? PFObject
            }
        }
        return obj
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("requestCell", forIndexPath: indexPath) as! RequestsTableViewCell
        
        cell.fromTextField.text = object.valueForKey("fromName") as? String
        cell.toTextField.text = object.valueForKey("toName") as? String
        cell.whenLabel.text = object.valueForKey("whenString") as? String
        if let status = object.valueForKey("status") as? String {
            switch status {
            case "New":
//                cell.statusIndicatorView.backgroundColor = UIColor(red: 204.0/255, green: 255.0/255, blue: 102.0/255, alpha: 1.0)
                cell.statusIndicatorView.backgroundColor = UIColor.greenColor()
            case "Accepted":
//                cell.statusIndicatorView.backgroundColor = UIColor(red: 41.0/255, green: 248.0/255, blue: 255.0/255, alpha: 1.0)
                cell.statusIndicatorView.backgroundColor = UIColor.yellowColor()

            case "Closed":
//                cell.statusIndicatorView.backgroundColor = UIColor(red: 200.0/255, green: 172.0/255, blue: 172.0/255, alpha: 1.0)
                cell.statusIndicatorView.backgroundColor = UIColor.grayColor()

            case "Cancelled":
//                cell.statusIndicatorView.backgroundColor = UIColor(red: 255.0/255, green: 107.0/255, blue: 102.0/255, alpha: 1.0)
                cell.statusIndicatorView.backgroundColor = UIColor.redColor()

            default:
                cell.backgroundColor = UIColor.whiteColor()
            }

        }
         return cell
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//            case "Display Request Details":
//                println("Display Request Details")
//                if let toVC = segue.destinationViewController as? MapLocationSelectViewController {
//                    if sender is UITableViewCell {
//                        let index = tableView.indexPathForCell(sender as! UITableViewCell)
//                        if let object =  objectAtIndexPath(index){
//                            toVC.limoRequest = LimoRequest(withoutDataWithObjectId: object.objectId)
//                            toVC.currentUser = currentUser
//                            toVC.userRole = userRole
//                        } else {
//                            alert("did not find the right object")
//                        }
//                    }
//                }
//            case "Show Request Detail":
//                if segue.destinationViewController is UINavigationController {
//                    if let toVC = segue.destinationViewController.viewControllers?.first as? RequestDetailTableViewController {
//                        toVC.currentUser = currentUser
//                        toVC.userRole = userRole
//                        if sender is UITableViewCell {
//                            let index = tableView.indexPathForCell(sender as! UITableViewCell)
//                            if let object =  objectAtIndexPath(index){
//                                toVC.limoRequest = LimoRequest(withoutDataWithObjectId: object.objectId)
//                            } else {
//                                alert("did not find the right object")
//                            }
//                        }
//                    }
//                }
//            default:
//            break
//            }
//        }
//    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRequest = objectAtIndexPath(indexPath) as? LimoRequest
        performSegueWithIdentifier("go Home", sender: nil)
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
