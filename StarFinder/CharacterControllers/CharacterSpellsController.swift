//
//  CharacterSpellsController.swift
//  StarFinder
//
//  Created by Tom on 5/4/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterSpellsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate {
    
    
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var level = Level()
    var defaultLevel = Level(context: context)
    var spellsKnown = [[Spell]]()
    let levelPicker = UIPickerView()
    var pcHasLevel = false
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var casterClassTitle: UILabel!
    @IBOutlet weak var casterClassSpacer: UIView!
    @IBOutlet weak var casterTextField: UITextField!
    
    @IBOutlet weak var casterLevelTitle: UILabel!
    @IBOutlet weak var casterLevelButton: UIButton!
    
    @IBOutlet weak var spellDCTitle: UILabel!
    @IBOutlet weak var spellDCLabel: UILabel!
    
    @IBOutlet weak var spellsPerDayTitle: UILabel!
    @IBOutlet weak var spellsPerDaySpacer: UIView!
    
    @IBOutlet weak var level1Title: UILabel!
    @IBOutlet weak var level1Button: UIButton!
    @IBOutlet weak var level2Title: UILabel!
    @IBOutlet weak var level2Button: UIButton!
    @IBOutlet weak var level3Title: UILabel!
    @IBOutlet weak var level3Button: UIButton!
    @IBOutlet weak var level4Title: UILabel!
    @IBOutlet weak var level4Button: UIButton!
    @IBOutlet weak var level5Title: UILabel!
    @IBOutlet weak var level5Button: UIButton!
    @IBOutlet weak var level6Title: UILabel!
    @IBOutlet weak var level6Button: UIButton!
    
    @IBOutlet weak var spellsKnownTitle: UILabel!
    @IBOutlet weak var spellsKnownSpacer: UIView!
    @IBOutlet weak var level0: UITableView!
    @IBOutlet weak var level0Height: NSLayoutConstraint!

    
    // Mark: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        level0.dataSource = self
        level0.delegate = self
        levelPicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.backgroundColor = UIColor.darkGray
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        casterTextField.inputAccessoryView = toolBar
        casterTextField.inputView = levelPicker
        
        if let lvl = PC.classLevels?.firstObject as? Level {
            pcHasLevel = true
            level = lvl
            casterTextField.text = lvl.name
            spellsKnown = getSpellsFor(level)
        } else {
            for _ in 0...6 {
                casterTextField.text = "-"
                spellsKnown.append([Spell]())
            }
        }
        
        PCChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        updatePalette()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        setSpellsPerDay()
        
        if !pcHasLevel {
            if let lvl = PC.classLevels?.firstObject as? Level {
                pcHasLevel = true
                level = lvl
                casterTextField.text = lvl.name
                spellsKnown = getSpellsFor(level)
            }
        }
        
        if pcHasLevel{
            casterLevelButton.setTitle("\(level.levels)", for: .normal)
            let baseDC = mod(of: level.spellcastingAbility ?? "", forPC: PC) + 10
            spellDCLabel.text = "\(baseDC) + Spell Level"
            
            spellsKnown = getSpellsFor(level)
        }
        
        level0.reloadData()
        level0Height.constant = level0.contentSize.height
    }
    
    func setSpellsPerDay() {
        let buttons = [level1Button, level2Button, level3Button, level4Button, level5Button, level6Button]
        for i in 0...5 {
            if pcHasLevel && level.classSlots?.count ?? 0 >= 6 {
                if (level.classSlots?.array as! [SpellSlot])[i].slots != 0 {
                    let spellsPerDay = Int((level.classSlots?.array as! [SpellSlot])[i].slots) + bonusSpells(forPC: PC, basedOn: level.spellcastingAbility ?? "")[i]
                    let spellsUsed = Int((level.classSlots?.array as! [SpellSlot])[i].used)
                    let spellsLeft = spellsPerDay - spellsUsed
                    buttons[i]?.setTitle("\(spellsLeft) / \(spellsPerDay)", for: .normal)
                } else {
                    let spellsPerDay = 0
                    let spellsUsed = Int((level.classSlots?.array as! [SpellSlot])[i].used)
                    let spellsLeft = spellsPerDay - spellsUsed
                    buttons[i]?.setTitle("\(spellsLeft) / \(spellsPerDay)", for: .normal)
                }
            }
        }
    }
    
    func updatePalette() {
        
        view.backgroundColor = palette.bg
        let titles: Array<UILabel> = [casterClassTitle, casterLevelTitle, spellDCTitle, spellsPerDayTitle, spellsKnownTitle, level1Title, level2Title, level3Title, level4Title, level5Title, level6Title]
        for title in titles {
            title.textColor = palette.main
        }
        let spacers: Array<UIView> = [casterClassSpacer, spellsPerDaySpacer, spellsKnownSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        casterTextField.textColor = palette.text
        casterTextField.backgroundColor = palette.button
        let texts: Array<UILabel> = [spellDCLabel]
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        let btns: Array<UIButton> = [casterLevelButton, level1Button, level2Button, level3Button, level4Button, level5Button, level6Button]
        for button in btns {
            button.backgroundColor = palette.button
            button.setTitleColor(palette.text, for: .normal)
        }
        let tables: Array<UITableView> = [level0]
        for table in tables {
            table.separatorColor = palette.main
            table.backgroundColor = palette.bg
            
        }
        
    }
    
    // MARK: - Buttons
    @IBAction func casterLevel(_ sender: Any) {
        let rvc = self.storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        rvc.rollName = "Caster Level"
        rvc.expression = "1d20+\(level.levels)"
        rvc.PC = PC
        present(rvc, animated: true)
    }
    
    // MARK: - Get Spells
    func getSpellsFor(_ lvl: Level) -> Array<Array<Spell>> {
        var lvl0Spells = [Spell]()
        var lvl1Spells = [Spell]()
        var lvl2Spells = [Spell]()
        var lvl3Spells = [Spell]()
        var lvl4Spells = [Spell]()
        var lvl5Spells = [Spell]()
        var lvl6Spells = [Spell]()
        if let spells = level.classSpells?.allObjects as? [Spell] {
            for spell in spells {
                switch spell.level {
                case 0:
                    lvl0Spells.append(spell)
                case 1:
                    lvl1Spells.append(spell)
                case 2:
                    lvl2Spells.append(spell)
                case 3:
                    lvl3Spells.append(spell)
                case 4:
                    lvl4Spells.append(spell)
                case 5:
                    lvl5Spells.append(spell)
                case 6:
                    lvl6Spells.append(spell)
                default:
                    break
                }
            }
        }
        var lvlsArray = [lvl0Spells, lvl1Spells, lvl2Spells, lvl3Spells, lvl4Spells, lvl5Spells, lvl6Spells]
        
        for i in 0...6 {
            lvlsArray[i] = lvlsArray[i].sorted { $0.name! < $1.name! }
        }
        
        return lvlsArray
    }
    
    @IBAction func editUsed(_ sender: UIButton) {
        if pcHasLevel {
            let sue = storyboard?.instantiateViewController(withIdentifier: "SpellsUsedEditor") as! SpellsUsedEditor
            sue.PC = PC
            sue.spellLevel = sender.tag
            sue.slot = (level.classSlots?.array as! [SpellSlot])[sender.tag - 1]
            sue.spellCastingAbility = level.spellcastingAbility ?? ""
            present(sue, animated: true)
        }
    }
    
    
    
    // MARK: - Picker View
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PC.classLevels?.array.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.white]
        return NSAttributedString(string: (PC.classLevels?.array as! [Level])[row].name ?? "-", attributes: myAttribute)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pcHasLevel {
            level = (PC.classLevels?.array as! [Level])[row]
            casterTextField.text = level.name
        }
        PCChanged()
    }
    
    @objc func donePicker() {
        casterTextField.resignFirstResponder()
    }
    
    
    
    // MARK: - Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level \(section)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = palette.text
        //header.backgroundColor = palette.button
        header.contentView.backgroundColor = palette.button
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellsKnown[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = level0.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath) as! SpellCell
        cell.spellNameLabel.text = spellsKnown[indexPath.section][indexPath.row].name ?? ""
        //cell.backgroundView?.backgroundColor = palette.bg
        //cell.backgroundColor = palette.bg
        cell.contentView.backgroundColor = palette.bg
        cell.spellNameLabel.textColor = palette.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sv = storyboard?.instantiateViewController(withIdentifier: "SpellView") as! SpellView
        sv.spell = spellsKnown[indexPath.section][indexPath.row]
        sv.level = level
        present(sv, animated: true)
    }
    
    // MARK: - Scroll View
    
    /*
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            if(velocity.y>0) {
                UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }, completion: nil)
                
            } else {
                UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }, completion: nil)
            }
        }
    }
     */
    
}



