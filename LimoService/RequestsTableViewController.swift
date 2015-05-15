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
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()
    
    private struct UIStoryboardConstants {
        static let showRequestDetail = "Show Request Detail"
        static let showProviderMenu  = "Show Provider Menu"
    }

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        parseClassName = "LimoRequest"
        textKey = "fromString"
        pullToRefreshEnabled = true
        objectsPerPage = 20
        let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController
        currentUser = (rootVC?.viewControllers[0] as! LoginManagerViewController).currentUser
        userRole = (rootVC?.viewControllers[0] as! LoginManagerViewController).userRole

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
//        configureToolbar() 

        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let menuImage = UIImage(named: "Menu")
        let menuButton = UIButton.buttonWithType(.System) as! UIButton
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.frame = CGRectMake(0, 0, 24, 24)
        menuButton.addTarget(self, action: "goHome", forControlEvents: .TouchUpInside)
        
        let menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.leftBarButtonItem = menuBarButtonItem
    }
    
    func goHome() {
        println("go home")
        if userRole != "provider" {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            println("got to have the new workflow here")
            performSegueWithIdentifier(UIStoryboardConstants.showProviderMenu, sender: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case UIStoryboardConstants.showProviderMenu:
                println("segue to provider menu")
                if segue.destinationViewController is ProviderMenuViewController {
                    let toVC = segue.destinationViewController as! ProviderMenuViewController
                    toVC.listner = nil
                    toVC.modalPresentationStyle = .Custom
                    toVC.transitioningDelegate = self.modalTransitioningDelegate
                }
            case UIStoryboardConstants.showRequestDetail:
                println("show request details")
                if segue.destinationViewController is RequestDetailTableViewController {
                    let toVC = segue.destinationViewController as! RequestDetailTableViewController
                    toVC.limoRequest = selectedRequest
                }
            default:
                break
            }
        }
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
    
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let object = objectAtIndexPath(indexPath) {
            let limoRequest = LimoRequest(withoutDataWithObjectId: object.objectId)
            limoRequest.fetchInBackgroundWithBlock { (object, error) in
                if error != nil {
                    println("limoreq fetch failed with \(error)")
                } else  {
                    limoRequest.pinInBackgroundWithBlock() { [unowned self] (succeeded, error) in
                        if succeeded {
                            self.selectedRequest = limoRequest
                            self.performSegueWithIdentifier(UIStoryboardConstants.showRequestDetail, sender: nil)
                        }
                    }
                }
            }
        } else {
            // if we did not get an limoRequest, it must have been the "load more" cell that was selected
            loadNextPage()
        }
    }
    
    

}
