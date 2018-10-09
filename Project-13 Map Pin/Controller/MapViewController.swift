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
    var shouldRemovePin = false
    var afterSearch = false
    
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
            mapView.delegate = self
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
            let touchPin = Pin(coordinate: touchCoordinate, title: "", subtitle: "")
            
            let clLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
            mapView.addAnnotation(touchPin)
            
            let geoDecoder = CLGeocoder()
            geoDecoder.reverseGeocodeLocation(clLocation) { (placemark, _) in
                
                let addDialog = UIAlertController(title: "Add", message: "Please enter location details", preferredStyle: .alert)
                addDialog.addTextField { (tf) in
                    tf.placeholder = "City"
                    tf.borderStyle = .none
                    if let info = placemark, info.count > 0{
                        tf.text = info.first!.name
                    }
                }
                addDialog.addTextField { (tf) in
                    tf.placeholder = "Details"
                    tf.borderStyle = .none
                }
                addDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.mapView.removeAnnotations(self.mapView.annotations.filter{ $0.coordinate == touchCoordinate})
                    addDialog.dismiss(animated: true, completion: nil)
                }))
                addDialog.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                    addDialog.dismiss(animated: true, completion: nil)
                    let pinToAdded = Pin(coordinate: touchCoordinate, title: addDialog.textFields?.first?.text ?? "", subtitle: addDialog.textFields?[1].text ?? "")
                    self.callback?.didAdd(pinAt: pinToAdded)
                    self.model?.pins.append(pinToAdded)
                    let annotation = self.mapView.annotations.filter{ $0.coordinate == touchCoordinate}
                    self.mapView.removeAnnotations(annotation)
                    self.mapView.addAnnotation(pinToAdded)
                }))
            
                self.present(addDialog, animated: true, completion: nil)
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

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if manager.location?.coordinate == annotation.coordinate {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "Annotation")
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Annotation")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if afterSearch{
            if shouldRemovePin{
                let a = mapView.annotations.filter({!(model?.pins.map({$0.coordinate}).contains($0.coordinate) ?? false)})
                mapView.removeAnnotations(a)
                shouldRemovePin = false
                afterSearch = false
            } else {
                shouldRemovePin = true
            }
        }
    }
    
}

extension CLLocationCoordinate2D: Equatable{
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKAnnotation{
    func toPin() -> Pin {
        let title = self.title == nil ? "" : self.title!
        var subtitle = ""
        if let nonNullSubtitle = self.subtitle, let certainlyNonNullSubtitle = nonNullSubtitle{
            subtitle = certainlyNonNullSubtitle
        }
 
         return Pin(coordinate: self.coordinate, title: title!, subtitle: subtitle)
    }
    
}
