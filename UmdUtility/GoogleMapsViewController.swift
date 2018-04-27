//
//  GoogleMapsViewController.swift
//  UmdUtility
//
//  Created by pc on 7/11/17.
//  Copyright © 2017 Jenish. All rights reserved.
//
import CoreLocation
import UIKit
import GoogleMaps
import MapKit

class GoogleMapsViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate {
    
    var long = ""
    var lat = ""
    var mapView : GMSMapView? = nil
    
    private var controller = MapViewController()
    private var myLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var toLocation : CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var dragView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GMSServices.provideAPIKey("AIzaSyBFKOFfpbBtMllX97qdT6L1WO41f9cejz8")
        
        let camera = GMSCameraPosition.camera(withLatitude: lat.toDouble()!, longitude: long.toDouble()!, zoom: 15)
        
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + 40, width: self.view.frame.size.width, height: self.view.frame.size.height)
        mapView = GMSMapView.map(withFrame: frame, camera: camera)
        self.view.addSubview(mapView!)
        
        let position = CLLocationCoordinate2D(latitude: lat.toDouble()!, longitude: long.toDouble()!)
        let marker = GMSMarker(position: position)
        marker.title = "Hello World"
        marker.map = mapView
        
        toLocation = position
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissC))
        gesture.direction = .right
        self.view.addGestureRecognizer(gesture)
        
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width/2, y: 0, width: 50, height: 50)
        button.setTitle("Current", for: .normal)
        button.addTarget(self, action: #selector(mapSetup), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.blue
        view.addSubview(button)
        mapSetup()
  
    }
    
    func buttonIspressed(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != UIGestureRecognizerState.ended && recognizer.state != .failed && recognizer.velocity(in: self.view).y < 0 && (recognizer.view?.frame.maxY)! < self.view.frame.maxY {
            
            mapView?.frame.size.height = (mapView?.frame.size.height)! + 10
            dragView.frame.origin.y = dragView.frame.origin.y + 10
            controller.view.frame.origin.y = controller.view.frame.origin.y + 10

        }
        else if recognizer.state != UIGestureRecognizerState.ended && recognizer.state != .failed && recognizer.velocity(in: self.view).y > 0 && (recognizer.view?.frame.origin.y)! > self.view.frame.origin.y {
            
            mapView?.frame.size.height = (mapView?.frame.size.height)! - 10
            dragView.frame.origin.y = dragView.frame.origin.y - 10
            controller.view.frame.origin.y = controller.view.frame.origin.y - 10
            controller.view.frame.size.height = controller.view.frame.size.height + 10
            
        }
    }
    
    func dismissC() {
        mapView!.removeFromSuperview()
        mapView = nil
  
        self.dismiss(animated: true, completion: nil)
    }
    
    private var locationManager = CLLocationManager()
    
    @objc private func mapSetup() {
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let coordinate = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        myLocation = coordinate
        
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 18)
        
        mapView?.camera = camera
        mapView?.isMyLocationEnabled = true
        locationManager.stopUpdatingLocation()
        showRouteOnMap()
  
    }
    
    func showRouteOnMap() {
        
        let origin = "\(toLocation.latitude),\(toLocation.longitude)"
        let destination = "\(myLocation.latitude),\(myLocation.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"
        
        getData(url: url) { (data, response, err) in
            if err == nil {
                if let arr = convertDataToDictionary(data: data!)
                {
                   let routes = arr.value(forKey: "routes") as! NSArray
                    for rt in routes {
                        let route = rt as! NSDictionary
                        let dic = route["overview_polyline"] as! NSDictionary
                        let polyLine = dic["points"] as! String
                        self.addPolyLineWithEncodedStringInMap(encodedString: polyLine)
                        
                    }
              
                    
                }

            }
        }
    }
    
    func addPolyLineWithEncodedStringInMap(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 3.0
        polyLine.strokeColor = UIColor.green
        
        polyLine.map = mapView


    }
 
}
