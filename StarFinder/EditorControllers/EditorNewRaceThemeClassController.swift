//
//  EditorNewRaceThemeClassController.swift
//  StarFinder
//
//  Created by Tom on 4/17/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorNewRaceThemeClassController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var PC = PlayerCharacter()
    var mode = ""
    var compendiumRaces = [CompendiumRace]()
    var compendiumThemes = [CompendiumTheme]()
    var compendiumClasses = [CompendiumClass]()
    var selectedRace = CompendiumRace()
    var selectedTheme = CompendiumTheme()
    var selectedClass = CompendiumClass()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        
        fetchCompendium(mode)
        
        switch mode {
        case "race":
            titleLabel.text = "Select Your Race"
            selectedRace = compendiumRaces[0]
        case "theme":
            titleLabel.text = "Select Your Theme"
            selectedTheme = compendiumThemes[0]
        case "class":
            titleLabel.text = "Add New Level"
            selectedClass = compendiumClasses[0]
        default:
            break
        }
        
    }
    


    func fetchCompendium(_ type: String) {
        compendiumRaces = [CompendiumRace]()
        compendiumThemes = [CompendiumTheme]()
        compendiumClasses = [CompendiumClass]()
        do {
            switch type {
            case "race":
                try compendiumRaces = context.fetch(CompendiumRace.fetchRequest()).sorted { $0.name! < $1.name! }
            case "theme":
                try compendiumThemes = context.fetch(CompendiumTheme.fetchRequest()).sorted { $0.name! < $1.name! }
            case "class":
                try compendiumClasses = context.fetch(CompendiumClass.fetchRequest()).sorted { $0.name! < $1.name! }
            default:
                break
            }
        } catch {
            print("⭐️⭐️Did not fetch compendium \(mode)!⭐️⭐️")
        }
    }
    
    
    
    
    
    
    // Mark: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch mode {
        case "race":
            return compendiumRaces.count
        case "theme":
            return compendiumThemes.count
        case "class":
            return compendiumClasses.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch mode {
        case "race":
            return compendiumRaces[row].name ?? "Untitled Race"
        case "theme":
            return compendiumThemes[row].name ?? "Untitled Theme"
        case "class":
            return compendiumClasses[row].name ?? "Untitled Class"
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch mode {
        case "race":
            selectedRace = compendiumRaces[row]
        case "theme":
            selectedTheme = compendiumThemes[row]
        case "class":
            selectedClass = compendiumClasses[row]
        default:
            break
        }
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        switch mode {
        case "race":
            let newRace = Race(context: context)
            newRace.name = selectedRace.name
            for bon in selectedRace.racialBonus?.array as! [Bonus]{
                let newBonus = Bonus(context: context)
                newBonus.type = bon.type
                newBonus.bonus = bon.bonus
                newBonus.enabled = true
                newRace.addToRacialBonus(newBonus)
            }
            for feat in selectedRace.racialFeature?.array as! [Feature]{
                let newFeat = Feature(context: context)
                newFeat.name = feat.name
                newFeat.content = feat.content
                for bon in feat.featureBonus?.array as! [Bonus] {
                    let newBonus = Bonus(context: context)
                    newBonus.type = bon.type
                    newBonus.bonus = bon.bonus
                    newBonus.enabled = true
                    newFeat.addToFeatureBonus(newBonus)
                }
                newRace.addToRacialFeature(newFeat)
            }
            if PC.race != nil {
                context.delete(PC.race!)
            }
            PC.race = newRace
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
                vc.PC = self.PC
                vc.mode = "race"
                pvc?.present(vc, animated: true)
            })
            
            
            

            
        case "theme":
            let newTheme = Theme(context: context)
            newTheme.name = selectedTheme.name
            for bon in selectedTheme.themeBonus?.array as! [Bonus]{
                let newBonus = Bonus(context: context)
                newBonus.type = bon.type
                newBonus.bonus = bon.bonus
                newBonus.enabled = true
                newTheme.addToThemeBonus(newBonus)
            }
            for feat in selectedTheme.themeFeatures?.array as! [Feature]{
                let newFeat = Feature(context: context)
                newFeat.name = feat.name
                newFeat.content = feat.content
                for bon in feat.featureBonus?.array as! [Bonus] {
                    let newBonus = Bonus(context: context)
                    newBonus.type = bon.type
                    newBonus.bonus = bon.bonus
                    newBonus.enabled = true
                    newFeat.addToFeatureBonus(newBonus)
                }
                newTheme.addToThemeFeature(newFeat)
            }
            if PC.theme != nil {
                context.delete(PC.theme!)
            }
            PC.theme = newTheme
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
                vc.PC = self.PC
                vc.mode = "theme"
                pvc?.present(vc, animated: true)
            })
            
        case "class":
            let newLevel = Level(context: context)
            newLevel.compendiumClass = selectedClass.name
            newLevel.name = selectedClass.name
            newLevel.stamina = selectedClass.staminaPoints
            newLevel.hitPoints = selectedClass.hitPoints
            newLevel.skillRanks = selectedClass.skillRanks
            newLevel.spellcastingAbility = selectedClass.spellcastingAbility ?? "None"
            let classSkills = selectedClass.classSkills?.components(separatedBy: ", ")
            for classSkill in classSkills! {
                for skill in PC.skills?.allObjects as! [Skill] {
                    if skill.name?.lowercased() == classSkill.lowercased() {
                        skill.classSkill = true
                    }
                }
            }
            levelUp(newLevel, forPC: PC)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let ecvc = self.storyboard?.instantiateViewController(withIdentifier: "EditorClassNav") as! EditorClassNavController
                ecvc.PC = self.PC
                ecvc.level = newLevel
                pvc?.present(ecvc, animated: true)
            })
            
        default:
            break
        }
    }
    

    
    @IBAction func newTapped(_ sender: Any) {
        switch mode {
        case "race":
            let newRace = Race(context: context)
            newRace.name = ""
            PC.race = newRace
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
                vc.PC = self.PC
                vc.mode = "race"
                pvc?.present(vc, animated: true)
            })
        case "theme":
            let newTheme = Theme(context: context)
            newTheme.name = "New Theme"
            let feat1 = Feature(context: context)
            feat1.name = "(1st Level)"
            let feat2 = Feature(context: context)
            feat2.name = "(6th Level)"
            let feat3 = Feature(context: context)
            feat3.name = "(12th Level)"
            let feat4 = Feature(context: context)
            feat4.name = "(18th Level)"
            PC.theme = newTheme
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditorRaceThemeNavController") as! EditorRaceThemeNavController
                vc.PC = self.PC
                vc.mode = "theme"
                pvc?.present(vc, animated: true)
            })
        case "class":
            let newClass = Level(context: context)
            newClass.name = "New Class"
            newClass.levels = 1
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let ecvc = self.storyboard?.instantiateViewController(withIdentifier: "EditorClassNav") as! EditorClassNavController
                ecvc.PC = self.PC
                ecvc.level = newClass
                pvc?.present(ecvc, animated: true)
            })
        default:
            break
        }
    }
    
    
    
    
    
    
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
