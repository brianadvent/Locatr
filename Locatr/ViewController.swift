//
//  ViewController.swift
//  Locatr
//
//  Created by Training on 29/07/16.
//  Copyright © 2016 Training. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    
    var lastKnownLocation:CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
    }
    
    
    @IBAction func updateLocation(_ sender: AnyObject) {
        
        let authCode = CLLocationManager.authorizationStatus()
        
        if authCode == CLAuthorizationStatus.notDetermined && locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            if Bundle.main.objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
            }else{
                print("No description provided")
            }
        }else{
            getLocation()
        }
        
    }
    
    func getLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if let currentLocation = locations.first {
            lastKnownLocation = currentLocation
            
            let currentPosition = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: currentPosition, span: coordinateSpan)
            
            mapView.setRegion(region, animated: true)
            
            let positionPin = MKPointAnnotation()
            positionPin.coordinate = currentPosition
            positionPin.title = "Your position"
            positionPin.subtitle = "What an awesome place"
            
            mapView.addAnnotation(positionPin)
            
            
            
        }
        
    }
    
    
    @IBAction func shareLocation(_ sender: AnyObject) {
        
        if lastKnownLocation != nil {
            let database = CKContainer.default().publicCloudDatabase
            
            let locationAlert = UIAlertController(title: "Your Location", message: "Enter a title for your shared Location", preferredStyle: .alert)
            locationAlert.addTextField(configurationHandler: { (textfield:UITextField) in
                textfield.placeholder = "Your location"
            })
            
            locationAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
                
                if let textFieldContent = locationAlert.textFields?.first?.text, locationAlert.textFields?.first?.text != "" {
                    let newLocation = CKRecord(recordType: "Position")
                    newLocation["locationTitle"] = textFieldContent
                    newLocation["sharedLocation"] = self.lastKnownLocation!
                    
                    database.save(newLocation, completionHandler: { (record:CKRecord?, error:NSError?) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                     
                    })
                    
                    
                }
                
                
                
                
                
                
                
            }))
            
            locationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(locationAlert, animated: true, completion: nil)
            
            
        
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

