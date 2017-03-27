//
//  User.swift
//  SoSueMe
//
//  Created by Anastasiya Dumyak on 2/27/17.
//  Copyright © 2017 Inoxoft. All rights reserved.
//

import UIKit

let kUserInformation = "UserInformationKey"

class User: NSObject, NSCoding {
    var email: String
    var username: String
    var password: String
    
    init(email: String,username: String,password: String) {
        self.email = email
        self.username = username
        self.password = password
    }
    
    required init(coder decoder: NSCoder) {
        self.email = decoder.decodeObject(forKey: "email") as? String ?? ""
        self.username = decoder.decodeObject(forKey: "username") as? String ?? ""
        self.password = decoder.decodeObject(forKey: "password") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(email, forKey: "email")
        coder.encode(username, forKey: "username")
        coder.encode(password, forKey: "password")
    }
}
