//
//  LocalSearchTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/23/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import MapKit

class LocalSearchTableViewController: UITableViewController,UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: Properties
    var mapView: MKMapView!
    var locationManager: CLLocationManager?

    var searchResults = [MKMapItem]()
    
    // The following 2 properties are set in viewDidLoad(),
    // They an implicitly unwrapped optional because they are used in many other places throughout this view controller
    //
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var resultsTableController: LocationResultsTableViewController!
    
    // text in the search bar
    var searchText = ""
    let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
    
    //
    var userLocation: CLLocation!
    var searchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    
    func mapView(mapView: MKMapView!,
        didFailToLocateUserWithError error: NSError!) {
            displayAlertWithTitle("Failed",
                message: "Could not get the user's location")
    }
    
    func locationManager(manager: CLLocationManager!,
        didUpdateToLocation newLocation: CLLocation!,
        fromLocation oldLocation: CLLocation!){
            println("Latitude = \(newLocation.coordinate.latitude)")
            println("Longitude = \(newLocation.coordinate.longitude)")
            self.userLocation = newLocation
            if searchText != "" {
                performLocalSearch(searchText)
            }

            
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
            println("Location manager failed with error = \(error)")
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
      }

    // need to pass search text as an parameter
    func performLocalSearch(searchString: NSString) {
        if userLocation != nil {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchString
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            
            request.region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: span)
            
            localSearch = MKLocalSearch(request: request)
            
            localSearch.startWithCompletionHandler{
                (response: MKLocalSearchResponse!, error: NSError!) in
                
                if error == nil {
                    var placemarks = [CLPlacemark]()
                    for item in response.mapItems as [MKMapItem]{
                        
                        println("Item name = \(item.name)")
                        println("Item phone number = \(item.phoneNumber)")
                        println("Item url = \(item.url)")
                        println("Item location = \(item.placemark.location)")
                        placemarks.append(item.placemark)
                    }
                    
                    self.searchResults = response.mapItems as [MKMapItem]
                    // Hand over the filtered results to our search results table.
                    println("received \(placemarks.count) results")
                    let resultsController = self.searchController.searchResultsController as LocationResultsTableViewController
                    resultsController.possibleMatches = placemarks
                    resultsController.searchText = self.searchText
                    resultsController.tableView.reloadData()

                    
                } else {
                    println("Received error \(error) for search \(searchString)")
                }
            }
        }
    }

    /* The authorization status of the user has changed, we need to react
    to that so that if she has authorized our app to to view her location,
    we will accordingly attempt to do so */
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus){
            
            print("The authorization status of location services is changed to: ")
            
            switch CLLocationManager.authorizationStatus(){
            case .Denied:
                println("Denied")
            case .NotDetermined:
                println("Not determined")
            case .Restricted:
                println("Restricted")
            default:
//                showUserLocationOnMapView()
                println("Now you have the authorization for location services.")
                manager.startUpdatingLocation()
            }
            
    }

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView()

        searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchText
        
        
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Authorized",
                    message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                locationManager = CLLocationManager()
                if let manager = locationManager {
                    manager.delegate = self
                    manager.desiredAccuracy = kCLLocationAccuracyKilometer
                    // Set a movement threshold for new events.
                    manager.distanceFilter = 500; // meters
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                /* Restrictions have been applied, we have no access
                to location services */
                displayAlertWithTitle("Restricted",
                    message: "Location services are not allowed for this app")
            default:
//                showUserLocationOnMapView()
                println("We have authorization to display location")
                if locationManager == nil {
                    locationManager = CLLocationManager()
                }
                if let manager = locationManager {
                    manager.delegate = self
                    manager.desiredAccuracy = kCLLocationAccuracyKilometer
                    // Set a movement threshold for new events.
                    manager.distanceFilter = 500; // meters
                    manager.startUpdatingLocation()
                }
            }
            
            
        } else {
            /* Location services are not enabled.
            Take appropriate action: for instance, prompt the
            user to enable the location services */
            println("Location services are not enabled")
        }

        
        resultsTableController = LocationResultsTableViewController()

        // register the cell for both table views
        tableView.registerClass(LocationTableViewCell.self, forCellReuseIdentifier: "locationCell")
        
        
        // We want to be the delegate for our filtered table so didSelectRowAtIndexPath(_:) is called for both tables.
        resultsTableController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // default is True
        searchController.hidesNavigationBarDuringPresentation = false // default is True
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        //        searchController.searchBar.text = searchText
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        //        geoCoder?.geocodeAddressString(searchText) { placemarks, error in
        //            if error == nil {
        //                self.searchResults = placemarks as [CLPlacemark]
        //                self.tableView.reloadData()
        //            } else {
        //                println("Error in geocoding: \(error) for string: \(self.searchText)")
        //
        //            }
        //            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //        }
        searchController.searchBar.text = searchText
        searchController.active = true
        //        searchController.searchBar.becomeFirstResponder()
        if searchText != "" {
            performLocalSearch(searchText)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }

    //destroy the manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    
    func presentSearchController(searchController: UISearchController) {
        NSLog(__FUNCTION__)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        NSLog(__FUNCTION__)
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        NSLog(__FUNCTION__)
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        NSLog(__FUNCTION__)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        NSLog(__FUNCTION__)
    }
    
    
    func performSearchForString(searchString: String)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        performLocalSearch(searchString)
