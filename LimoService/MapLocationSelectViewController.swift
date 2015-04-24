//
//  MapLocationSelectViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/19/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class MapLocationSelectViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, NavBarNotificationDelegate, RequestInfoDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var locationPin: LocationPin?
    var locationMapPinView: LocationMapPinView?
    var locationMapPinViewRect: CGRect?
    var locatingUser = false
    var mapRendered = false
    var requestInfo: RequestInfoViewController!
    static var geoCoder: CLGeocoder = {
        return CLGeocoder()
        }()
    var locationTitle = "" {
        didSet {
            requestInfo.textField.text = locationTitle
        }
    }
    var locationSubtitle = ""
    // bar button items
    var saveBarButton: UIBarButtonItem!
    var menuBarButtonItem: UIBarButtonItem!
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()

    
    @IBOutlet weak var requestInfoViewHeightConstraint: NSLayoutConstraint!
    var requestInfoDate: NSDate?
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
                println("Location Services status unknown")
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
                showUserLocationOnMapView()
            }
        } else {
            /* Location services are not enabled.
            Take appropriate action: for instance, prompt the
            user to enable the location services */
            println("Location services are not enabled")
            displayAlertWithTitle("Location Services Needed", message: "Please enable location Services for the device")
        }
        
        mapView.scrollEnabled = false
        mapView.zoomEnabled = false
        mapView.rotateEnabled = false
        
        // set self to be delegate of notification of nav bar
        (navigationController as! CustomNavigationController).notifier = self
    
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true
        
        // Do any additional setup after loading the view.
        menuBarButtonItem = UIBarButtonItem(title: "Menu", style: .Plain , target: self, action: "mainMenu")
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButton")
//        navigationItem.rightBarButtonItem = menuBarButtonItem
        navigationItem.leftBarButtonItem = menuBarButtonItem
    }
    
    func navigationBarStatusUpdated(newStatus: Bool) {
        println("new notification status = \(newStatus)")
        updateOverlayedTableView()
    }

    func updateOverlayedTableView() {
        println("update the tableview here")
    }
    
    func mainMenu() {
        println("main menu")
        performSegueWithIdentifier("Show Main Menu", sender: nil)
    }
    
    func saveButton() {
        println("save button")
        requestInfo.datePickerHidden = true
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            locationManager?.startUpdatingLocation()
            showUserLocationOnMapView()
        default:
            break   // do nothing
        }
//        navigationController?.hidesBarsOnTap = true
//        navigationController?.barHideOnTapGestureRecognizer.addTarget(self, action: "updateOverlayedTableView")
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager?.stopUpdatingLocation()
        mapView.showsUserLocation = false
//        navigationController?.hidesBarsOnTap = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
   
    //destroy the location manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    // MARK: - RequestInfoDelegate
    func dateUpdated(newDate: NSDate) -> Void {
        requestInfoDate = newDate
    }
    func neededHeight(height: CGFloat) -> Void {
        requestInfoViewHeightConstraint.constant = height
        if requestInfo.datePickerHidden {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = saveBarButton
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepare for segue")
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Main Menu":
                println("segue to main menu")
                if segue.destinationViewController is MainMenuViewController {
                    let toVC = segue.destinationViewController as! MainMenuViewController
                    toVC.modalPresentationStyle = .Custom
                    toVC.transitioningDelegate = self.modalTransitioningDelegate
                }
                
            case "Request Info":
                if segue.destinationViewController is RequestInfoViewController {
                    requestInfo = segue.destinationViewController as! RequestInfoViewController
                    requestInfo.delegate = self
                }
            default:
                break
            }
        }
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)

        if annotation is MKUserLocation {
            // just skip the user location annotation and use the defaults
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
        view.draggable = false
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil
        
        return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("didSelectAnnotationView")
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    }
    
    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        println("will start locating the user")
        locatingUser = true
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        mapView.scrollEnabled = true
        mapView.zoomEnabled = true
        mapView.rotateEnabled = true
        mapRendered = true
    }
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        println("region will change")
        mapView.removeAnnotation(locationPin)
        if let locationMapPinView = locationMapPinView {
            locationMapPinViewRect = mapView.convertRect(locationMapPinView.frame, toView: mapView)
            locationMapPinView.frame = locationMapPinViewRect!
            mapView.addSubview(locationMapPinView)
            println("did add subview")
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("region did change")
        locationPin?.coordinate = mapView.centerCoordinate
        locationMapPinView?.removeFromSuperview()
        mapView.addAnnotation(locationPin)
        if mapRendered {
            reverseGeoCode(mapView.centerCoordinate)
        }
    }
    
    func reverseGeoCode(locationCoordinate: CLLocationCoordinate2D) {
        // cancel previous in flight geocoding
        if MapLocationSelectViewController.geoCoder.geocoding {
            MapLocationSelectViewController.geoCoder.cancelGeocode()
        }
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        // add minimal delay to search to avoid searching for something outdated
        cancelDelayed("geocode")
        delayed(0.1, name: "geocode") {
            self.performReverseGeoCode(location)
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

    func performReverseGeoCode(location: CLLocation) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        MapLocationSelectViewController.geoCoder.reverseGeocodeLocation(location)
            { placemarks, error in
                if error == nil {
                    if let firstPlacemark = placemarks.first as? CLPlacemark {
                        self.locationTitle = firstPlacemark.name
                        //                        self.subtitle = String(map((ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).generate()) {
                        //                            $0 == "\n" ? "," : $0
                        //                            })
                        self.locationSubtitle = (ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).componentsSeparatedByString("\n")[1]
                        
                    }
                    //
                    //                    for placemark in placemarks {
                    //                        println("The name of the location is \(placemark.name)")
                    //                        println("\(ABCreateStringWithAddressDictionary(placemark.addressDictionary, false) as NSString)")
                    //                    }
                    if let locationPin = self.locationPin {
                        locationPin.title = self.locationTitle
                        locationPin.subtitle = self.locationSubtitle
                        // only select the locationPin if it is already added to the mapView
                        for annotation in self.mapView.annotations {
                            if annotation === locationPin {
                                self.mapView.selectAnnotation(locationPin, animated: true)
                            }
                        }

                      }
                } else {
                    println("Error in geocoding: \(error)")
                    
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let newLocation = locations.last as? CLLocation {
            if locationPin == nil {
                createLocationPin(newLocation.coordinate)
            } else {
                locationPin?.coordinate = newLocation.coordinate
                if locatingUser {
                    manager.stopUpdatingLocation()    // There is no reason to continue doing this now
                }
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Location manager failed with error = \(error)")
    }

    // MARK: - Constants
    
    private struct Constants {
        static let AnnotationViewReuseIdentifier = "location"
        static let ShowImageSegue = "Show Image"
    }
    // MARK: - Helpers
    
    /* Just a little method to help us display alert dialogs to the user */
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        controller.addAction(UIAlertAction(title: "Settings", style: .Default) { _ in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })

        presentViewController(controller, animated: true, completion: nil)
    }
    
    /* We will call this method when we are sure that the user has given
    us access to her location */
    func showUserLocationOnMapView(){
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
    }
    
    func createLocationPin(coordinate: CLLocationCoordinate2D) {
        if locationPin == nil {
            locationPin = LocationPin()
            locationPin?.coordinate = coordinate
            mapView.addAnnotation(locationPin)
        }
    }
}
