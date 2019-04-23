//
//  EditorSkillsController.swift
//  StarFinder
//
//  Created by Tom on 4/30/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorSkillsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var skillsTableView: UITableView!
    @IBOutlet weak var skillPointsLabel: UILabel!
    @IBOutlet weak var bottomSpacer: NSLayoutConstraint!
    
    var PC = PlayerCharacter()
    var skills = [Skill]()
    var hasLoaded = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            bottomSpacer.constant = 0
        } else {
            bottomSpacer.constant = 55
        }
        
        skillsTableView.delegate = self
        skillsTableView.dataSource = self
        
        hasLoaded = true
        
        PCChanged()

        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }

    @objc func PCChanged() {
        skillPointsLabel.text = "\(calculateSkillPoints(forPC: PC))"
        skills = PC.skills?.allObjects as! [Skill]
        skills = skills.sorted { $0.name! < $1.name! }
        skillsTableView.reloadData()
    }
    
    func removeRow(row: Int) {
        if skills.count >= row {
            skills.remove(at: row)
            let ip = IndexPath(row: row, section: 0)
            skillsTableView.deleteRows(at: [ip], with: .automatic)
        }
    }
    
    func calculateSkillPoints(forPC: PlayerCharacter) -> Int {
        var spentPoints = 0
        var totalAvailable = 0
        for skill in forPC.skills?.allObjects as! [Skill] {
            spentPoints += Int(skill.ranks)
        }
        for level in forPC.classLevels?.array as! [Level] {
            let pointsForLevel = Int(level.levels) * (Int(level.skillRanks) + mod(of: "Intelligence", forPC: forPC))
            totalAvailable += pointsForLevel
        }
        return (totalAvailable - spentPoints)
    }
    
    @IBAction func addNewSkillTapped(_ sender: Any) {
        let newSkill = Skill(context: context)
        newSkill.name = "-New Skill-"
        newSkill.ability = "Str"
        newSkill.ranks = 0
        newSkill.classSkill = false
        PC.addToSkills(newSkill)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    
    //Mark: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "skillEditorCell", for: indexPath) as! EditorSkillCell
        cell.skill = skills[indexPath.row]
        cell.nameLabel.text = skills[indexPath.row].name
        if skills[indexPath.row].classSkill {
            cell.classSkillLabel.text = "✦"
        } else {
            cell.classSkillLabel.text = "✧"
        }
        cell.ranksLabel.text = "\(skills[indexPath.row].ranks)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let svc = storyboard?.instantiateViewController(withIdentifier: "SkillEditorController") as! SkillEditorController
        svc.skill = skills[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        present(svc, animated: true)
    }

}

class EditorSkillCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classSkillLabel: UILabel!
    @IBOutlet weak var ranksLabel: UILabel!
    
    var skill = Skill()
    
    
    @IBAction func minusTapped(_ sender: Any) {
        skill.ranks -= 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)

    }
    
    @IBAction func plusTapped(_ sender: Any) {
        skill.ranks += 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)

    }
    
    
    
}





class SkillEditorController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ranksTextField: UITextField!
    @IBOutlet weak var abilityTextField: UITextField!
    @IBOutlet weak var classSkillButton: UIButton!
    @IBOutlet weak var armorCheckButton: UIButton!
    
    var skill = Skill()
    var ranksPicker = UIPickerView()
    var ranks = [String]()
    var abilitiesPicker = UIPickerView()
    let abilities = ["Str", "Dex", "Int", "Wis", "Cha"]
    var currentTextField = UITextField()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0...20 {
            ranks.append("\(i)")
        }
        
        nameTextField.delegate = self
        ranksTextField.delegate = self
        abilityTextField.delegate = self
        
        ranksPicker.delegate = self
        ranksPicker.dataSource = self
        abilitiesPicker.delegate = self
        abilitiesPicker.dataSource = self

        
        nameTextField.text = skill.name
        ranksTextField.text = "\(skill.ranks)"
        abilityTextField.text = skill.ability
        if skill.classSkill {
            classSkillButton.setTitle("● Class Skill", for: .normal)
        } else {
            classSkillButton.setTitle("○ Class Skill", for: .normal)
        }
        if skill.armorCheck {
            armorCheckButton.setTitle("● Armor Check", for: .normal)
        } else {
            armorCheckButton.setTitle("○ Armor Check", for: .normal)
        }

        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        ranksTextField.inputAccessoryView = toolBar
        abilityTextField.inputAccessoryView = toolBar
        
        ranksTextField.inputView = ranksPicker
        abilityTextField.inputView = abilitiesPicker
    }
    
    @IBAction func optionTapped(_ sender: UIButton) {
        if (sender.currentTitle?.contains("○"))! {
            if (sender.currentTitle?.contains("Class Skill"))! {
                skill.classSkill = true
                sender.setTitle(sender.currentTitle?.replacingOccurrences(of: "○", with: "●"), for: .normal)
            } else if (sender.currentTitle?.contains("Armor Check"))! {
                skill.armorCheck = true
                sender.setTitle(sender.currentTitle?.replacingOccurrences(of: "○", with: "●"), for: .normal)
            }
        } else {
            if (sender.currentTitle?.contains("Class Skill"))! {
                skill.classSkill = false
                sender.setTitle(sender.currentTitle?.replacingOccurrences(of: "●", with: "○"), for: .normal)
            } else if (sender.currentTitle?.contains("Armor Check"))! {
                skill.armorCheck = false
                sender.setTitle(sender.currentTitle?.replacingOccurrences(of: "●", with: "○"), for: .normal)
            }
        }
    }
    
    
    @IBAction func deleteSkillTapped(_ sender: Any) {
        context.delete(skill)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        skill.name = nameTextField.text
        skill.ranks = Int16(ranksTextField.text!)!
        skill.ability = abilityTextField.text
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Picker View
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        var isAPicker = true
        var currentPickerArray = [String]()
        switch textField {
        case ranksTextField:
            currentPickerArray = ranks
        case abilityTextField:
            currentPickerArray = abilities
        default:
            isAPicker = false
        }
        if isAPicker {
            let picker = textField.inputView as! UIPickerView
            setDefaultPick(picker: picker, array: currentPickerArray, textField: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case ranksPicker:
            return ranks.count
        case abilitiesPicker:
            return abilities.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case ranksPicker:
            return "\(ranks[row])"
        case abilitiesPicker:
            return abilities[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case ranksPicker:
            currentTextField.text = "\(ranks[row])"
        case abilitiesPicker:
            currentTextField.text = abilities[row]
        default:
            break
        }
    }
    
    func setDefaultPick(picker: UIPickerView, array: [String], textField: UITextField) {
        for i in 0...(array.count-1) {
            if textField.text == array[i] {
                picker.selectRow(i, inComponent: 0, animated: false)
            }
        }
    }
    
}
