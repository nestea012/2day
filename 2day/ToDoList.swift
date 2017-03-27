//
//  ToDoList.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/26/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import RealmSwift


class ToDoListManager {
    
    static func data(isTodayMode: Bool) -> [ToDoList] {
        let realm = try! Realm()
        if isTodayMode {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let result = formatter.string(from: date)
            return Array<ToDoList>(realm.objects(ToDoList.self).filter("date = '\(result)'"))
        }
        let list = realm.objects(ToDoList.self)
        return Array<ToDoList>(list)
    }
    
    static func updateItem(item: ToDoList, text: String) {
        let realm = try! Realm()
        try? realm.write {
            item.text = text
        }
    }
    
    static func addAction(actionText: String, isToday: Bool) {
        let realm = try! Realm()
        try! realm.write {
            let action = ToDoList()
            action.text = actionText
            action.id = UUID().uuidString
            if isToday {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                let result = formatter.string(from: date)
                action.date =  result
                action.isToday = true
            }
            action.userIdentificator = UserManager.sharedInstance.userData()?.email
            realm.add(action)
        }
    }
    
    static func updateDoneStatus(item: ToDoList) {
        let realm = try! Realm()
        try! realm.write {
            item.isDone = !item.isDone
            try? realm.commitWrite()
        }
    }
}

class ToDoList: Object {
    dynamic var id: String?
    dynamic var text: String?
    dynamic var isDone: Bool = false
    dynamic var userIdentificator: String?
    dynamic var isToday: Bool = false
    dynamic var date: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


