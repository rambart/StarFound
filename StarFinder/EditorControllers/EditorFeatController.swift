//
//  FeatControllers.swift
//  StarFinder
//
//  Created by Tom on 4/18/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorFeatNavController: UINavigationController {
    var feature = Feature()
    var forObj: Any = 0
    var PC = PlayerCharacter()
}

class EditorFeatController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var optionsTable: UITableView!
    
    @IBOutlet weak var optionsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var modifiersTableHeight: NSLayoutConstraint!
    
    var PC = PlayerCharacter()
    var feature = Feature()
    var modifiers = [Bonus]()
    var options = [Option]()
    var forObj: Any = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        modifiersTable.delegate = self
        optionsTable.delegate = self
        modifiersTable.dataSource = self
        optionsTable.dataSource = self
        modifiersTable.setEditing(true, animated: false)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        PC = (self.navigationController as! EditorFeatNavController).PC
        feature = (self.navigationController as! EditorFeatNavController).feature
        forObj = (self.navigationController as! EditorFeatNavController).forObj
        nameTextField.text = feature.name
        descriptionLabel.text = feature.content
        modifiers = feature.featureBonus?.array as! [Bonus]
        options = feature.featureOptions?.array as! [Option]
        
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
        
        optionsTable.reloadData()
        optionsTableHeight.constant = optionsTable.contentSize.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        modifiers = feature.featureBonus?.array as! [Bonus]
        options = feature.featureOptions?.array as! [Option]
        
        descriptionLabel.text = feature.content
        
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
        
        optionsTable.reloadData()
        optionsTableHeight.constant = optionsTable.contentSize.height
    }
    
    
    @objc func cancel() {
        if feature.feats == nil {
            context.delete(feature)
        }
        self.dismiss(animated: true)
    }
    
    @objc func done() {
        feature.name = nameTextField.text
        feature.content = descriptionLabel.text
        if let obj = forObj as? PlayerCharacter {
            obj.addToFeats(feature)
        }
        if let obj = forObj as? Level {
            obj.addToClassFeature(feature)
        }
        if let obj = forObj as? Race {
            obj.addToRacialFeature(feature)
        }
        if let obj = forObj as? Theme {
            obj.addToThemeFeature(feature)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func editContent(_ sender: UITapGestureRecognizer) {
        let textEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditorNavController") as! TextEditorNavController
        textEditVC.feature = self.feature
        present(textEditVC, animated: true)
    }
    
    
    @IBAction func addModifier(_ sender: Any) {
        let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
        newModVC.PC = PC
        newModVC.forObject = feature
        present(newModVC, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // Mark: - Table Views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == modifiersTable {
            return modifiers.count + 1
        } else {
            return options.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == modifiersTable {
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Modifier"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "modifierCell", for: indexPath) as! ModifierCell
                cell.nameLabel.text = modifiers[indexPath.row - 1].type
                cell.bonusLabel.text = cleanPossNeg(of: Int(modifiers[indexPath.row - 1].bonus))
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionCell
            cell.option = options[indexPath.row]
            cell.nameLabel.text = options[indexPath.row].name
            if options[indexPath.row].selected {
                cell.enabledButton.setTitle("●", for: .normal)
            } else {
                cell.enabledButton.setTitle("○", for: .normal)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == modifiersTable {
            if indexPath.row == 0 {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = feature
                present(newModVC, animated: true)
            } else {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = feature
                newModVC.previousMod = modifiers[indexPath.row - 1]
                present(newModVC, animated: true)
            }
        } else {
            let view = storyboard?.instantiateViewController(withIdentifier: "CharacterFeatController") as! CharacterFeatController
            view.name = options[indexPath.row].name ?? ""
            view.content = options[indexPath.row].content ?? ""
            tableView.deselectRow(at: indexPath, animated: true)
            present(view, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .insert
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let modifier = modifiers[indexPath.row - 1]
            modifiers.remove(at: indexPath.row - 1)
            context.delete(modifier)
            
            modifiersTable.reloadData()
            modifiersTableHeight.constant = modifiersTable.contentSize.height
        }
        if editingStyle == .insert {
            let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            newModVC.PC = PC
            newModVC.forObject = feature
            present(newModVC, animated: true)
        }
    }
    
    
    
    
}


class ModifierCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    
    
}




class OptionCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var enabledButton: UIButton!
    
    
    var option = Option()
    
    @IBAction func toggleEnable(_ sender: Any) {
        option.selected = !option.selected
        if option.selected {
            enabledButton.setTitle("●", for: .normal)
        } else {
            enabledButton.setTitle("○", for: .normal)
        }
    }
}

