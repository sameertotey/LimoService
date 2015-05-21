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

class MapLocationSelectViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, RequestInfoDelegate, UITextFieldDelegate {

    weak var currentUser: PFUser!
    var userRole = ""

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var locationPin: LocationPin? {
        didSet {
            println(locationPin)
        }
    }
    var locationMapPinView: LocationMapPinView?
    var fromPin: LocationPin!
    var toPin: LocationPin!
    var locationMapPinViewRect: CGRect?
    var locatingUser = false
    var mapRendered = false
    var requestInfo: RequestInfoViewController!
    static var geoCoder: CLGeocoder = {
        return CLGeocoder()
        }()
    var locationTitle = ""
    var locationSubtitle = ""
    var address = ""
    // bar button items
    var saveBarButton: UIBarButtonItem!
    var editBarButton: UIBarButtonItem!
    var doneBarButton: UIBarButtonItem!
    var menuBarButtonItem: UIBarButtonItem!
    lazy var modalTransitioningDelegate = ModalPresentationTransitionVendor()

    @IBOutlet weak var navToUserLocationButton: UIButton!
    
    @IBOutlet weak var requestInfoViewHeightConstraint: NSLayoutConstraint!
    var requestInfoDate: NSDate?
    var requestInfoDateString: String!
    var numPassengers = 1
    var numBags = 0
    var preferredVehicle = "Limo"
    var specialComments = ""
    var fromLocation: LimoUserLocation? {
        didSet {
            if let mapView = mapView {
                if let fromLocation = fromLocation {
                    if fromLocation.isDataAvailable() {
                        self.updateFromPin()
                        self.adjustMap()
                    } else {
                        fromLocation.fetchInBackgroundWithBlock({ (object, error) in
                            self.updateFromPin()
                            self.adjustMap()
                        })
                    }
                } else {
                    if fromPin.coordinateSet {
                        mapView.removeAnnotation(fromPin)
                        fromPin.coordinateReset()
                    }
                }
            }
        }
    }
    var toLocation: LimoUserLocation? {
        didSet {
            if let mapView = mapView {
                if let toLocation = toLocation {
                    if toLocation.isDataAvailable() {
                        self.makeDestinationPin()
                        self.adjustMap()
                    } else {
                        toLocation.fetchInBackgroundWithBlock({ (object, error) in
                            self.makeDestinationPin()
                            self.adjustMap()
                        })
                    }
                } else {
                    if toPin.coordinateSet {
                        mapView.removeAnnotation(toPin)
                        toPin.coordinateReset()
                    }
                }
            }
         }
    }
    
    var locationFieldActive: ActiveField?
    
    var limoRequest: LimoRequest? {
        didSet {
            fromLocation = nil
            toLocation = nil
            resetUI()
            updateUI()
         }
    }
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var rotationGestureRecognizer: UIRotationGestureRecognizer!
    
    func updateUI() {
        if let mapView = mapView {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                showUserLocationOnMapView()
            default:
                break   // do nothing
            }
            requestInfo?.limoRequest = limoRequest
            if limoRequest == nil {
                navigationItem.rightBarButtonItem = nil
                if mapView.userLocation.location != nil && fromLocation == nil {
                    mapView.setCenterCoordinate(mapView.userLocation.location.coordinate, animated: true)
                    createLocationPin(mapView.userLocation.location.coordinate)
                }
                adjustMap()
                createRequestButton.setTitle("Create Request", forState: .Normal)
            } else {
                navigationItem.rightBarButtonItem = nil
                toLocation = limoRequest?.to
                fromLocation = limoRequest?.from
                createRequestButton.setTitle("Start New Request", forState: .Normal)

            }
        }
     }
    
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
//                if locationManager == nil {
//                    locationManager = CLLocationManager()
//                }
//                if let manager = locationManager {
//                    manager.delegate = self
//                    manager.desiredAccuracy = kCLLocationAccuracyKilometer
//                    // Set a movement threshold for new events.
//                    manager.distanceFilter = 500; // meters
//                    manager.startUpdatingLocation()
//                }
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
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = false
        
        // Do any additional setup after loading the view.
        let menuImage = UIImage(named: "Menu")
        let menuButton = UIButton.buttonWithType(.System) as! UIButton
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.frame = CGRectMake(0, 0, 24, 24)
        menuButton.addTarget(self, action: "mainMenu", forControlEvents: .TouchUpInside)
        menuBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        let pencilImage = UIImage(named: "Pencil")
        let pencilButton = UIButton.buttonWithType(.System) as! UIButton
        pencilButton.setImage(pencilImage, forState: .Normal)
        pencilButton.frame = CGRectMake(0, 0, 24, 24)
        pencilButton.addTarget(self, action: "editButton", forControlEvents: .TouchUpInside)
        editBarButton = UIBarButtonItem(customView: menuButton)
        
        
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButton")
        doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButton")
