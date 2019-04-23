//
//  EditorClassController.swift
//  StarFinder
//
//  Created by Tom on 4/11/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorClassNavController: UINavigationController {
    var PC = PlayerCharacter()
    var level = Level()
}


class EditorClassController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    
    
    @IBOutlet weak var classNameTextField: UITextField!
    @IBOutlet weak var classLevelsTextField: UITextField!
    @IBOutlet weak var BABTextField: UITextField!
    @IBOutlet weak var fortTextField: UITextField!
    @IBOutlet weak var refTextField: UITextField!
    @IBOutlet weak var willTextField: UITextField!
    @IBOutlet weak var staminaTextField: UITextField!
    @IBOutlet weak var hitPointsTextField: UITextField!
    @IBOutlet weak var skillRanksTextField: UITextField!
    @IBOutlet weak var spellcastingAbilityTextField: UITextField!
    @IBOutlet weak var TextField1: UITextField!
    @IBOutlet weak var TextField2: UITextField!
    @IBOutlet weak var TextField3: UITextField!
    @IBOutlet weak var TextField4: UITextField!
    @IBOutlet weak var TextField5: UITextField!
    @IBOutlet weak var TextField6: UITextField!
    @IBOutlet weak var classFeaturesTable: UITableView!
    @IBOutlet weak var classFeaturesTableHeight: NSLayoutConstraint!
    @IBOutlet weak var BonusSlots1: UILabel!
    @IBOutlet weak var BonusSlots2: UILabel!
    @IBOutlet weak var BonusSlots3: UILabel!
    @IBOutlet weak var BonusSlots4: UILabel!
    @IBOutlet weak var BonusSlots5: UILabel!
    @IBOutlet weak var BonusSlots6: UILabel!
    
    var PC = PlayerCharacter()
    var level = Level()
    var slots = [SpellSlot]()
    var classFeatures = [Feature]()
    
    let oneToTwentyPicker = UIPickerView()
    let spellPicker = UIPickerView()
    let bonusPicker = UIPickerView()
    let abilityPicker = UIPickerView()
    
    var oneToTwenty = [String]()
    var spellArray = [String]()
    var bonusArray = [String]()
    let abilities = ["None", "Intelligence", "Wisdom", "Charisma"]
    
    var currentTextField = UITextField()
    var currentPickerArray = [String]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        
        classFeaturesTable.delegate = self
        classFeaturesTable.dataSource = self
        classFeaturesTable.setEditing(true, animated: false)
        
        classNameTextField.delegate = self
        classLevelsTextField.delegate = self
        BABTextField.delegate = self
        fortTextField.delegate = self
        refTextField.delegate = self
        willTextField.delegate = self
        staminaTextField.delegate = self
        hitPointsTextField.delegate = self
        skillRanksTextField.delegate = self
        spellcastingAbilityTextField.delegate = self
        TextField1.delegate = self
        TextField2.delegate = self
        TextField3.delegate = self
        TextField4.delegate = self
        TextField5.delegate = self
        TextField6.delegate = self
        
        oneToTwenty = [String]()
        for i in 1...20 {
            oneToTwenty.append("\(i)")
        }
        oneToTwentyPicker.delegate = self
        oneToTwentyPicker.dataSource = self
        spellArray = [String]()
        for i in 0...10 {
            spellArray.append("\(i)")
        }
        spellPicker.delegate = self
        spellPicker.dataSource = self
        bonusArray = [String]()
        for i in 0...20 {
            bonusArray.append("\(i)")
        }
        bonusPicker.delegate = self
        bonusPicker.dataSource = self
        abilityPicker.delegate = self
        abilityPicker.dataSource = self
        
        PC = (self.navigationController as! EditorClassNavController).PC
        level = (self.navigationController as! EditorClassNavController).level
        
        slots = level.classSlots?.array as! [SpellSlot]
        reloadLevel()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        classLevelsTextField.inputAccessoryView = toolBar
        BABTextField.inputAccessoryView = toolBar
        fortTextField.inputAccessoryView = toolBar
        refTextField.inputAccessoryView = toolBar
        willTextField.inputAccessoryView = toolBar
        staminaTextField.inputAccessoryView = toolBar
        hitPointsTextField.inputAccessoryView = toolBar
        skillRanksTextField.inputAccessoryView = toolBar
        spellcastingAbilityTextField.inputAccessoryView = toolBar
        TextField1.inputAccessoryView = toolBar
        TextField2.inputAccessoryView = toolBar
        TextField3.inputAccessoryView = toolBar
        TextField4.inputAccessoryView = toolBar
        TextField5.inputAccessoryView = toolBar
        TextField6.inputAccessoryView = toolBar
        
        classLevelsTextField.inputView = oneToTwentyPicker
        BABTextField.inputView = bonusPicker
        fortTextField.inputView = bonusPicker
        refTextField.inputView = bonusPicker
        willTextField.inputView = bonusPicker
        staminaTextField.inputView = bonusPicker
        hitPointsTextField.inputView = bonusPicker
        skillRanksTextField.inputView = bonusPicker
        spellcastingAbilityTextField.inputView = abilityPicker
        TextField1.inputView = spellPicker
        TextField2.inputView = spellPicker
        TextField3.inputView = spellPicker
        TextField4.inputView = spellPicker
        TextField5.inputView = spellPicker
        TextField6.inputView = spellPicker
        
        
        
        
        classFeatures = level.classFeature?.array as! [Feature]
        
        classFeaturesTable.reloadData()
        classFeaturesTableHeight.constant = classFeaturesTable.contentSize.height
        
        updateBonusSpells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
        updateBonusSpells()
    }
    
    @objc func PCChanged() {
        classFeaturesTable.reloadData()
        updateBonusSpells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBonusSpells() {
        let bonusSpellLabels = [BonusSlots1, BonusSlots2, BonusSlots3, BonusSlots4, BonusSlots5, BonusSlots6]
        let slotFields = [TextField1, TextField2, TextField3, TextField4, TextField5, TextField6]
        for i in 0...5 {
            if slotFields[i]?.text != "0"{
                bonusSpellLabels[i]?.text = "+\((bonusSpells(forPC: PC, basedOn: spellcastingAbilityTextField.text ?? "")[i]))"
            } else {
                bonusSpellLabels[i]?.text = "+0"
            }
        }
    }
    
    func reloadLevel() {
        classNameTextField.text = level.name
        classLevelsTextField.text = "\(level.levels)"
        BABTextField.text = "\(level.bab)"
        fortTextField.text = "\(level.fortitude)"
        refTextField.text = "\(level.reflex)"
        willTextField.text = "\(level.will)"
        staminaTextField.text = "\(level.stamina)"
        hitPointsTextField.text = "\(level.hitPoints)"
        skillRanksTextField.text = "\(level.skillRanks)"
        spellcastingAbilityTextField.text = level.spellcastingAbility ?? "None"
            
        if slots.count >= 6 {
            TextField1.text = "\(slots[0].slots)"
            TextField2.text = "\(slots[1].slots)"
            TextField3.text = "\(slots[2].slots)"
            TextField4.text = "\(slots[3].slots)"
            TextField5.text = "\(slots[4].slots)"
            TextField6.text = "\(slots[5].slots)"
        } else {
            print("Spell slots did not conform slots.count < 6")
            TextField1.text = "0"
            TextField2.text = "0"
            TextField3.text = "0"
            TextField4.text = "0"
            TextField5.text = "0"
            TextField6.text = "0"
        }
    }
    
    @objc func cancel() {
        if level.classLevels == nil {
            context.delete(level)
        }
        dismiss(animated: true)
    }
    
    @objc func save() {
        writeToLevel()
        level.classLevels = PC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        dismiss(animated: true)
    }
    
    func writeToLevel() {
        level.name = classNameTextField.text
        level.levels = Int16(classLevelsTextField.text!) ?? level.levels
        level.bab = Int16(BABTextField.text!) ?? level.bab
        level.fortitude = Int16(fortTextField.text!) ?? level.fortitude
        level.reflex = Int16(refTextField.text!) ?? level.reflex
        level.will = Int16(willTextField.text!) ?? level.will
        level.stamina = Int16(staminaTextField.text!) ?? level.stamina
        level.hitPoints = Int16(hitPointsTextField.text!) ?? level.hitPoints
        level.skillRanks = Int16(skillRanksTextField.text!) ?? level.skillRanks
        level.spellcastingAbility = spellcastingAbilityTextField.text ?? "None"
        
        let oldSlots = level.classSlots?.array as! [SpellSlot]
        var newSlots = [SpellSlot]()
        let slotFields = [TextField1, TextField2, TextField3, TextField4, TextField5, TextField6]
        
        for i in 0...5 {
            let newSlot = SpellSlot(context: context)
            newSlot.slots = Int16((slotFields[i]?.text)!) ?? 0
            newSlot.used = 0
            /*
            if oldSlots.count > i {
                newSlot.used = oldSlots[i].used
                context.delete(oldSlots[i])
            } else {
                
            }
            */
            print("writing \(newSlot.slots) level \(i+1) slots for \(level.name ?? "unnammed level")")
            newSlots.append(newSlot)
        }
        for ss in oldSlots {
            context.delete(ss)
        }
        for ss in newSlots {
            level.addToClassSlots(ss)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        var isPicker = true
        
        switch textField {
        case classLevelsTextField:
            currentPickerArray = oneToTwenty
        case BABTextField, fortTextField, refTextField, willTextField, staminaTextField, hitPointsTextField, skillRanksTextField:
            currentPickerArray = bonusArray
        case spellcastingAbilityTextField:
            currentPickerArray = abilities
        case TextField1, TextField2, TextField3, TextField4, TextField5, TextField6:
            currentPickerArray = spellArray
        default:
            isPicker = false
        }
        
        if isPicker {
            let picker = textField.inputView as! UIPickerView
            setDefaultPick(picker: picker, array: currentPickerArray, textField: textField)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSpells" {
            let skvc = segue.destination as! EditorSpellsKnownController
            skvc.level = level
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classFeatures.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add New Class Feature"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell", for: indexPath)
            cell.textLabel?.text = classFeatures[indexPath.row - 1].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let newFeature = Feature(context: context)
            newFeature.name = "New Feature"
            newFeature.content = ""
            let efvc = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
            efvc.feature = newFeature
            efvc.forObj = level
            efvc.PC = PC
            present(efvc, animated: true)
        } else {
            let efvc = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
            efvc.feature = classFeatures[indexPath.row - 1]
            efvc.forObj = level
            efvc.PC = PC
            present(efvc, animated: true)
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
            let featureToDelete = classFeatures[indexPath.row - 1]
            classFeatures.remove(at: indexPath.row - 1)
            classFeaturesTable.deleteRows(at: [indexPath], with: .fade)
            context.delete(featureToDelete)
            
            classFeaturesTable.reloadData()
            classFeaturesTableHeight.constant = classFeaturesTable.contentSize.height
        }
        if editingStyle == .insert {
            let newFeature = Feature(context: context)
            newFeature.name = ""
            newFeature.content = ""
            let efvc = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
            efvc.feature = newFeature
            efvc.forObj = level
            efvc.PC = PC
            present(efvc, animated: true)
        }
    }
    
    /*
    @IBAction func addClassFeatureTapped(_ sender: UIButton) {
        let newFeature = Feature(context: context)
        newFeature.name = "New Feature"
        newFeature.content = ""
        level.addToClassFeature(newFeature)
        classFeatures.append(newFeature)
        
        classFeaturesTable.reloadData()
        classFeaturesTableHeight.constant = classFeaturesTable.contentSize.height
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "-" {
            classFeaturesTable.setEditing(true, animated: true)
            sender.setTitle("Done", for: .normal)
        } else {
            classFeaturesTable.setEditing(false, animated: true)
            sender.setTitle("-", for: .normal)
        }
    }
    */
    
    ////////////////////////////////
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case oneToTwentyPicker:
            return oneToTwenty.count
        case spellPicker:
            return spellArray.count
        case bonusPicker:
            return bonusArray.count
        case abilityPicker:
            return abilities.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case oneToTwentyPicker:
            return oneToTwenty[row]
        case spellPicker:
            return spellArray[row]
        case bonusPicker:
            return bonusArray[row]
        case abilityPicker:
            return abilities[row]
        default:
            return ""
        }
    }
    
    func setDefaultPick(picker: UIPickerView, array: [String], textField: UITextField) {
        for i in 0...(array.count-1) {
            if textField.text == array[i] {
                picker.selectRow(i, inComponent: 0, animated: false)
                
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTextField.text = currentPickerArray[row]
    }

}
