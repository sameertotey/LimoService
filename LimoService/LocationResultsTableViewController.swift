//
//  LocationResultsTableViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/16/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import AddressBookUI


class LocationResultsTableViewController: UITableViewController {

    var possibleMatches = [CLPlacemark]()
    var previousLocations = [LimoUserLocation]()
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.registerClass(LocationTableViewCell.self, forCellReuseIdentifier: "locationCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
        
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRows = 0
        switch section {
        case 0:
            numRows =  possibleMatches.count
        case 1:
            numRows = previousLocations.count
        default:
            break
        }
        return numRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationTableViewCell
        
        cell.addressLabel!.attributedText = attributedAddressStringAtIndexPath(indexPath)

        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    
    // MARK: - Helpers
    
    
    func addressStringAtIndexPath(indexPath: NSIndexPath) -> NSString {
        var returnString: NSString = ""
        switch indexPath.section {
        case 0:
            let placemark = possibleMatches[indexPath.row]
            returnString =  ABCreateStringWithAddressDictionary(placemark.addressDictionary, false) as NSString
        case 1:
            if let string = previousLocations[indexPath.row].address {
                returnString = string as NSString
            }
        default:
            break
        }
        return returnString
    }
    
    func attributedAddressStringAtIndexPath(indexPath: NSIndexPath) -> NSAttributedString {
        
        let string = addressStringAtIndexPath(indexPath)
        // get standard body font and bold variant
        let bodyFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        let descriptor = bodyFont.fontDescriptor()
        let boldDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
        let highlightFont = UIFont(descriptor: boldDescriptor!, size: bodyFont.pointSize)
        
        var attributes = [NSFontAttributeName: bodyFont]
        
        var attribString = NSMutableAttributedString(string: string as String, attributes: attributes)
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
    


  
}