//        navigationItem.rightBarButtonItem = menuBarButtonItem
        navigationItem.leftBarButtonItem = menuBarButtonItem
        makeToFromPins()
    }
    
    func mainMenu() {
        println("main menu")
        if userRole == "provider" {
            performSegueWithIdentifier(UIStoryboardConstants.showProviderMenu, sender: nil)
        } else {
            performSegueWithIdentifier(UIStoryboardConstants.showConsumerMenu, sender: nil)
        }
    }
    func saveButton() {
        println("save button")
        requestInfo.datePickerHidden = true
    }
    func doneButton() {
        println("done button")
        limoRequest = nil
    }
    func editButton() {
        println("edit button")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.showsUserLocation = false
    }
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
   
    //destroy the location manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    override func shouldAutorotate() -> Bool {
        return false
    }
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    // MARK: - RequestInfoDelegate
    func dateUpdated(newDate: NSDate, newDateString: String) -> Void {
        requestInfoDate = newDate
        requestInfoDateString = newDateString
    }
    func neededHeight(height: CGFloat) -> Void {
        requestInfoViewHeightConstraint.constant = height
        if requestInfo.datePickerHidden {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = saveBarButton
        }
    }
    
    func textFieldActivated(field: ActiveField) {
        locationFieldActive = field
        performSegueWithIdentifier(UIStoryboardConstants.showLocationSearch, sender: nil)
    }

    func displayViewTapped() {
        performSegueWithIdentifier(UIStoryboardConstants.showRequestDetail, sender: nil)
    }
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {

        if annotation is MKUserLocation {
            // just skip the user location annotation and use the defaults
            return nil
        }
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if view == nil {
            view = LocationMapPinView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
        } else {
            view.annotation = annotation
        }
        
        view.canShowCallout = true
        view.draggable = false
        view.leftCalloutAccessoryView = nil
        view.rightCalloutAccessoryView = nil

        if annotation is LocationPin {
            if let kind = (annotation as? LocationPin)?.kind  {
                switch kind {
                case .Selector:
                    if view is LocationMapPinView {
                        locationMapPinView = view as? LocationMapPinView
                        locationMapPinView!.pinColor = .Purple
                     }
//                    var fromButton = UIButton.buttonWithType(.Custom) as! UIButton
//                    fromButton.setImage(UIImage(named: "FromPin"), forState: .Normal)
//                    fromButton.setTitle("Set Pickup", forState: .Normal)
//                    fromButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//                    fromButton.sizeToFit()
//                    view.leftCalloutAccessoryView = fromButton
//                    var toButton = UIButton.buttonWithType(.Custom) as! UIButton
//                    toButton.setImage(UIImage(named: "ToPin"), forState: .Normal)
//                    toButton.setTitle("Destination", forState: .Normal)
//                    toButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
//                    toButton.sizeToFit()
//                    view.rightCalloutAccessoryView = toButton
                case .From:
                    (view as? LocationMapPinView)?.pinColor = .Green
                case .To:
                    (view as? LocationMapPinView)?.pinColor = .Red
                }
            }
         }
         return view
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("didSelectAnnotationView")
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("control tapped \(control.dynamicType) \(control is UIButton)")
    }
    
    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        println("will start locating the user")
        locatingUser = true
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println("received user location update")
        // we only create a locationPin if it is nil
        createLocationPin(userLocation.location.coordinate)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        updateUI()
        mapView.scrollEnabled = true
//        mapView.zoomEnabled = true
        mapView.rotateEnabled = true
        mapRendered = true
    }
    func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
        println("region will change")
        if fromLocation == nil {
            mapView.removeAnnotation(locationPin)
            if let locationMapPinView = locationMapPinView {
                locationMapPinViewRect = mapView.convertRect(locationMapPinView.frame, toView: mapView)
                locationMapPinView.frame = locationMapPinViewRect!
                mapView.addSubview(locationMapPinView)
                println("did add subview")
            }
        }
     }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("region did change")
        if fromLocation == nil {
            locationPin?.coordinate = mapView.centerCoordinate
            if locationMapPinView?.annotation === locationPin {
                // only remove the view if it is still attached to this annotation (it can be reused for another annotation)
                locationMapPinView?.removeFromSuperview()
            }
            mapView.addAnnotation(locationPin)
            if mapRendered {
                reverseGeoCode(mapView.centerCoordinate)
            }
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
                        let addressString = ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false)
                        let addressComponents = addressString.componentsSeparatedByString("\n")
                        if addressComponents.count >= 2 {
                            self.locationSubtitle = addressComponents[1]
                        }
                        //                        self.locationSubtitle = (ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).componentsSeparatedByString("\n")[1]
