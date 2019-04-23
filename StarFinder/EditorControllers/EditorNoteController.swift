//
//  EditorNoteController.swift
//  StarFinder
//
//  Created by Tom on 5/25/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorNoteNavController: UINavigationController {
    var PC = PlayerCharacter()
    var armor = Armor()
    var weapon = Weapon()
    var note = Note()
    var fusion = Fusion()
}

class EditorNoteController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var armor = Armor()
    var weapon = Weapon()
    var note = Note()
    var fusion = Fusion()
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        
        nameTextField.delegate = self
        contentTextView.delegate = self
        
        PC = (self.navigationController as! EditorNoteNavController).PC
        armor = (self.navigationController as! EditorNoteNavController).armor
        weapon = (self.navigationController as! EditorNoteNavController).weapon
        note = (self.navigationController as! EditorNoteNavController).note
        fusion = (self.navigationController as! EditorNoteNavController).fusion

        if fusion.managedObjectContext != nil {
            nameTextField.text = fusion.name ?? ""
            contentTextView.text = fusion.content ?? ""
        } else {
            nameTextField.text = note.name ?? ""
            contentTextView.text = note.content ?? ""
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func cancel() {
        if note.managedObjectContext != nil && note.forPC == nil {
            context.delete(note)
        }
        if fusion.managedObjectContext != nil && fusion.armorFusion == nil && fusion.weaponFusion == nil {
            context.delete(fusion)
        }
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        if note.managedObjectContext != nil {
            note.name = nameTextField.text
            note.content = contentTextView.text
            note.forPC = PC
        } else if fusion.managedObjectContext != nil {
            fusion.name = nameTextField.text
            fusion.content = contentTextView.text
            if armor.managedObjectContext != nil {
                fusion.armorFusion = armor
            } else if weapon.managedObjectContext != nil {
                fusion.weaponFusion = weapon
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentTextView.contentInset = UIEdgeInsets.zero
        } else {
            contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        contentTextView.scrollIndicatorInsets = contentTextView.contentInset
        
        let selectedRange = contentTextView.selectedRange
        contentTextView.scrollRangeToVisible(selectedRange)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
