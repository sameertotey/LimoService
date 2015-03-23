//
//  LocationMapViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/17/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit
import AddressBook
import AddressBookUI

class LocationMapViewController: UIViewController {
    // MARK: Types
    
    // Constants for Storyboard/ViewControllers
    struct StoryboardConstants {
        static let storyboardName = "Main"
        static let viewControllerIdentifier = "MapLocation"
    }

    @IBOutlet weak var mapView: MKMapView!
    var placemark: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveLocation")
        self.navigationItem.rightBarButtonItem = saveBarButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if placemark == nil {
            return
        }
        
        // set title from first address line
        self.navigationItem.title = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
        
        println("Navigation title = \(ABCreateStringWithAddressDictionary(placemark.addressDictionary, false))")
        
        // set zoom to fit placemark
        var circularRegion = CLCircularRegion()
        circularRegion = placemark.region as CLCircularRegion  // can we downcast it safely?
        
        let distance = circularRegion.radius * 2.0
        
        let mapRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, distance, distance)
        mapView.setRegion(mapRegion, animated: false)
        
        
        // create annoation
        let mkPlacemark = MKPlacemark(placemark: placemark)
        mapView.addAnnotation(mkPlacemark)

    }
    
    func saveLocation() {
        println("save location selected")
        performSegueWithIdentifier("unwindToUserProfile", sender: self)
    }
    
    
    // MARK: Factory Methods
    
    class func forPlacemark(placemark: CLPlacemark) -> LocationMapViewController {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewControllerWithIdentifier(StoryboardConstants.viewControllerIdentifier) as LocationMapViewController
        
        viewController.placemark = placemark
        
        return viewController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
