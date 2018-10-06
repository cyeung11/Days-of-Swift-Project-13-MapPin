//
//  ViewController.swift
//  Project-13 Map Pin
//
//  Created by Chris on 2/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let targetLocationZoomDistance = 10000.0
    var shouldCenterUserLocation = false
    
    var targetLocation: CLLocationCoordinate2D?
    let manager = CLLocationManager()
    var model: MapPins?
    var callback: DidSelectLocationCallback?
    
    @IBOutlet weak var searchButton: UIButton!{
        didSet{
            searchButton.layer.cornerRadius = 7.5
            searchButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var myLocation: UIButton!{
        didSet{
            myLocation.layer.cornerRadius = 7.5
            myLocation.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            if let model = model{
                mapView.showAnnotations(model.pins, animated: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        if let targetLocation = targetLocation{
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(targetLocation, targetLocationZoomDistance, targetLocationZoomDistance), animated: true)
        } else {
            shouldCenterUserLocation = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if CLLocationManager.locationServicesEnabled(){
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                mapView.showsUserLocation = true
                myLocation.isEnabled = true
                manager.startUpdatingLocation()
            } else if CLLocationManager.authorizationStatus() != .denied{
                manager.requestWhenInUseAuthorization()
            }
        }
    }
    
    @IBAction func selectLocation(_ sender: UILongPressGestureRecognizer) {
        if callback != nil{
            let touchLocation = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            let clLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            let geoDecoder = CLGeocoder()
            geoDecoder.reverseGeocodeLocation(clLocation) { (placemark, _) in
                
                self.callback?.didSelect(locationAt: touchCoordinate, withAdditionalInfo: placemark)
                self.callback = nil
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    
    
    @IBAction func showMyLocation(_ sender: Any) {
        if let lastLocation = manager.location{
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, targetLocationZoomDistance, targetLocationZoomDistance), animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search", let searchVC = segue.destination as? SearchLocationTableViewController{
            searchVC.region = mapView.region
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            myLocation.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0{
            if shouldCenterUserLocation{
                mapView.setRegion(MKCoordinateRegionMakeWithDistance(locations.first!.coordinate, targetLocationZoomDistance, targetLocationZoomDistance), animated: true)
                shouldCenterUserLocation = false
            }
        }
    }
}

