//
//  Photo+Extension.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation
import UIKit

extension Photo {
    // Download image data from given url
    typealias returnFunctionType = (UIImage) -> Void
    func loadImageFromURL(_ url:String, onComplete: returnFunctionType? = nil) {
        self.url = url
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            self.image = data
            try? CoreDataHelper.shared.viewContext.save()
            DispatchQueue.main.async {
                if let onComplete = onComplete {
                    onComplete(UIImage(data: self.image!)!)
                }
            }
        }
        task.resume()
    }
}
