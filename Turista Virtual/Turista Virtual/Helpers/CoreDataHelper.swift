//
//  CoreDataHelper.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 06/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CoreDataHelper {
    
    // MARK: STATIC OBJECT REFERENCE
    static let shared:CoreDataHelper = CoreDataHelper()
    
    // MARK: Private constants
    private let pinFetch:NSFetchRequest<Pin> = Pin.fetchRequest()
    private let photoFetch:NSFetchRequest<Photo> = Photo.fetchRequest()
    
    private var persistentContainer:NSPersistentContainer!
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // private init for override purpose
    private init() {
    }
    
    // Inital load function
    func load(modelName:String, completion: (() -> Void)? = nil) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    // MARK: Pins Functions
    func getPins() -> [Pin] {
        var result:[Pin] = []
        if let response = try? viewContext.fetch(pinFetch) {
            result = Array(response)
        }
        return result
    }
    
    func setPintToCoreData(pinToSave:CLLocationCoordinate2D) -> Pin{
        // Save the pin to core data
        let pin:Pin = Pin(context: viewContext)
        pin.latitude = pinToSave.latitude
        pin.longitude = pinToSave.longitude
        try? viewContext.save()
        return pin
    }
    
    func getPinFromCoordinate(_ coord:CLLocationCoordinate2D) -> Pin? {
        let predicate:NSPredicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", coord.latitude, coord.longitude)
        pinFetch.predicate = predicate
        if let response = try? viewContext.fetch(pinFetch) {
            pinFetch.predicate = nil
            if response.count > 0 {
                return response[0]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: Photos functions
    func getFetchedResultsControllerOfPhotos(from pin:Pin) -> NSFetchedResultsController<Photo> {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func deletePhoto(_ photo:Photo) {
        viewContext.delete(photo)
        try? viewContext.save()
    }
}
