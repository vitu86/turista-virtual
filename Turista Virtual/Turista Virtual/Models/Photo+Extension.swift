//
//  Photo+Extension.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation

extension Photo {
    // Download image data from given url
    func loadImageFromURL(_ url:String) {
        self.url = url
        let request = NSMutableURLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                return
            }
            self.image = data
            try? DataControllerSingleton.shared.viewContext.save()
        }
        task.resume()
    }
}
