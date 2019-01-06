//
//  DataHelper.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 06/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class DataHelper {
    // MARK: STATIC OBJECT REFERENCE
    static let shared:DataHelper = DataHelper()
    
    // MARK: Private constants
    private let latitudeValueKey:String = "LatitudeValueKey"
    private let longitudeValueKey:String = "LongitudeValueKey"
    private let latitudeSpanValueKey:String = "LatitudeSpanValueKey"
    private let longitudeSpanValueKey:String = "LongitudeSpanValueKey"
    
    // MARK: Public properties
    var currentAnnotation:MKPointAnnotation?
    
    // private init for override purpose
    private init() {
    }
    
    
    // MARK: UserDefaults functions
    func setNewMapRegion(_ region:MKCoordinateRegion) {
        UserDefaults.standard.set(region.center.latitude, forKey: latitudeValueKey)
        UserDefaults.standard.set(region.center.longitude, forKey: longitudeValueKey)
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: latitudeSpanValueKey)
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: longitudeSpanValueKey)
    }
    
    func getMapCenterSaved(mapView:MKMapView) -> MKCoordinateRegion? {
        if let recordedLatitude = UserDefaults.standard.object(forKey: latitudeValueKey) as? CLLocationDegrees,
            let recordedLongitude = UserDefaults.standard.object(forKey: longitudeValueKey)  as? CLLocationDegrees,
            let recordedSpanLatitude = UserDefaults.standard.object(forKey: latitudeSpanValueKey) as? CLLocationDegrees,
            let recordedSpanLongitude = UserDefaults.standard.object(forKey: longitudeSpanValueKey)  as? CLLocationDegrees
        {
            let newCenter:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: recordedLatitude, longitude: recordedLongitude)
            let newSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: recordedSpanLatitude, longitudeDelta: recordedSpanLongitude)
            let newRegion:MKCoordinateRegion = MKCoordinateRegion(center: newCenter, span: newSpan)
            let regionThatFits = mapView.regionThatFits(newRegion)
            return regionThatFits
        } else {
            return nil
        }
    }
    
    // MARK: CoreData functions
    func getAnnotationsFromSavedPins() -> [MKPointAnnotation] {
        let pins = CoreDataHelper.shared.getPins()
        var result:[MKPointAnnotation] = []
        for pin in pins {
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate.latitude = pin.latitude
            newAnnotation.coordinate.longitude = pin.longitude
            result.append(newAnnotation)
        }
        return result
    }
    
    func saveNewAnnotationAsPin (_ annotation:MKPointAnnotation) {
        CoreDataHelper.shared.setPintToCoreData(pinToSave: annotation.coordinate)
    }
    
    func getPhotosFromCurrentAnnotation () -> [Photo] {
        if let pin:Pin = CoreDataHelper.shared.getPinFromCoordinate(currentAnnotation!.coordinate){
            return CoreDataHelper.shared.getPhotosFromPin(pin)
        } else {
            return []
        }
    }
}
