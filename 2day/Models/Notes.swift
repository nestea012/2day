//
//  Notes.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/25/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import RealmSwift


class NotesManager {
    
    static func data(isTodayMode: Bool) -> [Notes] {
        let realm = try! Realm()
        if isTodayMode {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let result = formatter.string(from: date)
            return Array<Notes>(realm.objects(Notes.self).filter("date = '\(result)'"))
        }
        
        let list = realm.objects(Notes.self)
        return Array<Notes>(list)
    }
    
    static func updateItem(item: Notes, text: String) {
        let realm = try! Realm()
        try? realm.write {
            item.text = text
        }
    }
    
    static func addItem(text: String, isToday: Bool) {
        let realm = try! Realm()
        try! realm.write {
            let action = Notes()
            action.text = text
            action.id = UUID().uuidString
            action.userIdentificator = UserManager.sharedInstance.userData()?.email
            if isToday {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let result = formatter.string(from: date)
                action.date = result
                action.isTodey = isToday
            }
            
            realm.add(action)
        }
    }
}

class Notes: Object {
    dynamic var id: String?
    dynamic var text: String?
    dynamic var userIdentificator: String?
    dynamic var date: String?
    dynamic var isTodey: Bool = false
    override static func primaryKey() -> String? {
        return "id"
    }
}

