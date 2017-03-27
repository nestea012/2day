//
//  Alerts.swift
//  Guardian
//
//  Created by Anastasiya Dumyak on 2/17/17.
//  Copyright © 2017 Inoxoft. All rights reserved.
//

import UIKit

class Alerts: NSObject {

    static func showAlertWith(title: String, description:String, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancel)
        controller.present(alert, animated: true, completion: nil)
    }
}