//        geoCoder?.geocodeAddressString(searchString) { placemarks, error in
//            if error == nil {
//                self.searchResults = placemarks as [CLPlacemark]
//                // Hand over the filtered results to our search results table.
//                println("received \(placemarks.count) results")
//                let resultsController = self.searchController.searchResultsController as LocationResultsTableViewController
//                resultsController.possibleMatches = placemarks as [CLPlacemark]
//                resultsController.searchText = self.searchText
//                resultsController.tableView.reloadData()
//                
//            } else {
//                println("Error in geocoding: \(error)")
//                
//            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//        }
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
        
        if countElements(strippedString) >= 3 {
            // add minimal delay to search to avoid searching for something outdated
            cancelDelayed("search")
            delayed(0.1, name: "search") {
                self.performSearchForString(strippedString)
            }
        } // else do nothing
        
    }
    
    // MARK: - Helpers
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
            message: message,
            preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func addressStringAtIndexPath(indexPath: NSIndexPath) -> NSString {
        let placemark = searchResults[indexPath.row].placemark
        return ABCreateStringWithAddressDictionary(placemark.addressDictionary, false) as NSString
    }
    
    func attributedAddressStringAtIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        let string = addressStringAtIndexPath(indexPath)
        // get standard body font and bold variant
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let descriptor = bodyFont.fontDescriptor()
        let boldDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
        let highlightFont = UIFont(descriptor: boldDescriptor, size: bodyFont.pointSize)
        
        var attributes = [NSFontAttributeName: bodyFont]
        
        var attribString = NSMutableAttributedString(string: string, attributes: attributes)
        // show search terms in bold
        
        if !searchText.isEmpty {
            let searchTerms = searchText.componentsSeparatedByString(" ") as [String]
            for term in searchTerms {
                if !term.isEmpty {
                    let matchRange = string.rangeOfString(term, options: .DiacriticInsensitiveSearch | .CaseInsensitiveSearch)
                    if matchRange.location != NSNotFound {
                        attribString.addAttributes([NSFontAttributeName: highlightFont], range: matchRange)
                    }
                }
            }
        }
        return attribString
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as LocationTableViewCell
        
        cell.addressLabel!.attributedText = attributedAddressStringAtIndexPath(indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Check to see which table view cell was selected.
        
        var attributedString: NSAttributedString
        
        if tableView == self.tableView {
            attributedString = attributedAddressStringAtIndexPath(indexPath)
        }
        else {
            attributedString = resultsTableController.attributedAddressStringAtIndexPath(indexPath)
        }
        
        let neededSize = attributedString.size()
        return ceil(neededSize.height) + 20
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedPlacemark: CLPlacemark
        
        // Check to see which table view cell was selected.
        if tableView == self.tableView {
            selectedPlacemark = searchResults[indexPath.row].placemark
        }
        else {
            selectedPlacemark = resultsTableController.possibleMatches[indexPath.row]
        }
        
        // Set up the detail view controller to show.
        let mapViewController = LocationMapViewController.forPlacemark(selectedPlacemark)
        
        // Note: Should not be necessary but current iOS 8.0 bug requires it.
        tableView.deselectRowAtIndexPath(tableView.indexPathForSelectedRow()!, animated: false)
        
        navigationController!.pushViewController(mapViewController, animated: true)
    }
    
    
}