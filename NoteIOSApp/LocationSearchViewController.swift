//
//  SearchLocationViewController.swift
//  NoteIOSApp
//
//  Created by mac on 2016. 12. 12..
//  Copyright © 2016년 hosung. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class LocationSearchViewController: UIViewController, UIGestureRecognizerDelegate  {
    
    //public var detailView:DetailViewController? = nil
    
    public var locationManager = CLLocationManager()
    public var locationCordinate:CLLocationCoordinate2D? = nil
    public var locationAddress : String = ""
    public var curAnnotion: MKPointAnnotation? = nil
    
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    
    @IBOutlet weak var mvLocationMap: MKMapView!
    @IBOutlet weak var txtLocationSearch: UILabel!
    @IBOutlet weak var vwSearchBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        vwSearchBar.addSubview(searchBar)
        
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        locationSearchTable.mapView = mvLocationMap
        locationSearchTable.handleMapSearchDelegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(LocationSearchViewController.handleTap))
        gestureRecognizer.delegate = self
        mvLocationMap.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func itembtnYes(_ sender: UIBarButtonItem) {
        var controller : UIAlertController? = nil;
        if locationCordinate == nil || locationAddress == "" {
            controller = UIAlertController(title: "", message: "Please search new location!!", preferredStyle: .alert)
            let okaction = UIAlertAction(title: "Ok", style: .default)
            controller?.addAction(okaction)
            present(controller!,animated: true)
            return
        }
        
        
        let naviVC = (self.navigationController)! as UINavigationController
        let n: Int! = naviVC.viewControllers.count
        
        if n < 2 {
            return
        }
        
        let detailVC = self.navigationController?.viewControllers[n-2] as! DetailViewController
        detailVC.changeLocation(cordinate: self.locationCordinate!)

        naviVC.popViewController(animated: true)
    }
    
    @IBAction func itembtnNo(_ sender: UIBarButtonItem) {
        let naviVC = (self.navigationController)! as UINavigationController
        naviVC.popViewController(animated: true)
    }
    
    func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        let location = gestureReconizer.location(in: mvLocationMap)
        let coordinate = mvLocationMap.convert(location,toCoordinateFrom: mvLocationMap)

        if curAnnotion != nil {
            mvLocationMap.removeAnnotation(curAnnotion!)
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        if curAnnotion != nil {
            mvLocationMap.removeAnnotation(curAnnotion!)
        }
        curAnnotion = annotation
        mvLocationMap.addAnnotation(annotation)
        
        // location Latitude, Longitude and address
        locationCordinate = coordinate
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation( cllocation, completionHandler: { (location, error) -> Void in
            let place = (location?[0])! as CLPlacemark
            self.locationAddress = self.getLocationAddress(place: place, subtitle: false)
        });
        txtLocationSearch.text = "Latitude: \((locationCordinate?.latitude)!), Logigitude: \((locationCordinate?.longitude)!)\nLocation: \(locationAddress)"
    }
    
    func getLocationAddress(place : CLPlacemark, subtitle : Bool ) -> String{
        var address = ""
        if !subtitle {
            if let name = place.name {
                address = " \(name)"
            }
        }
        if let city = place.locality {
            if address != "" {
                address += ", \(city)"
            } else {
                address = city
            }
        }
        if let state = place.administrativeArea {
            if address != "" {
                address += ", \(state)"
            } else {
                address = state
            }
        }
        if let zip = place.postalCode {
            if address != "" {
                address += ", \(zip)"
            } else {
                address = zip
            }
        }
        if let country = place.country {
            if address != "" {
                address += ", \(country)"
            } else {
                address = country
            }
        }
        return address
    }
}

extension LocationSearchViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        let span = MKCoordinateSpanMake(DetailViewController.latitudeDelta, DetailViewController.longitudeDelta)
//        let region = MKCoordinateRegion(center: location.coordinate, span: span)
//        mvLocationMap.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
    
}

extension LocationSearchViewController: HandleMapSearch {
    
    func dropPinZoomIn(_ placemark: MKPlacemark){
        selectedPin = placemark
        mvLocationMap.removeAnnotations(mvLocationMap.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = getLocationAddress(place: placemark, subtitle: true)

        if curAnnotion != nil {
            mvLocationMap.removeAnnotation(curAnnotion!)
        }
        curAnnotion = annotation
        mvLocationMap.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(DetailViewController.latitudeDelta, DetailViewController.longitudeDelta)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mvLocationMap.setRegion(region, animated: true)
        
        // location Latitude, Longitude and address
        locationCordinate = placemark.coordinate
        locationAddress = getLocationAddress(place: placemark, subtitle: false)
        txtLocationSearch.text = "Latitude: \((locationCordinate?.latitude)!), Logigitude: \((locationCordinate?.longitude)!)\nLocation: \(locationAddress))"
    }
    
}


