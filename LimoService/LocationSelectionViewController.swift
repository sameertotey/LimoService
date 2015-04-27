//
//  LocationSelectionViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/25/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectionViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDelegate {
    
    // MARK: Properties
    var searchResults = [MKMapItem]()
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    // Secondary search results table view.
    var resultsTableController: LocationResultsTableViewController!
    
    // text in the search bar
    var searchText = ""
    let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
    
    var userLocation: CLLocation!
    var searchRegion: MKCoordinateRegion!
    var searchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    
    var selectedPlacemark: CLPlacemark!
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchText
        
        resultsTableController = LocationResultsTableViewController()
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called from this controller.
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // default is True
        searchController.hidesNavigationBarDuringPresentation = false // default is True
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        // Do any additional setup after loading the view.
        //        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveLocation")
        //        navigationItem.rightBarButtonItem = saveBarButtonItem
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.searchBar.text = searchText
        searchController.active = true
        searchController.searchBar.becomeFirstResponder()
    }
    
     // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    
    func presentSearchController(searchController: UISearchController) {
        //        NSLog(__FUNCTION__)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        //        NSLog(__FUNCTION__)
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        //        NSLog(__FUNCTION__)
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        //        NSLog(__FUNCTION__)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        //        NSLog(__FUNCTION__)
    }
    
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Update the filtered array based on the search text.
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        searchText = strippedString
        println("inside update search results for search controller: \(searchText)")
        let searchItems = strippedString.componentsSeparatedByString(" ") as [String]
        
        // cancel previous in flight search
        localSearch?.cancel()
        
        if count(strippedString) >= 3 {
            // add minimal delay to search to avoid searching for something outdated
            cancelDelayed("search")
            delayed(0.1, name: "search") {
                self.performLocalSearch(strippedString)
            }
        } // else do nothing
    }
    
    typealias Closure = ()->()
    var closures = [String: Closure]()
    
    func delayed(delay: Double, name: String, closure: Closure) {
        // store the closure to execute in the closures dictionary
        closures[name] = closure
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue()) {
                if let closure = self.closures[name] {
                    closure()
                    self.closures[name] = nil
                }
        }
    }
    
    func cancelDelayed(name: String) {
        closures[name] = nil
    }
    
    func performLocalSearch(searchString: NSString) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchString as String
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        request.region = MKCoordinateRegion( center: userLocation.coordinate, span: span)
        request.region = searchRegion
        localSearch = MKLocalSearch(request: request)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        localSearch.startWithCompletionHandler{
            (response: MKLocalSearchResponse!, error: NSError!) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error == nil {
                var placemarks = [CLPlacemark]()
                for item in response.mapItems as! [MKMapItem]{
                    println("Item name = \(item.name)")
                    println("Item phone number = \(item.phoneNumber)")
                    println("Item url = \(item.url)")
                    println("Item location = \(item.placemark.location)")
                    placemarks.append(item.placemark)
                }
                self.searchResults = response.mapItems as! [MKMapItem]
                // Hand over the filtered results to our search results table.
                println("received \(placemarks.count) results")
                let resultsController = self.searchController.searchResultsController as! LocationResultsTableViewController
                resultsController.possibleMatches = placemarks
                resultsController.searchText = self.searchText
                resultsController.tableView.reloadData()
            } else {
                println("Received error \(error) for search \(searchString)")
            }
        }
    }
    
    // MARK: - Helpers
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
     // MARK: - Table View Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Check to see which table view cell was selected.
        let attributedString = resultsTableController.attributedAddressStringAtIndexPath(indexPath)
        let neededSize = attributedString.size()
        return ceil(neededSize.height) + 20
    }
    
    // We use this to be the tableview delegate of the search controller so that we can push the map view form this controller and not the results table controller, which is presented by this controller.
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        // Check to see which table view cell was selected.
//        let selectedPlacemark = resultsTableController.possibleMatches[indexPath.row]
//        
//        // Set up the detail view controller to show.
//        let mapViewController = LocationMapViewController.forPlacemark(selectedPlacemark)
//        
//        // Note: Should not be necessary but current iOS 8.0 bug requires it.
//        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
//        
//        navigationController!.pushViewController(mapViewController, animated: true)
        
        selectedPlacemark = resultsTableController.possibleMatches[indexPath.row]
        performSegueWithIdentifier("return location", sender: nil)
        
    }
    
}
