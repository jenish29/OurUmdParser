//
//  MapViewController.swift
//  UmdUtility
//
//  Created by pc on 7/10/17.
//  Copyright © 2017 Jenish. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    var long = ""
    var lat = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapSetup()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissC))
        gesture.direction = .right
        self.mapView.addGestureRecognizer(gesture)
    
        
    }
    
    func dismissC() {
        mapView = nil
        self.dismiss(animated: true, completion: nil)
        
    }
    
    let locationManager = CLLocationManager()
    
    private func mapSetup() {
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        let annotation = MKPointAnnotation()
        let toLocation  = CLLocationCoordinate2DMake(lat.toDouble()!, long.toDouble()!)
        self.toLocation = toLocation
        annotation.coordinate = toLocation
        mapView.addAnnotation(annotation)
        
        
        
    }
    
    private var myLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var toLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    func showRouteOnMap() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: myLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toLocation))
        request.requestsAlternateRoutes = true
        request.transportType = .walking
        
        
        let directions = MKDirections(request: request)
        
        directions.calculate { (response, err) in
            guard let response = response else {return}
                if response.routes.count > 0 {
                    let rekt = response.routes[0].polyline.boundingMapRect
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
                    
                    let overlay = response.routes[0].polyline
                    self.mapView.add(overlay, level: .aboveRoads)
                }
                
            }
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = UIColor.blue
            polylineRender.lineWidth = 2.0
            return polylineRender
   
        
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        let mlc  :CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        myLocation = mlc
        
        self.showRouteOnMap()
        self.locationManager.stopUpdatingLocation()
    }

}

class CustomRender : MKPolylineRenderer {
    override func applyStrokeProperties(to context: CGContext, atZoomScale zoomScale: MKZoomScale) {
        applyStrokeProperties(to: context, atZoomScale: zoomScale)
        
    }
}


