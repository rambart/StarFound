//
//  EditorDetailController.swift
//  StarFinder
//
//  Created by Tom on 4/7/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorDetailController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var portraitImgView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var raceButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    @IBOutlet weak var homeworldTextField: UITextField!
    @IBOutlet weak var deityTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var alignmentTextField: UITextField!
    @IBOutlet weak var speedTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var hairTextField: UITextField!
    @IBOutlet weak var eyesTextField: UITextField!
    @IBOutlet weak var strengthTextField: UITextField!
    @IBOutlet weak var dexterityTextField: UITextField!
    @IBOutlet weak var constitutionTextField: UITextField!
    @IBOutlet weak var intelligenceTextField: UITextField!
    @IBOutlet weak var wisdomTextField: UITextField!
    @IBOutlet weak var charismaTextField: UITextField!
    @IBOutlet weak var resolveTextField: UITextField!
    @IBOutlet weak var editorClassTable: UITableView!
    @IBOutlet weak var editorClassTableHeight: NSLayoutConstraint!
    
    var PC = PlayerCharacter()
    var num = [String]()
    let alignment1 = ["Lawful", "Neutral", "Chaotic"]
    let alignment2 = ["Good", "Neutral", "Evil"]
    var alignmentElement1 = "Neutral"
    var alignmentElement2 = "Neutral"
    let sizes = ["Fine", "Diminutive", "Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan", "Colossal"]
    let abilities = ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"]
    var speeds = [String]()
    var currentPickerArray = [String]()
    var currentTextField = UITextField()
    var numPicker = UIPickerView()
    var speedPicker = UIPickerView()
    var alignmentPicker = UIPickerView()
    var sizePicker = UIPickerView()
    var resolveAbilityPicker = UIPickerView()
    var classLevels = [Level]()
    var oldImgURLs = [String]()
    var newImgURLs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        num = [String]()
        for i in 1...50 {
            num.append("\(i)")
        }
        speeds = [String]()
        for i in 0...30 {
            speeds.append("\(i * 5)")
        }
        
        classLevels = PC.classLevels?.array as! [Level]
        
        let gestRec = UITapGestureRecognizer(target: self, action: #selector(addImg))
        portraitImgView.addGestureRecognizer(gestRec)
        
        numPicker.delegate = self
        numPicker.dataSource = self
        speedPicker.delegate = self
        speedPicker.dataSource = self
        alignmentPicker.delegate = self
        alignmentPicker.dataSource = self
        sizePicker.delegate = self
        sizePicker.dataSource = self
        resolveAbilityPicker.delegate = self
        resolveAbilityPicker.dataSource = self
        
        editorClassTable.delegate = self
        editorClassTable.dataSource = self
        editorClassTable.setEditing(true, animated: false)
        
        nameTextField.delegate = self
        homeworldTextField.delegate = self
        deityTextField.delegate = self
        sizeTextField.delegate = self
        alignmentTextField.delegate = self
        speedTextField.delegate = self
        genderTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        hairTextField.delegate = self
        eyesTextField.delegate = self
        strengthTextField.delegate = self
        dexterityTextField.delegate = self
        constitutionTextField.delegate = self
        intelligenceTextField.delegate = self
        wisdomTextField.delegate = self
        charismaTextField.delegate = self
        resolveTextField.delegate = self
        
        nameTextField.text = PC.name ?? ""
        raceButton.setTitle(PC.race?.name ?? "-", for: .normal)
        themeButton.setTitle(PC.theme?.name ?? "-", for: .normal)
        homeworldTextField.text = PC.homeworld ?? ""
        deityTextField.text = PC.deity ?? ""
        sizeTextField.text = PC.size ?? "Medium"
        alignmentTextField.text = PC.alignment ?? "Neutral"
        speedTextField.text = "\(PC.speed)"
        genderTextField.text = PC.gender ?? ""
        heightTextField.text = PC.height ?? ""
        weightTextField.text = PC.weight ?? ""
        hairTextField.text = PC.hair ?? ""
        eyesTextField.text = PC.eyes ?? ""
        strengthTextField.text = "\(PC.strength)"
        dexterityTextField.text = "\(PC.dexterity)"
        constitutionTextField.text = "\(PC.constitution)"
        intelligenceTextField.text = "\(PC.intelligence)"
        wisdomTextField.text = "\(PC.wisdom)"
        charismaTextField.text = "\(PC.charisma)"
        resolveTextField.text = PC.resolveAbility ?? ""
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        sizeTextField.inputAccessoryView = toolBar
        alignmentTextField.inputAccessoryView = toolBar
        speedTextField.inputAccessoryView = toolBar
        strengthTextField.inputAccessoryView = toolBar
        dexterityTextField.inputAccessoryView = toolBar
        constitutionTextField.inputAccessoryView = toolBar
        intelligenceTextField.inputAccessoryView = toolBar
        wisdomTextField.inputAccessoryView = toolBar
        charismaTextField.inputAccessoryView = toolBar
        resolveTextField.inputAccessoryView = toolBar
        
        sizeTextField.inputView = sizePicker
        speedTextField.inputView = speedPicker
        strengthTextField.inputView = numPicker
        dexterityTextField.inputView = numPicker
        constitutionTextField.inputView = numPicker
        intelligenceTextField.inputView = numPicker
        wisdomTextField.inputView = numPicker
        charismaTextField.inputView = numPicker
        resolveTextField.inputView = resolveAbilityPicker
        alignmentTextField.inputView = alignmentPicker
        
        let typableTextFields: [UITextField] = [nameTextField, homeworldTextField, deityTextField, genderTextField, heightTextField, weightTextField, hairTextField, eyesTextField]
        for tf in typableTextFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            PCChanged()
        }
        
        editorClassTable.reloadData()
        editorClassTableHeight.constant = editorClassTable.contentSize.height
    }
    
    @objc func PCChanged() {
        
        if PC.portraitPath != nil {
            let path = getDocumentsDirectory().appendingPathComponent(PC.portraitPath!)
            portraitImgView.image = UIImage(contentsOfFile: path.path)
        }
        
        raceButton.setTitle(PC.race?.name ?? "-", for: .normal)
        themeButton.setTitle(PC.theme?.name ?? "-", for: .normal)
        
        classLevels = PC.classLevels?.array as! [Level]
        
        editorClassTable.reloadData()
        editorClassTableHeight.constant = editorClassTable.contentSize.height
    }
    
    func cleanAlignment() -> String{
        if alignmentElement1 == alignmentElement2 {
            return alignmentElement1
        } else {
            return alignmentElement1 + " " + alignmentElement2
        }
    }
    
    func setDefaultPick(picker: UIPickerView, array: [String], textField: UITextField) {
        if textField == alignmentTextField {
            picker.selectRow(1, inComponent: 0, animated: false)
            picker.selectRow(1, inComponent: 1, animated: false)
            if (textField.text?.lowercased().contains("lawful"))! {
                picker.selectRow(0, inComponent: 0, animated: false)
            } else if (textField.text?.lowercased().contains("chaotic"))! {
                picker.selectRow(2, inComponent: 0, animated: false)
            }
            if (textField.text?.lowercased().contains("good"))! {
                picker.selectRow(0, inComponent: 1, animated: false)
            } else if (textField.text?.lowercased().contains("evil"))! {
                picker.selectRow(2, inComponent: 1, animated: false)
            }
        } else {
            for i in 0...(array.count-1) {
                if textField.text == array[i] {
                    picker.selectRow(i, inComponent: 0, animated: false)
                }
            }
        }
    }
    