class SpellCell: UITableViewCell {
    
    @IBOutlet weak var spellNameLabel: UILabel!
    
}


class SpellsUsedEditor: UIViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var slot = SpellSlot()
    var spellLevel = 0
    var spellCastingAbility = ""
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleSpacer: UIView!
    
    @IBOutlet weak var lessBtn: UIButton!
    @IBOutlet weak var spellsLeftLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePalette()
        titleLabel.text = "Level \(spellLevel) Spells"
        updateSpellsLeft()
    }
    
    func updateSpellsLeft() {
        var slotsLeft = Int16(0)
        if slot.slots != 0 {
            slotsLeft = (slot.slots + Int16(bonusSpells(forPC: PC, basedOn: spellCastingAbility)[spellLevel - 1])) - slot.used
        } else {
            slotsLeft = 0 - slot.used
        }
        spellsLeftLabel.text = "\(slotsLeft)"
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        titleLabel.textColor = palette.main
        titleSpacer.backgroundColor = palette.main
        spellsLeftLabel.textColor = palette.text
        lessBtn.backgroundColor = palette.main
        moreBtn.backgroundColor = palette.main
        if palette.text == UIColor.white {
            lessBtn.setTitleColor(UIColor.black, for: .normal)
            moreBtn.setTitleColor(UIColor.black, for: .normal)
        } else {
            lessBtn.setTitleColor(UIColor.white, for: .normal)
            moreBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: - Buttons
    @IBAction func minus(_ sender: Any) {
        slot.used += 1
        updateSpellsLeft()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)

    }
    
    @IBAction func plus(_ sender: Any) {
        slot.used -= 1
        updateSpellsLeft()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)

    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}



