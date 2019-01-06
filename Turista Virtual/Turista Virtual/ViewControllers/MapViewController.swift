//
//  ViewController.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Private constants
    private let latitudeValueKey:String = "LatitudeValueKey"
    private let longitudeValueKey:String = "LongitudeValueKey"
    private let latitudeSpanValueKey:String = "LatitudeSpanValueKey"
    private let longitudeSpanValueKey:String = "LongitudeSpanValueKey"
    
    // MARK: Private properties
    private var currentAnnotation:MKPointAnnotation?
    
    // MARK: View Controller Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Private functions
    private func configureMapView() {
        // Add long press event to put pins
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
        
        fillMap()
        centerMap()
        
        // Set delegate of the map view to self (functions in extenstion below)
        mapView.delegate = self
    }
    
    private func fillMap() {
        // Fill map with saved data (if any)
        let fetch:NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? DataControllerSingleton.shared.viewContext.fetch(fetch) {
            for item in result {
                addPinToMap(item)
            }
        }
    }
    
    private func addPinToMap(_ pin:Pin) {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate.latitude = pin.latitude
        newAnnotation.coordinate.longitude = pin.longitude
        mapView.addAnnotation(newAnnotation)
    }
    
    private func centerMap() {
        // Check if there's any object recorded, then make the new region for the map and set it
        if let recordedLatitude = UserDefaults.standard.object(forKey: latitudeValueKey) as? CLLocationDegrees,
            let recordedLongitude = UserDefaults.standard.object(forKey: longitudeValueKey)  as? CLLocationDegrees,
            let recordedSpanLatitude = UserDefaults.standard.object(forKey: latitudeSpanValueKey) as? CLLocationDegrees,
            let recordedSpanLongitude = UserDefaults.standard.object(forKey: longitudeSpanValueKey)  as? CLLocationDegrees
        {
            let newCenter:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: recordedLatitude, longitude: recordedLongitude)
            let newSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: recordedSpanLatitude, longitudeDelta: recordedSpanLongitude)
            let newRegion:MKCoordinateRegion = MKCoordinateRegion(center: newCenter, span: newSpan)
            let regionThatFits = mapView.regionThatFits(newRegion)
            mapView.setRegion(regionThatFits, animated: true)
        }
    }
    
    @objc private func addPinToMap(longGesture: UIGestureRecognizer) {
        // Define coordinates
        let touchPoint = longGesture.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        if longGesture.state == .began {
            // If is the begin of the touch, create the annotation and add it to the map
            currentAnnotation = MKPointAnnotation()
            currentAnnotation!.coordinate = newCoordinates
            mapView.addAnnotation(currentAnnotation!)
        } else if longGesture.state == .changed {
            // If the user is still holding, update the annotation position
            if let currentAnnotation = currentAnnotation {
                currentAnnotation.coordinate = newCoordinates
            }
        } else if longGesture.state == .ended {
            // If the user lift the finger, work is done.
            // Let's nil the current annotation object and save the pin to coredata.
            setPintToCoreData(pinToSave: currentAnnotation!.coordinate)
            currentAnnotation = nil
        }
    }
    
    private func setPintToCoreData(pinToSave:CLLocationCoordinate2D) {
        // Save the pin to core data
        let pin:Pin = Pin(context: DataControllerSingleton.shared.viewContext)
        pin.latitude = pinToSave.latitude
        pin.longitude = pinToSave.longitude
        try? DataControllerSingleton.shared.viewContext.save()
        // Put its image list to download in background
        FlickrHelper.shared.downloadPhotosFromPin(pin)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: Mapview Delegate Functions
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            print("Did select: ", annotation.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: latitudeValueKey)
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: longitudeValueKey)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: latitudeSpanValueKey)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: longitudeSpanValueKey)
    }
}


