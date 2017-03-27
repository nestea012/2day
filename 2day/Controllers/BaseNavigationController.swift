//
//  BaseNavigationController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/26/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLogoutButton()
    }
    
    func setupLogoutButton() {
        let button = UIBarButtonItem(image: UIImage(named:"logout"), style: .plain, target: self, action: #selector(BaseNavigationController.logout))
       navigationBar.items?.first?.rightBarButtonItem = button
    }

    func logout() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController") as! LoginController
        viewController.isModalInPopover = true
        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
        UserManager.sharedInstance.logout()
    }
}
