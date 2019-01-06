//
//  ViewController.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PhotoAlbumViewController
        vc.annotationToShow = (sender as! MKPointAnnotation)
    }
    
    // MARK: Private functions
    private func configureMapView() {
        // Add long press event to put pins
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
        
        // Fill map with saved data (if any)
        mapView.addAnnotations(DataHelper.shared.getAnnotationsFromSavedPins())
        
        // Check if there's any object recorded, then make the new region for the map and set it
        if let region = DataHelper.shared.getMapCenterSaved(mapView: mapView) {
            mapView.setRegion(region, animated: true)
        }
        
        // Set delegate of the map view to self (functions in extenstion below)
        mapView.delegate = self
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
            DataHelper.shared.saveNewAnnotationAsPin(currentAnnotation!)
            currentAnnotation = nil
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // MARK: Mapview Delegate Functions
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            performSegue(withIdentifier: "segueToPhotoAlbum", sender: annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DataHelper.shared.setNewMapRegion(mapView.region)
    }
}


