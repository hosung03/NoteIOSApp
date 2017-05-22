//
//  DetailViewController.swift
//  NoteIOSApp
//
//  Created by Hosung, Lee on 2016. 12. 5..
//  Copyright © 2016년 hosung. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    public static var latitudeDelta : CLLocationDegrees = 0.07
    public static var longitudeDelta : CLLocationDegrees = 0.07
    
    private let picker = UIImagePickerController()

    public var masterView : MasterViewController? = nil
    
    private var curNoteInfo : NoteInfo? = nil
    private var locationManager = CLLocationManager()
    private var locationCordinate:CLLocationCoordinate2D? = nil
    private var geolocationCordinate:CLLocationCoordinate2D? = nil
    private var enableLocationManager = true
    private var viewState = 0
    private var locationAdderss : String = ""
    
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var mvMap: MKMapView!
    @IBOutlet weak var lbLocaltion: UILabel!
    
    
    var detailItem: AnyObject? {
        didSet {
            self.configureView()
        }
    }
    
    func configureView() {
        if MasterViewController.arrNoteList?.count == 0 {
            return
        }
        
        curNoteInfo = detailItem as? NoteInfo
        
        if let note = self.txtNote {
            note.text = curNoteInfo?.getNote()
            if txtNote.text == MasterViewController.BLANK_NOTE {
                txtNote.text = ""
            }
        }
        
        if let photo = self.ivPhoto {
            if curNoteInfo?.getPhotofile() != "" {
                
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let file_name = (curNoteInfo?.getPhotofile())!
                let imageURL = URL(fileURLWithPath: "\(paths[0])/\(file_name)")
                //print ("Detail imageURL: \(imageURL.path)");
                if imageURL.isFileURL {
                    photo.image = UIImage(contentsOfFile: imageURL.path)
                }
            }
        }
        
        if curNoteInfo?.getLatitude() != 0
            && curNoteInfo?.getLongitude() != 0 {
            if locationCordinate == nil {
                locationCordinate = CLLocationCoordinate2D()
            }
            locationCordinate?.latitude = (curNoteInfo?.getLatitude())!
            locationCordinate?.longitude = (curNoteInfo?.getLongitude())!
            
            locationAdderss = (curNoteInfo?.getAddress())!
            
            if let location = self.lbLocaltion {
                location.text = "Location: "+locationAdderss+"\nLatitude: \((locationCordinate?.latitude)!), Logigitude: \((locationCordinate?.longitude)!)"
            }
            
            enableLocationManager = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if ((curNoteInfo?.getNoteno())! > 0) {
            self.navigationItem.title = "Edit Note"
        } else {
            self.navigationItem.title = "Add Note"
        }

        // photo picker
        picker.delegate = self
        
        // note textview
        txtNote.becomeFirstResponder()
        txtNote.delegate = self
        self.configureView()
        
        // location
        if enableLocationManager {
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                if locationCordinate == nil {
                    locationCordinate = CLLocationCoordinate2D()
                }
                locationCordinate = locationManager.location?.coordinate
                geolocationCordinate = locationCordinate
            }
        }
        
        // map
        mvMap.delegate = self
        mvMap.mapType = .standard
        mvMap.isZoomEnabled = true
        mvMap.isScrollEnabled = true
        if let coor = mvMap.userLocation.location?.coordinate{
            mvMap.setCenter(coor, animated: true)
        }
        
        if locationCordinate != nil {
            lbLocaltion.text = "Latitude: \((locationCordinate?.latitude)!), Longitude: \((locationCordinate?.longitude)!)"
            setLocationAddress()
            setLocationInMap()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mvMap.showsUserLocation = true
        if viewState > 0 {
            viewState = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mvMap.showsUserLocation = false
        if viewState == 0 {
            saveNoteInfo()
        }
        super.viewWillDisappear(animated)
    }
    
    public func saveNoteInfo() {
        if MasterViewController.arrNoteList?.count == 0 {
            return
        }
        
        MasterViewController.arrNoteList?[MasterViewController.currentIndex].setNote(note: txtNote.text)
        if txtNote.text == "" {
            MasterViewController.arrNoteList?[MasterViewController.currentIndex].setNote(note: MasterViewController.BLANK_NOTE)
        }

        if (ivPhoto.image != nil){
            // Create path.
            let current_time = Int64(Date().timeIntervalSince1970 * 1000)
            let file_name : String = "\(current_time).png"
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let filepath = "\(paths[0])/\(file_name)"
            
            // Save image.
            let data = UIImagePNGRepresentation(ivPhoto.image!)
            do {
                try data?.write(to: URL(fileURLWithPath: filepath), options: .atomic)
            } catch {
                print(error)
            }
            MasterViewController.arrNoteList?[MasterViewController.currentIndex].setPhotofile(photofile: file_name)
        }
        
        
        if locationCordinate != nil {
            if (geolocationCordinate == nil
                || geolocationCordinate?.latitude != locationCordinate?.latitude
                || geolocationCordinate?.longitude != locationCordinate?.longitude
                || curNoteInfo?.getNote() != MasterViewController.BLANK_NOTE
                || curNoteInfo?.getPhotofile() != "") {
                
                if locationCordinate?.latitude != curNoteInfo?.getLatitude() {
                    MasterViewController.arrNoteList?[MasterViewController.currentIndex].setLatitude(latitude: (locationCordinate?.latitude)!)
                }
                if locationCordinate?.longitude != curNoteInfo?.getLongitude() {
                    MasterViewController.arrNoteList?[MasterViewController.currentIndex].setLongitude(longitude: (locationCordinate?.longitude)!)
                }
                if locationAdderss != "" {
                     MasterViewController.arrNoteList?[MasterViewController.currentIndex].setAddress(address: locationAdderss)
                }
            }
        }
        
        if curNoteInfo != nil {
            MasterViewController.saveTODB(noteinfo: curNoteInfo!)
        }
        
//        let naviVC = (self.navigationController)! as UINavigationController
//        let n: Int! = naviVC.viewControllers.count
//        if n < 2 {
//            return
//        }
//        
//        let masterVC = self.navigationController?.viewControllers[n-2] as! MasterViewController
//        masterVC.tableView.reloadData()
        masterView?.tableView.reloadData()
    }
    
    @IBAction func btnAddChangeImageFromGallary(_ sender: UIButton) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
        viewState = 1 // call Gallary
    }

    @IBAction func btnAddChangeImageFromCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
            viewState = 2 // call Photo Libary
        } else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,animated: true,completion: nil)
    }

    @IBAction func btnChangeLocation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "srchLocSegue", sender: sender)
    }
    
    public func changeLocation(cordinate : CLLocationCoordinate2D) {
        locationCordinate = cordinate
        if locationCordinate != nil {
            lbLocaltion.text = "Latitude: \((locationCordinate?.latitude)!), Longitude: \((locationCordinate?.longitude)!)"
            setLocationAddress()
            setLocationInMap()
        }
    }
    
    // photo picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var  chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        ivPhoto.contentMode = .scaleAspectFit
        ivPhoto.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        var view : MKPinAnnotationView
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView {
            dequeueView.annotation = annotation
            view = dequeueView
        }else{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        view.pinTintColor = .red
        return view
    }

    func setLocationInMap(){
        let region = MKCoordinateRegion(center:locationCordinate!, span: MKCoordinateSpanMake(DetailViewController.latitudeDelta, DetailViewController.longitudeDelta))
        mvMap.setRegion(region, animated: true)
    }
    
    func setLocationAddress(){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: (locationCordinate?.latitude)!, longitude: (locationCordinate?.longitude)!)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (address, error) -> Void in
            if let addr = address?[0] {
                self.locationAdderss = self.getLocationAddress(place: addr, subtitle: false)
                self.lbLocaltion.text = "Latitude: \((self.locationCordinate?.latitude)!), Logigitude: \((self.locationCordinate?.longitude)!)\nLocation: \(self.locationAdderss)"
            }
        })
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

