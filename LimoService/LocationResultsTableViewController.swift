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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleMatches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as LocationTableViewCell
        
        cell.addressLabel!.attributedText = attributedAddressStringAtIndexPath(indexPath)
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let attributedString = attributedAddressStringAtIndexPath(indexPath)
        let neededSize = attributedString.size()
        return ceil(neededSize.height) + 20
    }
    
        
    // MARK: - Helpers
    
    
    func addressStringAtIndexPath(indexPath: NSIndexPath) -> NSString {
        let placemark = possibleMatches[indexPath.row]
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
    


  
}
