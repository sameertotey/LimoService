//
//  MapLocationSelectViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/19/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit

class MapLocationSelectViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var locationPin: LocationPin?
    var locationMapPinView: LocationMapPinView?
    var locationMapPinViewRect: CGRect?

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                showUserLocationOnMapView()
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
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        // Do any additional setup after loading the view.
        //        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveLocation")
        //        navigationItem.rightBarButtonItem = saveBarButtonItem
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    //destroy the location manager
    deinit {
        locationManager?.delegate = nil
        mapView!.delegate = nil
        locationManager = nil
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)

        if annotation is MKUserLocation {
            // Create the specail pin here
            println("create location pin")
            createLocationPin()
            return nil
        }
        if annotation is LocationPin {
            view = LocationMapPinView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            if view is LocationMapPinView {
                locationMapPinView = view as? LocationMapPinView
            }
        }
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
        } else {
            view.annotation = annotation
        }
        
        view.canShowCallout = true
        view.draggable = true
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil
        
        return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("didSelectAnnotationView \(view)")
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    }
    
    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        println("will start locating the user")
    }
    
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        println("region will change")
        println("the coordinated of the center pin are \(locationMapPinView?.frame)")
        println("the coordinated of the center pin are \(locationMapPinView?.superview)")
        mapView.removeAnnotation(locationPin)
        if let locationMapPinView = locationMapPinView {
            locationMapPinViewRect = mapView.convertRect(locationMapPinView.frame, toView: view)
            locationMapPinView.frame = locationMapPinViewRect!
            view.addSubview(locationMapPinView)
            println("did add subview")
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("region did change")
        locationPin?.coordinate = mapView.centerCoordinate
        locationMapPinView?.removeFromSuperview()
        mapView.addAnnotation(locationPin)
        mapView.selectAnnotation(locationPin, animated: true)
    }
    // MARK: - LocationManager Delegate
    /* The authorization status of the user has changed, we need to react
    to that so that if she has authorized our app to to view her location,
    we will accordingly attempt to do so */
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        print("The authorization status of location services is changed to: ")
        
        switch CLLocationManager.authorizationStatus(){
        case .Denied:
            println("Denied")
        case .NotDetermined:
            println("Not determined")
        case .Restricted:
            println("Restricted")
        default:
            showUserLocationOnMapView()
            println("Now you have the authorization for location services.")
            manager.startUpdatingLocation()
        }
    }

    // MARK: - Constants
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth: CGFloat = 320
    }
    // MARK: - Helpers
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
    }
    
    /* We will call this method when we are sure that the user has given
    us access to her location */
    func showUserLocationOnMapView(){
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
    }
    
    func createLocationPin() {
        // we only need the location pin once
        if locationPin == nil {
            locationPin = LocationPin()
            locationPin?.coordinate = mapView.userLocation.location.coordinate
            mapView.addAnnotation(locationPin)
        }
    }

}