class SpellView: UIViewController {
    
    // MARK: - Attributes
    var spell = Spell()
    var level = Level()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var spellNameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    
    @IBOutlet weak var spellContentLabel: UILabel!
    
    @IBOutlet weak var castBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        spellNameLabel.text = spell.name
        
        let content = NSMutableAttributedString()
        content
            .bold("Level ")
            .normal("\(spell.level)")
        if spell.school != nil {
            content
                .bold("\nSchool ")
                .normal(spell.school!)
        }
        if spell.castingTime != nil {
            content
                .bold("\nCasting Time ")
                .normal(spell.castingTime!)
        }
        if spell.range != nil {
            content
                .bold("\nRange ")
                .normal(spell.range!)
        }
        if spell.area != nil {
            content
                .bold("\nArea ")
                .normal(spell.area!)
        }
        if spell.effect != nil {
            content
                .bold("\nEffect ")
                .normal(spell.effect!)
        }
        if spell.duration != nil {
            content
                .bold("\nDuration ")
                .normal(spell.duration!)
        }
        if spell.savingThrow != nil {
            content
                .bold("\nSaving Throw ")
                .normal(spell.savingThrow!)
        }
        if spell.spellResistance != nil {
            content
                .bold("\nSpell Resistance ")
                .normal(spell.spellResistance!)
        }
        content.normal("\n\n\(spell.content ?? "")")
        
        spellContentLabel.attributedText = content
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        spellNameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        spellContentLabel.textColor = palette.text
        castBtn.backgroundColor = palette.main
        if palette.text == UIColor.white {
            castBtn.setTitleColor(UIColor.black, for: .normal)
        } else {
            castBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: - Buttons
    @IBAction func castSpell(_ sender: Any) {
        let spellLevel = Int(spell.level)
        if spellLevel != 0 {
            let slot = (level.classSlots?.array as! [SpellSlot])[spellLevel - 1]
            slot.used += 1
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}








