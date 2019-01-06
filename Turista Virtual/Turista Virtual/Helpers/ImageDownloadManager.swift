//
//  DownloadManager.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 06/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloadManager {
    
    // MARK: STATIC OBJECT REFERENCE
    static let shared:ImageDownloadManager = ImageDownloadManager()
    
    // private init for override purpose
    private init() {
    }
    
    func downloadImage(from photo:Photo, toShowIn collectionView:UICollectionView, at indexPath:IndexPath) {
        DispatchQueue.global(qos: .background).async {
            if let imageData:Data = try? Data(contentsOf: URL(string: photo.url!)!) {
                photo.image = imageData
                DispatchQueue.main.async {
                    try? CoreDataHelper.shared.viewContext.save()
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
}
