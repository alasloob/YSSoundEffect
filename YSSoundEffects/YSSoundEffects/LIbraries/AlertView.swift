//
//  AlertView.swift
//  YSSoundEffects
//
//  Created by Youssef Eid on 04/07/1440 AH.
//  Copyright © 1440 Youssef Eid. All rights reserved.
//

import Foundation
import UIKit

class AlertView {
    
    static func show(_ title: String, message: String, vc controllerView: UIViewController) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler:
            { (action) in
                alertView.dismiss(animated: true)
        }))
        controllerView.present(alertView, animated: true)
    }
    
}
