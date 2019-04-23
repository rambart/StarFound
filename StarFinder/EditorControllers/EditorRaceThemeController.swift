//
//  EditorRaceThemeController.swift
//  StarFinder
//
//  Created by Tom on 4/20/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorRaceThemeNavController: UINavigationController {
    
    var PC = PlayerCharacter()
    var mode = ""
}

class EditorRaceThemeController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var featuresTable: UITableView!
    @IBOutlet weak var modifiersTableHeight: NSLayoutConstraint!
    @IBOutlet weak var featuresTableHeight: NSLayoutConstraint!
    
    
    var PC = PlayerCharacter()
    var race = Race()
    var theme = Theme()
    var mode = ""
    var modifiers = [Bonus]()
    var features = [Feature]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modifiersTable.delegate = self
        modifiersTable.dataSource = self
        featuresTable.delegate = self
        featuresTable.dataSource = self
        nameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))

        PC = (self.navigationController as! EditorRaceThemeNavController).PC
        mode = (self.navigationController as! EditorRaceThemeNavController).mode
        race = (self.navigationController as! EditorRaceThemeNavController).PC.race ?? Race()
        theme = (self.navigationController as! EditorRaceThemeNavController).PC.theme ?? Theme()
        
        if mode == "race" {
            modifiers = race.racialBonus?.array as! [Bonus]
            features = race.racialFeature?.array as! [Feature]
            nameTextField.text = race.name
            changeButton.setTitle("Change Race", for: .normal)
        } else {
            modifiers = theme.themeBonus?.array as! [Bonus]
            features = theme.themeFeature?.array as! [Feature]
            nameTextField.text = theme.name
            changeButton.setTitle("Change Theme", for: .normal)
        }
        
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
        modifiersTable.setEditing(true, animated: false)
        
        featuresTable.reloadData()
        featuresTableHeight.constant = featuresTable.contentSize.height
        featuresTable.setEditing(true, animated: false)
        
    }
    
    @objc func PCChanged() {
        if mode == "race" {
            race = PC.race!
            modifiers = race.racialBonus?.array as! [Bonus]
            features = race.racialFeature?.array as! [Feature]
            nameTextField.text = race.name
            changeButton.setTitle("Change Race", for: .normal)
        } else {
            theme = PC.theme!
            modifiers = theme.themeBonus?.array as! [Bonus]
            features = theme.themeFeature?.array as! [Feature]
            nameTextField.text = theme.name
            changeButton.setTitle("Change Theme", for: .normal)
        }
        
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
        
        featuresTable.reloadData()
        featuresTableHeight.constant = featuresTable.contentSize.height
    }

    @objc func cancel() {
        self.dismiss(animated:true)
    }
    
    @objc func save() {
        if mode == "race" {
            race.name = nameTextField.text
        } else {
            theme.name = nameTextField.text
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        self.dismiss(animated:true)
    }
    
    @IBAction func chooseNew(_ sender: UIButton) {
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let newRTCvc = self.storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newRTCvc.mode = self.mode
            newRTCvc.PC = self.PC
            pvc?.present(newRTCvc, animated: true)
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == modifiersTable {
            return modifiers.count + 1
        } else {
            return features.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == modifiersTable {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.sizeToFit()
                cell.textLabel?.text = "Add New Modifier"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ModifierCell", for: indexPath) as! ModifierCell
                cell.nameLabel.text = modifiers[indexPath.row - 1].type
                cell.bonusLabel.text = cleanPossNeg(of: Int(modifiers[indexPath.row - 1].bonus))
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.sizeToFit()
                cell.textLabel?.text = "Add New Feature"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath)
                cell.textLabel?.text = features[indexPath.row - 1].name
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .insert
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            if tableView == modifiersTable {
                let mod = modifiers[indexPath.row - 1]
                modifiers.remove(at: indexPath.row - 1)
                context.delete(mod)
                
                modifiersTable.reloadData()
                modifiersTableHeight.constant = modifiersTable.contentSize.height
            }
            if tableView == featuresTable {
                let feat = features[indexPath.row - 1]
                features.remove(at: indexPath.row - 1)
                context.delete(feat)
                
                featuresTable.reloadData()
                featuresTableHeight.constant = featuresTable.contentSize.height
            }
        }
        if editingStyle == .insert {
            if tableView == modifiersTable {
                let newModvc = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModvc.PC = self.PC
                if mode == "race" {
                    newModvc.forObject = race
                } else {
                    newModvc.forObject = theme
                }
                present(newModvc, animated: true)
            } else {
                let featVC = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
                let newFeature = Feature(context: context)
                newFeature.name = "New Feature"
                if mode == "race" {
                    featVC.forObj = race
                } else {
                    featVC.forObj = theme
                }
                featVC.feature = newFeature
                featVC.PC = PC
                present(featVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == modifiersTable {
            let newModvc = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            newModvc.PC = PC
            if indexPath.row != 0 {
                newModvc.previousMod = modifiers[indexPath.row - 1]
            }
            if mode == "race" {
                newModvc.forObject = race
            } else {
                newModvc.forObject = theme
            }
            tableView.deselectRow(at: indexPath, animated: true)
            present(newModvc, animated: true)
        } else if tableView == featuresTable {
            let featVC = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
            if mode == "race" {
                featVC.forObj = race
            } else {
                featVC.forObj = theme
            }
            if indexPath.row == 0 {
                let newFeature = Feature(context: context)
                featVC.feature = newFeature
            } else {
                featVC.feature = features[indexPath.row - 1]
            }
            featVC.PC = PC
            tableView.deselectRow(at: indexPath, animated: true)
            present(featVC, animated: true)
            
        }
    }
    
    
    
}

