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
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Private functions
    private func configureMapView() {
        mapView.delegate = self
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(longGesture:)))
        mapView.addGestureRecognizer(longGesture)
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
            // If the user lift the finger
            currentAnnotation = nil
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    // MARK: Mapview Delegate Functions
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            print("Did select: ", annotation.coordinate)
        }
    }
}

