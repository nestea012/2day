//
//  ToDoListController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/26/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ToDoTableViewCellDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todoTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewHeigthConstraint: NSLayoutConstraint!
    
    var tableViewEditLongPress:UILongPressGestureRecognizer!
    var isTodayMode = false
    var todoDS:[ToDoList] = []
     var isEditMode: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDS()
    }
    
    func setupUI() {
        
        navigationItem.title = "Todo list"
        view.layer.contents = UIImage(named:"natureplaceholder")?.cgImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
        
        todoTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ToDoListController.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
        
        setupDS()
        setupEditGestureRecognizer()
    }
    
    func setupDS() {
        todoDS = []
        if isTodayMode {
            todoDS = ToDoListManager.data(isTodayMode: true)
        } else {
            todoDS = ToDoListManager.data(isTodayMode: false)
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 130
        tableView.reloadData()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction func addNewAction(_ sender: Any) {
        
        if !isEditMode {
            if todoTextView.text == "" {return}
        }
        
        if isEditMode {
            isEditMode = false
            tableView.isEditing = false
            addButton.setTitle("Tap to save", for: .normal)
            return
        } else {
            if isTodayMode {
                ToDoListManager.addAction(actionText: todoTextView.text, isToday: true)
                todoTextView.text = ""
            } else {
                ToDoListManager.addAction(actionText: todoTextView.text, isToday: false)
                todoTextView.text = ""
            }
            
            setupDS()
            endEditing()
        }
    }
    
    func selectedAt(index:Int) {
        ToDoListManager.updateDoneStatus(item: todoDS[index])
        let indexPath = NSIndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath as IndexPath], with: .fade)
    }
}

extension ToDoListController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoDS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
        cell.actionLabel.text = todoDS.reversed()[indexPath.row].text
        cell.checkButton.tag = indexPath.row
        cell.cellDelegate = self
        if todoDS[indexPath.row].isDone {
            cell.checkImageView.image = UIImage(named:"radiobuttonchecked")
        } else {
            cell.checkImageView.image = UIImage(named:"radiobuttonempty")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let alert = UIAlertController(title: "Change", message: "Please update your text", preferredStyle:.alert)
            alert.addTextField { (textField) in
                textField.text = self.todoDS[indexPath.row].text
            }
            let okAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                if alert.textFields?.first?.text != "" {
                    ToDoListManager.updateItem(item: self.todoDS[indexPath.row], text: (alert.textFields?.first?.text)!)
                }
                self.tableView.reloadData()
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.tableView.reloadData()
            })
            alert.addAction(okAction)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        editAction.backgroundColor = .black
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let realm = try? Realm()
            try? realm?.write {
                realm?.delete(self.todoDS[indexPath.row])
            }
            self.setupDS()
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try? Realm()
            try? realm?.write {
                realm?.delete(todoDS[indexPath.row])
            }
            setupDS()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let realm = try? Realm()
        try? realm?.write {
            let itemToMove = todoDS[sourceIndexPath.row]
            todoDS.remove(at: sourceIndexPath.row)
            todoDS.insert(itemToMove, at: destinationIndexPath.row)
        }
    }
    
    func setupEditGestureRecognizer() {
        tableViewEditLongPress = UILongPressGestureRecognizer(target: self, action: #selector(ListController.enableTableViewEditMode(_:)))
        tableViewEditLongPress.delegate = self
        tableView.addGestureRecognizer(tableViewEditLongPress)
    }
    
    func enableTableViewEditMode(_ longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
            tableView.isEditing = true
            isEditMode = true
            addButton.setTitle("End editing", for: .normal)
        }
    }
}

extension ToDoListController {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewHeigthConstraint.constant = 120
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewHeigthConstraint.constant = 35
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

protocol ToDoTableViewCellDelegate {
    func selectedAt(index:Int)
}

class ToDoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    
    var cellDelegate:ToDoTableViewCellDelegate?
    
    @IBAction func actionDone(_ sender: Any) {
        cellDelegate?.selectedAt(index: (sender as! UIButton).tag)
    }
}
