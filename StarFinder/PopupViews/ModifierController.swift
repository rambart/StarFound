//
//  ModifierController.swift
//  StarFinder
//
//  Created by Tom on 4/19/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class ModifierController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
   
    
    var previousMod = Bonus()
    var forObject: Any = 0
    var PC = PlayerCharacter()
    let typesOfModifiers = ["Abilities", "Skills", "Bonuses"]
    let abilities = ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"]
    var skills = [String]()
    var bonuses = ["Attack", "Damage", "EAC", "KAC", "Speed", "Fortitude", "Reflex", "Will", "Hit Points", "Stamina", "Resolve", "Initiative"]
    let values = Array(-50...50)
    var topSelection = "Abilities"
    var bottomSelection = "Strength"
    var bottomValue = 0
    var newBonus = Bonus()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var modTitle: UILabel!
    @IBOutlet weak var modSpacer: UIView!
    
    @IBOutlet weak var topPicker: UIPickerView!
    @IBOutlet weak var pickersSpacer: UIView!
    @IBOutlet weak var bottomPicker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()

        topPicker.delegate = self
        topPicker.dataSource = self
        bottomPicker.delegate = self
        bottomPicker.dataSource = self
        
        var skillNames = [String]()
        for skill in (PC.skills?.allObjects as! [Skill]) {
            skillNames.append(skill.name!)
        }
        skills = skillNames.sorted { $0 < $1 }
        bottomPicker.selectRow(50, inComponent: 1, animated: false)
        
        if previousMod.managedObjectContext != nil {
            setPickersFor(previousMod)
        }
    }
    
    func updatePalette() {
        windowView.backgroundColor = palette.bg
        modTitle.textColor = palette.main
        modSpacer.backgroundColor = palette.main
        pickersSpacer.backgroundColor = palette.main
        selectButton.backgroundColor = palette.main
        selectButton.setTitleColor(palette.alt, for: .normal)
        
    }

    func setPickersFor(_ mod: Bonus) {
        let allArrays = [abilities, skills, bonuses]
        for i in 0...2 {
            for ii in 0...allArrays[i].count - 1 {
                if mod.type == allArrays[i][ii] {
                    topPicker.selectRow(i, inComponent: 0, animated: false)
                    topSelection = typesOfModifiers[i]
                    bottomPicker.reloadAllComponents()
                    bottomPicker.selectRow(ii, inComponent: 0, animated: false)
                    bottomSelection = allArrays[i][ii]
                    bottomValue = Int(mod.bonus)
                }
            }
        }
        bottomPicker.selectRow(Int(mod.bonus + 50), inComponent: 1, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == topPicker {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == topPicker {
            return typesOfModifiers.count
        } else {
            if component == 0 {
                switch topSelection{
                case "Abilities":
                    return abilities.count
                case "Skills":
                    return skills.count
                case "Bonuses":
                    return bonuses.count
                default:
                    return 0
                }
            } else {
                return values.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == topPicker {
            return format(typesOfModifiers[row])
        } else {
            if component == 0 {
                switch topSelection {
                case "Abilities":
                    return format(abilities[row])
                case "Skills":
                    return format(skills[row])
                case "Bonuses":
                    return format(bonuses[row])
                default:
                    return format("")
                }
            } else {
                return format("\(cleanPossNeg(of: values[row]))")
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == topPicker {
            topSelection = typesOfModifiers[row]
            self.bottomPicker.reloadAllComponents()
            self.bottomPicker.selectRow(50, inComponent: 1, animated: false)
            switch row{
            case 0:
                bottomSelection = abilities[0]
            case 1:
                bottomSelection = skills[0]
            case 2:
                bottomSelection = bonuses[0]
            default:
                break
            }
        } else {
            if component == 0 {
                switch topSelection {
                case "Abilities":
                    bottomSelection = abilities[row]
                case "Skills":
                    bottomSelection = skills[row]
                case "Bonuses":
                    bottomSelection = bonuses[row]
                default:
                    break
                }
            } else {
                bottomValue = values[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if pickerView == bottomPicker {
            if component == 1 {
                return 60
            } else {
                return 200
            }
        } else {
            return 100
        }
    }
    
    
    func format(_ string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: palette.text])
    }
    
    
    @IBAction func selectTapped(_ sender: Any) {
        if previousMod.managedObjectContext != nil {
            previousMod.type = bottomSelection
            previousMod.bonus = Int16(bottomValue)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            self.dismiss(animated: true)
        } else {
            let newBonus = Bonus(context: context)
            newBonus.type = bottomSelection
            newBonus.bonus = Int16(bottomValue)
            newBonus.enabled = true
            
            if let Objc = forObject as? PlayerCharacter {
                Objc.addToConditionalBonus(newBonus)
            }
            if let Objc = forObject as? Race {
                Objc.addToRacialBonus(newBonus)
            }
            if let Objc = forObject as? Theme {
                Objc.addToThemeBonus(newBonus)
            }
            if let Objc = forObject as? Feature {
                Objc.addToFeatureBonus(newBonus)
            }
            if let Objc = forObject as? Item {
                Objc.addToItemBonus(newBonus)
            }
            if let Objc = forObject as? Weapon {
                Objc.addToWeaponBonus(newBonus)
            }
            if let Objc = forObject as? Armor {
                Objc.addToArmorBonus(newBonus)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
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