// MARK: - donePicker
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    
    
    
    
    
    @IBAction func raceButtonTapped(_ sender: Any) {
        if PC.race?.name == "" {
            let newRaceVC = storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newRaceVC.PC = PC
            newRaceVC.mode = "race"
            present(newRaceVC, animated: true)
        } else {
            let raceEditVC = storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
            raceEditVC.PC = PC
            raceEditVC.mode = "race"
            present(raceEditVC, animated: true)
        }
    }
    
    @IBAction func themeButtonTapped(_ sender: Any) {
        if PC.theme?.name == "" {
            let newThemeVC = storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newThemeVC.PC = PC
            newThemeVC.mode = "theme"
            present(newThemeVC, animated: true)
        } else {
            let themeEditVC = storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
            themeEditVC.PC = PC
            themeEditVC.mode = "theme"
            present(themeEditVC, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveToEditedPC()
    }
    
    
// MARK: - Save Func
    func saveToEditedPC() {
        PC.name = nameTextField.text
        PC.homeworld = homeworldTextField.text
        PC.deity = deityTextField.text
        PC.size = sizeTextField.text
        PC.alignment = alignmentTextField.text
        PC.speed = Int16(speedTextField.text!)!
        PC.gender = genderTextField.text
        PC.height = heightTextField.text
        PC.weight = weightTextField.text
        PC.hair = hairTextField.text
        PC.eyes = eyesTextField.text
        PC.strength = Int16(strengthTextField.text!)!
        PC.dexterity = Int16(dexterityTextField.text!)!
        PC.constitution = Int16(constitutionTextField.text!)!
        PC.intelligence = Int16(intelligenceTextField.text!)!
        PC.wisdom = Int16(wisdomTextField.text!)!
        PC.charisma = Int16(charismaTextField.text!)!
        PC.resolveAbility = resolveTextField.text
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
// MARK: - Text Field Functions
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        var isAPicker = true
        switch textField {
        case sizeTextField:
            currentPickerArray = sizes
        case speedTextField:
            currentPickerArray = speeds
        case strengthTextField:
            currentPickerArray = num
        case dexterityTextField:
            currentPickerArray = num
        case constitutionTextField:
            currentPickerArray = num
        case intelligenceTextField:
            currentPickerArray = num
        case wisdomTextField:
            currentPickerArray = num
        case charismaTextField:
            currentPickerArray = num
        case resolveTextField:
            currentPickerArray = abilities
        case alignmentTextField:
            break
        default:
            isAPicker = false
        }
        if isAPicker{
            let picker = textField.inputView as! UIPickerView
            setDefaultPick(picker: picker, array: currentPickerArray, textField: textField)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveToEditedPC()
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        saveToEditedPC()
    }
    
// MARK: - Picker Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if currentTextField == alignmentTextField {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == alignmentPicker {
            return 3
        } else {
            return currentPickerArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == alignmentPicker {
            if component == 0 {
                return alignment1[row]
            } else {
                return alignment2[row]
            }
        } else {
            return currentPickerArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == alignmentPicker {
            if component == 0 {
                alignmentElement1 = alignment1[row]
            } else {
                alignmentElement2 = alignment2[row]
            }
            currentTextField.text = cleanAlignment()
        } else {
            currentTextField.text = currentPickerArray[row]
        }
        saveToEditedPC()
    }

// MARK: - TableView Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classLevels.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell.sizeToFit()
            cell.textLabel?.text = "Add New Class Level"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditorClassCell", for: indexPath)
            cell.textLabel?.text = classLevels[indexPath.row - 1].name ?? "Class Name"
            cell.detailTextLabel?.text = "Level \(classLevels[indexPath.row - 1].levels)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let newVC = storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newVC.PC = PC
            newVC.mode = "class"
            present(newVC, animated: true)
        } else {
            let ecvc = storyboard?.instantiateViewController(withIdentifier: "EditorClassNav") as! EditorClassNavController
            ecvc.level = classLevels[indexPath.row - 1]
            ecvc.PC = PC
            present(ecvc, animated: true)
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
            
            let clss = classLevels[indexPath.row - 1]
            context.delete(clss)
            
            classLevels.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            editorClassTable.reloadData()
            editorClassTableHeight.constant = editorClassTable.contentSize.height
        }
        if editingStyle == .insert {
            let newVC = storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newVC.PC = PC
            newVC.mode = "class"
            present(newVC, animated: true)
        }
    }
    
    @IBAction func levelUpTapped(_ sender: Any) {
        if classLevels.count == 0 {
            let newVC = storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newVC.PC = PC
            newVC.mode = "class"
            present(newVC, animated: true)
        } else {
            let luvc = storyboard?.instantiateViewController(withIdentifier: "LevelUpController") as! LevelUpController
            luvc.PC = PC
            present(luvc, animated: true)
        }
    }
    
    
    
    // MARK: - Image Picker
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 100) {
            try? jpegData.write(to: imagePath)
        }
        
        if PC.portraitPath != nil {
            (self.parent as! MasterEditorController).oldImgUrls.append(PC.portraitPath!)
            //oldImgURLs.append(PC.portraitPath!)
        }
        (self.parent as! MasterEditorController).newImgUrls.append(imageName)
        
        PC.portraitPath = imageName
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        dismiss(animated: true)
    }
    
    @objc func addImg() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
