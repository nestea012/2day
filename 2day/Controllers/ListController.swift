//
//  ListController.swift
//  2day
//
//  Created by Anastasiya Dumyak on 3/25/17.
//  Copyright © 2017 AnastasiyaDumiak. All rights reserved.
//

import UIKit
import RealmSwift

class ListController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var thoughtTextField: UITextView!
    @IBOutlet weak var textViewHeightConstarint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var noteDS:[Notes] = []
    var tableViewEditLongPress:UILongPressGestureRecognizer!
    var isEditMode: Bool = false
    var isTodayMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDS()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDS()
    }
    
    func setupUI() {
        navigationItem.title = "List"
        view.layer.contents = UIImage(named:"natureplaceholder")?.cgImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill
        thoughtTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ListController.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        dateLabel.text = result
        
        setupEditGestureRecognizer()
    }
    
    func setupEditGestureRecognizer() {
        tableViewEditLongPress = UILongPressGestureRecognizer(target: self, action: #selector(ListController.enableTableViewEditMode(_:)))
        tableViewEditLongPress.delegate = self
        tableView.addGestureRecognizer(tableViewEditLongPress)
    }
    
    func setupDS() {
        if isTodayMode {
            noteDS = NotesManager.data(isTodayMode: true)
        } else {
            noteDS = NotesManager.data(isTodayMode: false)
        }
        
        if noteDS.count == 0 {
            tableView.alpha = 0
        } else {
            tableView.alpha = 1
        }
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    @IBAction func addNew(_ sender: Any) {
         if !isEditMode {
            if thoughtTextField.text == "" {return}
         }
        
        if !isEditMode {
            addNewNote()
            endEditing()
        } else {
            isEditMode = false
            tableView.isEditing = false
            saveButton.setTitle("Tap to save", for: .normal)
        }
    }
}

extension ListController {
  
    func enableTableViewEditMode(_ longPressGesture: UILongPressGestureRecognizer) {
        if longPressGesture.state == .began {
                tableView.isEditing = true
                isEditMode = true
                saveButton.setTitle("End editing", for: .normal)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let realm = try? Realm()
        try? realm?.write {
            let itemToMove = noteDS[sourceIndexPath.row]
            noteDS.remove(at: sourceIndexPath.row)
            noteDS.insert(itemToMove, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let realm = try? Realm()
            try? realm?.write {
                realm?.delete(noteDS[indexPath.row])
            }
            setupDS()
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return tableView.isEditing ? .delete : .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            let alert = UIAlertController(title: "Change", message: "Please update your text", preferredStyle:.alert)
            alert.addTextField { (textField) in
                textField.text = self.noteDS[indexPath.row].text
            }
            let okAction = UIAlertAction(title: "Save", style: .default, handler: { (action) in
                if alert.textFields?.first?.text != "" {
                    NotesManager.updateItem(item: self.noteDS[indexPath.row], text: (alert.textFields?.first?.text)!)
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
                realm?.delete(self.noteDS[indexPath.row])
            }
            self.setupDS()
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteDS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        cell.noteLabel.text = noteDS.reversed()[indexPath.row].text
        return cell
    }
}

extension ListController {
    func addNewNote() {
        NotesManager.addItem(text: thoughtTextField.text, isToday: isTodayMode)
        thoughtTextField.text = ""
        setupDS()
    }
}

extension ListController {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewHeightConstarint.constant = 120
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewHeightConstarint.constant = 35
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var noteLabel: UILabel!
}
