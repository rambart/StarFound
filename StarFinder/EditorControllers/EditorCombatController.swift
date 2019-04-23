//
//  EditorCombatController.swift
//  StarFinder
//
//  Created by Tom on 2/8/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorCombatController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    
    // MARK: - Outlets
    @IBOutlet weak var trackersTable: UITableView!
    @IBOutlet weak var trackersHeight: NSLayoutConstraint!
    @IBOutlet weak var attacksTable: UITableView!
    @IBOutlet weak var attacksHeight: NSLayoutConstraint!
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackersTable.delegate = self
        trackersTable.dataSource = self
        attacksTable.delegate = self
        attacksTable.dataSource = self
        
        trackersTable.isEditing = true
        attacksTable.isEditing = true
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        trackersTable.reloadData()
        trackersHeight.constant = trackersTable.contentSize.height
        
        attacksTable.reloadData()
        attacksHeight.constant = attacksTable.contentSize.height
    }
    
    // MARK: - Buttons
    
    
    // MARK: - Table Views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case trackersTable:
            return (PC.trackers?.array.count ?? 0) + 1
        case attacksTable:
            return (PC.attack?.array.count ?? 0) + 1
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            switch tableView {
            case trackersTable:
                cell.textLabel?.text = "Add new tracker"
            case attacksTable:
                cell.textLabel?.text = "Add new attack"
            default:
                break
            }
        } else {
            switch tableView {
            case trackersTable:
                cell.textLabel?.text = (PC.trackers?.array[indexPath.row - 1] as! Tracker).name
            case attacksTable:
                cell.textLabel?.text = (PC.attack?.array[indexPath.row - 1] as! Attack).name
            default:
                break
            }
        }
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .insert
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableView {
        case trackersTable:
            if editingStyle == .delete {
                let trackerToDelete = PC.trackers?.array[indexPath.row - 1]
                context.delete(trackerToDelete as! Tracker)
                
                //tableView.deleteRows(at: [indexPath], with: .fade)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                
            }
            if editingStyle == .insert {
                let newTracker = Tracker(context: context)
                editTracker(newTracker)
            }
        case attacksTable:
            if editingStyle == .delete {
                let attackToDelete = PC.attack?.array[indexPath.row - 1]
                context.delete(attackToDelete as! Attack)
                
                //tableView.deleteRows(at: [indexPath], with: .fade)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                
            }
            if editingStyle == .insert {
                let newAttack = Attack(context: context)
                editAttack(newAttack)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView {
        case trackersTable:
            if indexPath.row == 0 {
                editTracker(Tracker(context: context))
            } else {
                let tracker = PC.trackers?.array[indexPath.row - 1]
                editTracker(tracker as! Tracker)
            }
        case attacksTable:
            if indexPath.row == 0 {
                editAttack(Attack(context: context))
            } else {
                let attack = PC.attack?.array[indexPath.row - 1]
                editAttack(attack as! Attack)
            }
        default:
            break
        }
    }
    
    func editTracker(_ tracker: Tracker) {
        let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorTrackerNav") as! EditorTrackerNav
        nvc.PC = PC
        nvc.tracker = tracker
        present(nvc, animated: true)
    }
    
    func editAttack(_ attack: Attack) {
        let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorAttackNav") as! EditorAttackNav
        nvc.PC = PC
        nvc.attack = attack
        present(nvc, animated: true)
    }

}




class EditorTrackerNav: UINavigationController {
    
    var PC = PlayerCharacter()
    var tracker = Tracker()
    
}


class EditorTrackerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var tracker = Tracker()
    var valuePicker = UIPickerView()
    var resetPicker = UIPickerView()
    var currentTextField = UITextField()
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var resetTextField: UITextField!
    
    // MARK: - VDL
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        PC = (self.navigationController as! EditorTrackerNav).PC
        tracker = (self.navigationController as! EditorTrackerNav).tracker
        
        
        
        nameTextField.delegate = self
        valueTextField.delegate = self
        resetTextField.delegate = self
        
        valuePicker.delegate = self
        resetPicker.delegate = self
        
        valueTextField.inputView = valuePicker
        resetTextField.inputView = resetPicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        valueTextField.inputAccessoryView = toolBar
        resetTextField.inputAccessoryView = toolBar
        
        loadTracker()
    }
    
    func loadTracker() {
        nameTextField.text = tracker.name ?? ""
        valueTextField.text = "\(tracker.value)"
        resetTextField.text = "\(tracker.reset)"
        if !tracker.doesReset {
            resetTextField.text = "Doesn't Reset"
        }
    }
    
    
    // MARK: - Buttons
    @objc func save() {
        tracker.forPC = PC
        tracker.name = nameTextField.text ?? ""
        tracker.value = Int64(valueTextField.text ?? "") ?? 0
        if resetTextField.text == "Doesn't Reset" {
            tracker.doesReset = false
        } else {
            tracker.reset = Int64(resetTextField.text ?? "") ?? 0
            tracker.doesReset = true
        }
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func cancel() {
        if tracker.forPC != PC {
            context.delete(tracker)
        }
        self.dismiss(animated: true)
    }
    
    // MARK: - Textfield
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField {
        case valueTextField:
            var row = 100 + Int(valueTextField.text ?? "0")!
            if row > 200 {
                row = 200
            }
            if row < 0 {
                row = 0
            }
            valuePicker.selectRow(row, inComponent: 0, animated: false)
        case resetTextField:
            if resetTextField.text == "Doesn't Reset" {
                resetPicker.selectRow(101, inComponent: 0, animated: true)
            } else if Int(resetTextField.text ?? "0")! >= 0 {
                let row = 101 + Int(resetTextField.text ?? "0")!
                resetPicker.selectRow(row, inComponent: 0, animated: false)
            } else {
                let row = 101 + Int(resetTextField.text ?? "0")!
                resetPicker.selectRow(row, inComponent: 0, animated: false)
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == resetPicker {
            return 202
        }
        return 201
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == resetPicker {
            if row == 101 {
                return "Doesn't Reset"
            } else if row > 101 {
                return "\(row - 101)"
            }
        }
        return "\(row - 100)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var rowTitle = "\(row - 100)"
        if pickerView == resetPicker {
            if row == 101 {
                rowTitle = "Doesn't Reset"
            } else if row > 101 {
                rowTitle = "\(row - 101)"
            }
        }
        currentTextField.text = rowTitle
    }
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    
    
}



class EditorAttackNav: UINavigationController {
    
    var PC = PlayerCharacter()
    var attack = Attack()
    
}


class EditorAttackController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var attack = Attack()
    var damageType = ""
    var currentTextField = UITextField()
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var attackRollTextField: UIButton!
    @IBOutlet weak var criticalTextField: UITextField!
    @IBOutlet weak var damageTextField: UIButton!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var pBtn: UIButton!
    @IBOutlet weak var sBtn: UIButton!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var cBtn: UIButton!
    @IBOutlet weak var eBtn: UIButton!
    @IBOutlet weak var fBtn: UIButton!
    @IBOutlet weak var oBtn: UIButton!
    @IBOutlet weak var usageTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PC = (self.navigationController as! EditorAttackNav).PC
        attack = (self.navigationController as! EditorAttackNav).attack
        
        nameTextField.delegate = self
        criticalTextField.delegate = self
        usageTextField.delegate = self
        capacityTextField.delegate = self
        
        PCChanged()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        NotificationCenter.default.addObserver(self, selector: #selector(RollReturned), name:NSNotification.Name(rawValue: "RollReturned"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        nameTextField.text = attack.name ?? ""
        attackRollTextField.setTitle(attack.roll ?? "", for: .normal)
        criticalTextField.text = attack.critical ?? ""
        damageTextField.setTitle(attack.damage ?? "", for: .normal)
        usageTextField.text = "\(attack.usage)"
        capacityTextField.text = "\(attack.capacity)"
        damageType = attack.damageType ?? ""
        setButtonSelections()
    }
    
    @objc func RollReturned() {
        attackRollTextField.setTitle(attack.roll ?? "", for: .normal)
        damageTextField.setTitle(attack.damage ?? "", for: .normal)
    }
    
    
    // MARK: - Buttons
    @objc func cancel() {
        if attack.forPC != PC {
            context.delete(attack)
        }
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        attack.forPC = PC
        attack.name = nameTextField.text
        attack.roll = attackRollTextField.title(for: .normal)
        attack.critical = criticalTextField.text
        attack.damage = damageTextField.title(for: .normal)
        attack.damageType = damageType
        attack.usage = Int16(usageTextField.text ?? "") ?? 0
        attack.capacity = Int16(capacityTextField.text ?? "") ?? 0
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    
    func setButtonSelections() {
        bBtn.isSelected = damageType.uppercased().contains("B")
        pBtn.isSelected = damageType.uppercased().contains("P")
        sBtn.isSelected = damageType.uppercased().contains("S")
        aBtn.isSelected = damageType.uppercased().contains("A")
        cBtn.isSelected = damageType.uppercased().contains("C")
        eBtn.isSelected = damageType.uppercased().contains("E")
        fBtn.isSelected = damageType.uppercased().contains("F")
        oBtn.isSelected = damageType.uppercased().contains("O")
    }
    
    func reverseInstancesOf(_ letter: String) {
        if damageType.uppercased().contains(letter) {
            damageType = damageType.uppercased().replacingOccurrences(of: letter, with: "")
        } else {
            damageType.append(letter.uppercased())
        }
    }
    
    @IBAction func damageTypePressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            reverseInstancesOf("B")
        case 1:
            reverseInstancesOf("P")
        case 2:
            reverseInstancesOf("S")
        case 3:
            reverseInstancesOf("A")
        case 4:
            reverseInstancesOf("C")
        case 5:
            reverseInstancesOf("E")
        case 6:
            reverseInstancesOf("F")
        case 7:
            reverseInstancesOf("O")
        default:
            break
        }
        setButtonSelections()
    }
    
    
    // MARK: - Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func showCalc(_ sender: UIButton) {
        if sender == attackRollTextField {
            currentTextField.resignFirstResponder()
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = true
            rcvc.inputExpression = attack.roll ?? ""
            rcvc.attack = attack
            present(rcvc, animated: true)
        }
        
        if sender == damageTextField {
            currentTextField.resignFirstResponder()
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = false
            rcvc.inputExpression = attack.damage ?? ""
            rcvc.attack = attack
            present(rcvc, animated: true)
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case attackRollTextField:
            currentTextField.resignFirstResponder()
            currentTextField = textField
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = true
            rcvc.inputExpression = attack.roll ?? ""
            rcvc.attack = attack
            present(rcvc, animated: true)
        case damageTextField:
            currentTextField.resignFirstResponder()
            currentTextField = textField
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = false
            rcvc.inputExpression = attack.damage ?? ""
            rcvc.attack = attack
            present(rcvc, animated: true)
        default:
            currentTextField = textField
        }
    }
    
    
    
    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    
    
}
