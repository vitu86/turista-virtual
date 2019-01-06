//
//  DataController.swift
//  Mooskine
//
//  Created by Kathryn Rotondo on 10/11/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

// Made some changes to make it as a Singleton

import Foundation
import CoreData

class DataControllerSingleton {
    
    // MARK: STATIC OBJECT REFERENCE
    static let shared:DataControllerSingleton = DataControllerSingleton()
    
    // MARK: Properties
    var persistentContainer:NSPersistentContainer!
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // private init for override purpose
    private init() {
    }
    
    func load(modelName:String, completion: (() -> Void)? = nil) {
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

// MARK: Autosaving
extension DataControllerSingleton {
    func autoSaveViewContext(interval:TimeInterval = 10) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}

