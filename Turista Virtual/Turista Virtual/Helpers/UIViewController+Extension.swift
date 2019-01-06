//
//  UIViewController+Extension.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 06/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    typealias returnAlertFunction = (UIAlertAction) -> Void
    func showAlert(title:String, message:String, okFunction: returnAlertFunction? = nil, cancelFunction: returnAlertFunction? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let cancelFunction = cancelFunction {
            alert.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: cancelFunction))
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okFunction))
        self.present(alert, animated: true)
    }
}
