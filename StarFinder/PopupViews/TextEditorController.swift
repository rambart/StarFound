//
//  TextEditorController.swift
//  StarFinder
//
//  Created by Tom on 4/20/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class TextEditorNavController: UINavigationController {
    var feature = Feature()
    var spell = Spell()
    var armor = Armor()
    var weapon = Weapon()
    var item = Item()
}

class TextEditorController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textEditor: UITextView!
    
    var feature = Feature()
    var spell = Spell()
    var armor = Armor()
    var weapon = Weapon()
    var item = Item()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        textEditor.delegate = self
        
        feature = (self.navigationController as! TextEditorNavController).feature
        spell = (self.navigationController as! TextEditorNavController).spell
        armor = (self.navigationController as! TextEditorNavController).armor
        weapon = (self.navigationController as! TextEditorNavController).weapon
        item = (self.navigationController as! TextEditorNavController).item
        
        if feature.managedObjectContext == context {
            textEditor.text = feature.content
        } else if spell.managedObjectContext == context {
            textEditor.text = spell.content
        } else if armor.managedObjectContext == context {
            textEditor.text = armor.content
        } else if weapon.managedObjectContext == context {
            textEditor.text = weapon.content
        } else if item.managedObjectContext == context {
            textEditor.text = item.content
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func cancel() {
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        if feature.managedObjectContext == context {
            feature.content = textEditor.text
        } else if spell.managedObjectContext == context {
            spell.content = textEditor.text
        } else if armor.managedObjectContext == context {
            armor.content = textEditor.text
        } else if weapon.managedObjectContext == context {
            weapon.content = textEditor.text
        } else if item.managedObjectContext == context {
            item.content = textEditor.text
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textEditor.contentInset = UIEdgeInsets.zero
        } else {
            textEditor.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        textEditor.scrollIndicatorInsets = textEditor.contentInset
        
        let selectedRange = textEditor.selectedRange
        textEditor.scrollRangeToVisible(selectedRange)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