//                        self.address = String(map((ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false) as String).generate()) {
//                            $0 == "\n" ? "," : $0
//                            })
                        self.address = ABCreateStringWithAddressDictionary(firstPlacemark.addressDictionary, false)
                    }
                    if let locationPin = self.locationPin {
                        locationPin.title = self.locationTitle
                        locationPin.subtitle = self.locationSubtitle
                        locationPin.address = self.address
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
    
    //MARK: - Gesture Recognizer Actions
    @IBAction func pinchGesture(sender: UIPinchGestureRecognizer) {
//        mapView.transform = CGAffineTransformScale(mapView.transform, sender.scale, sender.scale)
        var  originalRegion: MKCoordinateRegion
        originalRegion = mapView.region
        
        var latdelta = originalRegion.span.latitudeDelta / Double(sender.scale)
        var londelta = originalRegion.span.longitudeDelta / Double(sender.scale)
        
        latdelta = max(min(latdelta, 80), 0.002)
        londelta = max(min(londelta, 80), 0.002)
        let span = MKCoordinateSpanMake(latdelta, londelta)
        
        mapView.region = MKCoordinateRegionMake(originalRegion.center, span)
        sender.scale = 1

    }
    
    @IBAction func panGesture(sender: UIPanGestureRecognizer) {
        
//        let translation = sender.translationInView(view)
//        println("translation is \(translation)")
//        if let mapview = sender.view {
//            let oldCenter = mapView.convertCoordinate(mapView.centerCoordinate, toPointToView: mapView)
//            let newCenter = CGPoint(x:oldCenter.x - translation.x,
//                y:oldCenter.y - translation.y)
//            mapView.centerCoordinate = mapView.convertPoint(newCenter, toCoordinateFromView: mapView)
//        }
//        sender.setTranslation(CGPointZero, inView: view)
        
    }
    
    @IBAction func tapGesture(sender: UITapGestureRecognizer) {
        var  originalRegion: MKCoordinateRegion
        originalRegion = mapView.region
        
        var latdelta = originalRegion.span.latitudeDelta / 1.2
        var londelta = originalRegion.span.longitudeDelta / 1.2
        
//        // TODO: set these constants to appropriate values to set max/min zoomscale
        latdelta = max(min(latdelta, 80), 0.005)
        londelta = max(min(londelta, 80), 0.005)
        let span = MKCoordinateSpanMake(latdelta, londelta)
        
        mapView.region = MKCoordinateRegionMake(originalRegion.center, span)
    }
    
    @IBAction func rotationGesture(sender: UIRotationGestureRecognizer) {
        // let the mapview handle the rotations
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
//            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("Location manager did update locations")

//        if let newLocation = locations.last as? CLLocation {
//            if locationPin == nil {
//                createLocationPin(newLocation.coordinate)
//            } else {
//                locationPin?.coordinate = newLocation.coordinate
//                if locatingUser {
//                    manager.stopUpdatingLocation()    // There is no reason to continue doing this now
//                }
//            }
//        }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println("Location manager failed with error = \(error)")
    }
    
    @IBAction func navToUserLocation() {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
        locationPin?.coordinate = mapView.userLocation.coordinate
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let AnnotationViewReuseIdentifier = "location"
        static let ShowImageSegue = "Show Image"
    }
    
    func getFromLocation() -> LimoUserLocation {
        var from: LimoUserLocation!
        if fromLocation == nil {
//            if fromLocation == nil || fromLocation!.name != locationPin?.title || fromLocation!.address != locationPin?.address {
            from = LimoUserLocation(className: LimoUserLocation.parseClassName())
            let geoPoint = PFGeoPoint(location: locationPin?.location)
            from["location"] = geoPoint
            from["owner"] = currentUser
            from["name"] = locationPin?.title
            from["address"] = locationPin?.address
        } else {
            from = fromLocation!
        }
        return from
    }
    
    @IBOutlet weak var createRequestButton: ActionButton!
    
    @IBAction func createRequestButtonTouched(sender: ActionButton) {
        if let title = sender.titleForState(.Normal) {
            switch title {
                case "Create Request":
                createTheRequest()
                case "Start New Request":
                doneButton()
            default:
                break
            }
        }
    }
    
    func createTheRequest() {
        println("create the request")
        let from = getFromLocation()
        let limoRequest = LimoRequest(className: LimoRequest.parseClassName())
        limoRequest["from"] = from
        limoRequest["fromAddress"] = from["address"]
        limoRequest["fromName"] = from["name"]
        if let to = toLocation {
            limoRequest["to"] = to
            limoRequest["toAddress"] = to["address"]
            limoRequest["toName"] = to["name"]
        }
        limoRequest["owner"] = currentUser
        limoRequest["status"] = "New"
        limoRequest["when"] = requestInfoDate
        limoRequest["whenString"] = requestInfoDateString
        limoRequest["numPassengers"] = numPassengers
        limoRequest["numBags"] = numBags
        limoRequest["preferredVehicle"] = preferredVehicle
        limoRequest["comment"] = specialComments
        limoRequest.saveInBackgroundWithBlock {[unowned self](succeeded, error)  in
            if succeeded {
                println("Succeed in creating a limo request: \(limoRequest)")
                let controller = UIAlertController(title: "Request Created", message: "Your limo request has been saved", preferredStyle: .Alert)
                controller.addAction(UIAlertAction(title: "OK", style: .Default) {[unowned self] _ in
                    println("request created")
                    self.limoRequest = limoRequest
                    
                    //                        self.scheduleLocalNotification()
                    //                        self.performSegueWithIdentifier("Show Created Request", sender: limoRequest)
                    //                        self.resetFields()
                    })
                self.navigationController?.presentViewController(controller, animated: true, completion: nil)
                
            } else {
                println("Received error while creating the request: \(error)")
            }
        }
    }
    /*
    // MARK: - Create the Request
    func createTheRequest() {
        if let from = fromLocation {
        } else {
            displayAlertWithTitle("Incomplete Request", message: "Need 'From' Location")
        }
    }
    
    
    func scheduleLocalNotification() {
        var localNotification = UILocalNotification()
        localNotification.fireDate =  NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.CalendarUnitMinute, value: -2, toDate: whenCell.date!, options: nil)!
        localNotification.timeZone = NSTimeZone.localTimeZone()
        localNotification.alertBody = "Limo service due soon"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
   */

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
    func adjustMap() {
        var annotations = [MKAnnotation]()
        if mapView.userLocation.location != nil {
            annotations.append(mapView.userLocation)
            println("mapview location is \(mapView.userLocation.location.coordinate.latitude) : \(mapView.userLocation.location.coordinate.longitude)")
        }
        if limoRequest == nil {
            if let locationPinSet = locationPin?.coordinateSet where locationPinSet {
                annotations.append(locationPin!)
            }
        }
        if fromPin.coordinateSet {
            annotations.append(fromPin)
        }
        if toPin.coordinateSet  {
            annotations.append(toPin)
        }
        println("annotations count: \(annotations.count)")
        println("annotations are: \(annotations)")
        
        var zoomRect = MKMapRectNull
        for annotation in annotations {
            if annotation is LocationPin {
                println((annotation as! LocationPin).kind)
            }
            print(annotation.coordinate.latitude)
            println(annotation.coordinate.longitude)
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let  pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        let newRegion = MKCoordinateRegionForMapRect(zoomRect)
        var latdelta = newRegion.span.latitudeDelta * 2.2         // zoom out the region
        var londelta = newRegion.span.longitudeDelta * 2.2
        let span = MKCoordinateSpanMake(max(latdelta, 0.02), max(londelta, 0.02))
        println(" 1 lat = \(span.latitudeDelta) : long = \(span.longitudeDelta)")
        mapView.region = MKCoordinateRegionMake(mapView.centerCoordinate, span)
    }
    
    func resetUI() {
        mapView?.removeAnnotations(mapView.annotations)
        locationPin = nil
        locationMapPinView?.removeFromSuperview()
        locationMapPinView = nil
        makeToFromPins()
        requestInfoDate = NSDate()
        requestInfoDateString = ""
        numPassengers = 1
        numBags = 0
        specialComments = ""
    }
    
    /* We will call this method when we are sure that the user has given
    us access to her location */
    func showUserLocationOnMapView(){
        mapView.showsUserLocation = true
        if fromLocation == nil {
            mapView.userTrackingMode = .Follow
        }
    }
    
    func createLocationPin(coordinate: CLLocationCoordinate2D) {
        if locationPin == nil && limoRequest == nil && mapRendered && fromLocation == nil {
            println("created the locationPin")
            locationPin = LocationPin()
            locationPin?.kind = .Selector
            locationPin?.coordinate = coordinate
            mapView.addAnnotation(locationPin)
        }
    }
    func removeLocationPin() {
        if locationMapPinView?.annotation === locationPin {
            // only remove the view if it is still attached to this annotation (it can be reused for another annotation)
            locationMapPinView?.removeFromSuperview()
        }
        mapView.removeAnnotation(locationPin)
        locationPin = nil
        mapView.userTrackingMode = .None
    }
    func makeDestinationPin() {
        if let toLocation = toLocation {
            if toPin.coordinateSet {
                mapView.removeAnnotation(toPin)
            }
            if let location = toLocation["location"] as? PFGeoPoint {
                println("\(NSDate()) \(__FILE__) \(__FUNCTION__) \(__LINE__)")
                toPin.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                if let toName = toLocation["name"] as? String, toAddress = toLocation["address"] as? String {
                    toPin.title = toName
                    toPin.subtitle = toAddress.fullAddressString(toName)
                }
                mapView.addAnnotation(toPin)
                mapView.centerCoordinate = toPin.coordinate
                
                requestInfo.toTextField.text = toPin.title
                if fromPin.coordinateSet {
                    removeLocationPin()
                }

            }
        }
    }
    func updateFromPin() {
        if let fromLocation = fromLocation {
            if fromPin.coordinateSet {
                mapView.removeAnnotation(fromPin)
            }
            if let location = fromLocation["location"] as? PFGeoPoint {
                println("\(NSDate()) \(__FILE__) \(__FUNCTION__) \(__LINE__)")
                fromPin.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                if let fromName = fromLocation["name"] as? String, fromAddress = fromLocation["address"] as? String {
                    fromPin.title = fromName
                    fromPin.subtitle = fromAddress.fullAddressString(fromName)
                }
                mapView.addAnnotation(fromPin)
                mapView.centerCoordinate = fromPin.coordinate
                if toPin.coordinateSet {
                    removeLocationPin()
                }
                requestInfo.fromTextField.text = fromPin.title
            }
        }
    }
    func makeToFromPins() {
        toPin = LocationPin()
        toPin.kind = .To
        fromPin = LocationPin()
        fromPin.kind = .From
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("prepare for segue")
        if let identifier = segue.identifier {
            switch identifier {
            case UIStoryboardConstants.showLocationSearch:
                if segue.destinationViewController is LocationSelectionViewController {
                    let toVC = segue.destinationViewController as! LocationSelectionViewController
                    toVC.searchRegion = mapView.region
                    toVC.searchText = locationTitle
                }
            case UIStoryboardConstants.showConsumerMenu:
                println("segue to consumer menu")
                if segue.destinationViewController is CustomerMenuViewController {
                    let toVC = segue.destinationViewController as! CustomerMenuViewController
                    toVC.listner = self
                    toVC.modalPresentationStyle = .Custom
                    toVC.transitioningDelegate = self.modalTransitioningDelegate
                }
            case UIStoryboardConstants.showProviderMenu:
                println("segue to provider menu")
                if segue.destinationViewController is ProviderMenuViewController {
                    let toVC = segue.destinationViewController as! ProviderMenuViewController
                    toVC.listner = self
                    toVC.modalPresentationStyle = .Custom
                    toVC.transitioningDelegate = self.modalTransitioningDelegate
                }
            case UIStoryboardConstants.requestInfo:
                if segue.destinationViewController is RequestInfoViewController {
                    requestInfo = segue.destinationViewController as! RequestInfoViewController
                    requestInfo.delegate = self
                    requestInfo.limoRequest = limoRequest
                }
            case UIStoryboardConstants.showRequestDetail:
                if segue.destinationViewController is RequestDetailTableViewController {
                    let toVC = segue.destinationViewController as! RequestDetailTableViewController
                    toVC.limoRequest = limoRequest
                }
            default:
                break
            }
        }
    }
    // unwind from a location selection
    @IBAction func unwindToMapSelection(sender: UIStoryboardSegue)
    {
        // Pull any data from the view controller which initiated the unwind segue.
        if let sVC = sender.sourceViewController as? LocationSelectionViewController {
            switch locationFieldActive! {
            case .From:
                fromLocation = sVC.selectedLocation
            case .To:
                toLocation = sVC.selectedLocation
            }
        }
    }
    
    private struct UIStoryboardConstants {
        static let showLocationSearch = "Show Location Search"
        static let showConsumerMenu   = "Show Consumer Menu"
        static let showProviderMenu   = "Show Provider Menu"
        static let requestInfo        = "Request Info"
        static let showRequestDetail  = "Show Request Detail"
    }

}
