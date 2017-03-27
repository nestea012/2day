//
//  UserManager.swift
//  SoSueMe
//
//  Created by Anastasiya Dumyak on 2/27/17.
//  Copyright © 2017 Inoxoft. All rights reserved.
//

import UIKit

class UserManager: NSObject {

    static let sharedInstance = UserManager()
    
    func createNewUser(_ username: String, password: String, email: String) {
        let user = User.init(email: email, username: username, password: password)
        saveData(user)
    }
    
    func saveData(_ user: User) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: user )
        UserDefaults.standard.set(encodedData, forKey: kUserInformation)
    }
    
    func checkUserInformation() -> Bool {
        let user = UserDefaults.standard.object(forKey: kUserInformation)
        if let _ = user {
            return true
        }
        return false
    }
    
    func userData() -> User? {
        if let  user = UserDefaults.standard.object(forKey: kUserInformation) {
             return  NSKeyedUnarchiver.unarchiveObject(with: user as! Data) as? User
        }
        return  nil
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: kUserInformation)
    }
}
