//
//  FlickrHelper.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation

class FlickrHelper {
    
    // MARK: STATIC OBJECT REFERENCE
    static let shared:FlickrHelper = FlickrHelper()
    
    // MARK: Private properties and constants
    private let flickr_api_key:String = "36d4bbc25bbadefaeaae521e88642e9a"
    
    private var latitude:Double = 0.0
    private var longitude:Double = 0.0
    private var getPhotoListURL:String = ""
    private var getImageFromPhotoURL:String = ""
    private var currentPin:Pin?
    
    private var getPhotoListTask:URLSessionDataTask!
    private var getPhotoURLTask:URLSessionDataTask!
    
    // private init for override purpose
    private init() {
    }
    
    func downloadPhotosFromPin(_ pin:Pin) {
        currentPin = pin
        latitude = pin.latitude
        longitude = pin.longitude
        
        getPhotoListURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickr_api_key)&lat=\(latitude)&lon=\(longitude)&per_page=30&format=json&nojsoncallback=1"
        
        // cancel tasks so we dont have problems with photos in wrong pins
        if let getPhotoListTask = getPhotoListTask {
            getPhotoListTask.cancel()
        }
        if let getPhotoURLTask = getPhotoURLTask {
            getPhotoURLTask.cancel()
        }
        
        getPhotoList()
    }
    
    // Get photo list and call download image url
    private func getPhotoList() {
        let request = NSMutableURLRequest(url: URL(string: getPhotoListURL)!)
        let session = URLSession.shared
        getPhotoListTask = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                let photoList = json["photos"] as? [String:Any] ?? [:]
                let photos = photoList["photo"] as? [[String:Any]]
                if let photos = photos {
                    for photoItem in photos {
                        self.getPhotoImageURL(id: photoItem["id"] as! String)
                    }
                }
            } catch let err as NSError {
                print(err)
            }
        }
        getPhotoListTask.resume()
    }
    
    // Download image url and call download image data
    private func getPhotoImageURL (id: String) {
        getImageFromPhotoURL = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(flickr_api_key)&photo_id=\(id)&format=json&nojsoncallback=1"
        
        let request = NSMutableURLRequest(url: URL(string: getImageFromPhotoURL)!)
        let session = URLSession.shared
        getPhotoURLTask = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                let sizeList = json["sizes"] as? [String:Any] ?? [:]
                let sizes = sizeList["size"] as? [[String:Any]]
                if let sizes = sizes {
                    for sizeItem in sizes {
                        if sizeItem["label"] as! String == "Square" {
                            let newPhoto:Photo = Photo(context: CoreDataHelper.shared.viewContext)
                            newPhoto.url = (sizeItem["source"] as! String)
                            self.currentPin?.addToPhotos(newPhoto)
                            try? CoreDataHelper.shared.viewContext.save()
                        }
                    }
                }
            } catch let err as NSError {
                print(err)
            }
        }
        getPhotoURLTask.resume()
    }
}
