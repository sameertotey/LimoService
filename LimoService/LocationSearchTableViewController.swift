//
//  LocationSearchTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/16/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class LocationSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating  {

    // MARK: Properties
    var geoCoder: CLGeocoder?
    var searchResults = [CLPlacemark]()
    
    // The following 2 properties are set in viewDidLoad(),
    // They an implicitly unwrapped optional because they are used in many other places throughout this view controller
    //
    // Search controller to help us with filtering.
    var searchController: UISearchController!
    
    // Secondary search results table view.
    var resultsTableController: LocationResultsTableViewController!
    
    // text in the search bar
    var searchText = ""

    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geoCoder = CLGeocoder()
        
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
        searchController.dimsBackgroundDuringPresentation = false // default is YES
        searchController.searchBar.delegate = self    // so we can monitor text changes + others
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        searchController.searchBar.text = searchText
     }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        geoCoder?.geocodeAddressString(searchText) { placemarks, error in
            if error == nil {
                self.searchResults = placemarks as [CLPlacemark]
                self.tableView.reloadData()
            } else {
                println("Error in geocoding: \(error) for string: \(self.searchText)")
                
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }

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
    
    
    func performGeocodingForString(searchString: String)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        geoCoder?.geocodeAddressString(searchString) { placemarks, error in
            if error == nil {
//                self.searchResults = placemarks as [CLPlacemark]
                // Hand over the filtered results to our search results table.
                let resultsController = self.searchController.searchResultsController as LocationResultsTableViewController
                resultsController.possibleMatches = placemarks as [CLPlacemark]
                resultsController.searchText = self.searchText
                resultsController.tableView.reloadData()

            } else {
                println("Error in geocoding: \(error)")
   
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
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
        
        // cancel previous in flight geocoding
        geoCoder?.cancelGeocode()
        
        if countElements(strippedString) >= 3 {
            // add minimal delay to search to avoid searching for something outdated
            cancelDelayed("geocode")
            delayed(0.1, name: "geocode") {
                self.performGeocodingForString(strippedString)
            }
        } // else do nothing
        
    }
    
    // MARK: - Helpers
    
    
    func addressStringAtIndexPath(indexPath: NSIndexPath) -> NSString {
        let placemark = searchResults[indexPath.row]
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
            selectedPlacemark = searchResults[indexPath.row]
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
