//
//  UIAlertController+DefaultStyle.swift
//  Dine
//
//  Created by doss-zstch1212 on 14/05/24.
//

import Foundation
import UIKit

extension UIAlertController {
    func defaultStyle(title: String, message: String) -> UIViewController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        return alert
    }
}
