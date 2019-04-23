//
//  ItemsController.swift
//  StarFinder
//
//  Created by Tom on 5/13/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterItemsController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var armor = [Armor]()
    var weaps = [Weapon]()
    var items = [Item]()
    var ammo = [Ammo]()
    var gravityArray: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    var gravPicker = UIPickerView()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var equipmentTitle: UILabel!
    @IBOutlet weak var equipmentSpacer: UIView!
    
    @IBOutlet weak var sellBtn: UIButton!
    @IBOutlet weak var creditsTitle: UILabel!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var buyBtn: UIButton!
    
    @IBOutlet weak var bulkTitle: UILabel!
    @IBOutlet weak var bulkTotal: UILabel!
    @IBOutlet weak var encumberedTitle: UILabel!
    @IBOutlet weak var encumberedTotal: UILabel!
    @IBOutlet weak var overburdenedTitle: UILabel!
    @IBOutlet weak var overburdenedTotal: UILabel!
    @IBOutlet weak var gravityTitle: UILabel!
    @IBOutlet weak var gravityTextField: UITextField!
    
    @IBOutlet weak var armorTitle: UILabel!
    @IBOutlet weak var armorSpacer: UIView!
    @IBOutlet weak var armorTable: UITableView!
    @IBOutlet weak var armorHeight: NSLayoutConstraint!
    
    @IBOutlet weak var weaponsTitle: UILabel!
    @IBOutlet weak var weaponsSpacer: UIView!
    @IBOutlet weak var weaponsTable: UITableView!
    @IBOutlet weak var weaponsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var itemsTitle: UILabel!
    @IBOutlet weak var itemsSpacer: UIView!
    @IBOutlet weak var itemsTable: UITableView!
    @IBOutlet weak var itemsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ammoTitle: UILabel!
    @IBOutlet weak var ammoSpacer: UIView!
    @IBOutlet weak var ammoTable: UITableView!
    @IBOutlet weak var ammoHeight: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePalette()
        
        // MARK: - Delegates
        scrollView.delegate = self
        gravityTextField.delegate = self
        armorTable.delegate = self
        armorTable.dataSource = self
        weaponsTable.delegate = self
        weaponsTable.dataSource = self
        itemsTable.delegate = self
        itemsTable.dataSource = self
        ammoTable.delegate = self
        ammoTable.dataSource = self
        gravPicker.delegate = self
        gravPicker.dataSource = self
        gravPicker.backgroundColor = palette.bg
        gravPicker.tintColor = palette.text
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        gravityTextField.inputAccessoryView = toolBar
        gravityTextField.inputView = gravPicker
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }

    @objc func PCChanged() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:PC.credits))
        creditsButton.setTitle(formattedNumber ?? "0", for: .normal)
        
        var strengthScore = 0
        strengthScore += Int(PC.strength)
        strengthScore += Int(bonus(to: "strength", forPC: PC))
        encumberedTotal.text = "\(strengthScore/2)"
        overburdenedTotal.text = "\(strengthScore)"
        
        var bulk: Float = 0
        for armr in PC.ownsArmor?.array as! [Armor] {
            bulk += armr.bulk * Float(armr.quantity)
        }
        for weap in PC.ownsWeapon?.array as! [Weapon] {
            bulk += weap.bulk * Float(weap.quantity)
        }
        for item in PC.ownsItem?.array as! [Item] {
            bulk += item.bulk * Float(item.quantity)
        }
        for ammo in PC.ownsBattery?.array as! [Ammo] {
            if ammo.isBattery {
                bulk += ammo.bulk
            } else {
                bulk += (ammo.bulk / Float(ammo.perUnits)) * Float(ammo.current)
            }
        }
        bulk *= PC.gravityModifier
        bulkTotal.text = "\(Int(floor(bulk)))"
        
        gravityTextField.text = "\(PC.gravityModifier)"
        
        // MARK: - Table Views Resizing
        if let armr = PC.ownsArmor?.array as? [Armor] {
            armor = armr
        }
        if let weap = PC.ownsWeapon?.array as? [Weapon] {
            weaps = weap
        }
        if let item = PC.ownsItem?.array as? [Item] {
            items = item
        }
        if let amo = PC.ownsBattery?.array as? [Ammo] {
            ammo = amo
        }
        
        armorTable.reloadData()
        armorHeight.constant = armorTable.contentSize.height
        weaponsTable.reloadData()
        weaponsHeight.constant = weaponsTable.contentSize.height
        itemsTable.reloadData()
        itemsHeight.constant = itemsTable.contentSize.height
        ammoTable.reloadData()
        ammoHeight.constant = ammoTable.contentSize.height
    }
    
    func updatePalette() {
        view.backgroundColor = palette.bg
        let titles: Array<UILabel> = [equipmentTitle, creditsTitle, bulkTitle, encumberedTitle, overburdenedTitle, gravityTitle, armorTitle, weaponsTitle, itemsTitle, ammoTitle]
        for title in titles {
            title.textColor = palette.main
        }
        let spacers: Array<UIView> = [equipmentSpacer, armorSpacer, weaponsSpacer, itemsSpacer, ammoSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        let texts: Array<UILabel> = [bulkTotal, encumberedTotal, overburdenedTotal]
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        let btns: Array<UIButton> = [sellBtn, creditsButton, buyBtn]
        for button in btns {
            button.backgroundColor = palette.button
            button.setTitleColor(palette.text, for: .normal)
        }
        let tables: Array<UITableView> = [armorTable, weaponsTable, itemsTable, ammoTable]
        for table in tables {
            table.separatorColor = palette.main
            table.backgroundColor = palette.bg
        }
        gravityTextField.backgroundColor = palette.button
        gravityTextField.textColor = palette.text
    }
    
    // MARK: - Buttons
    @IBAction func editCredits(_ sender: Any) {
        let pvc = storyboard?.instantiateViewController(withIdentifier: "ProgressEditorController") as! ProgressEditorController
        pvc.PC = PC
        pvc.type = 4
        present(pvc, animated: true)
    }
    

    
    
    // MARK: - Table Views
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case armorTable:
            return armor.count
        case weaponsTable:
            return weaps.count
        case itemsTable:
            return items.count
        case ammoTable:
            return ammo.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case armorTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArmorCell", for: indexPath) as! ArmorCell
            cell.armor = armor[indexPath.row]
            if armor[indexPath.row].equiped {
                cell.toggleButton.setTitle("●", for: .normal)
            }
            cell.title.text = armor[indexPath.row].name
            var fusions = ""
            for fus in armor[indexPath.row].armorFusion?.array as! [Fusion] {
                fusions.append("\(fus.name ?? "") ")
            }
            if fusions == "" {
                fusions = "Level \(armor[indexPath.row].level)"
            }
            cell.subtitle.text = fusions
            cell.quanitityLabel.text = "\(armor[indexPath.row].quantity)"
            cell.quanitityLabel.textColor = palette.text
            cell.contentView.backgroundColor = palette.bg
            cell.toggleButton.setTitleColor(palette.main, for: .normal)
            cell.title.textColor = palette.text
            cell.subtitle.textColor = palette.text
            return cell
        case weaponsTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeaponCell", for: indexPath) as! WeaponCell
            cell.weapon = weaps[indexPath.row]
            if weaps[indexPath.row].equiped {
                cell.toggleButton.setTitle("●", for: .normal)
            }
            cell.title.text = weaps[indexPath.row].name
            var fusions = ""
            for fus in weaps[indexPath.row].weaponFusion?.array as! [Fusion] {
                fusions.append("\(fus.name ?? "") ")
            }
            if fusions == "" {
                fusions = "Level \(weaps[indexPath.row].level)"
            }
            cell.subtitle.text = fusions
            cell.quanitityLabel.text = "\(weaps[indexPath.row].quantity)"
            cell.quanitityLabel.textColor = palette.text
            cell.contentView.backgroundColor = palette.bg
            cell.toggleButton.setTitleColor(palette.main, for: .normal)
            cell.title.textColor = palette.text
            cell.subtitle.textColor = palette.text
            return cell
        case itemsTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            cell.item = items[indexPath.row]
            if items[indexPath.row].equiped {
                cell.toggleButton.setTitle("●", for: .normal)
            }
            cell.title.text = items[indexPath.row].name
            cell.subtitle.text = "Level \(items[indexPath.row].level)"
            cell.quanitityLabel.text = "\(items[indexPath.row].quantity)"
            cell.quanitityLabel.textColor = palette.text
            cell.contentView.backgroundColor = palette.bg
            cell.toggleButton.setTitleColor(palette.main, for: .normal)
            cell.title.textColor = palette.text
            cell.subtitle.textColor = palette.text
            return cell
        case ammoTable:
            
            let amo = ammo[indexPath.row]
            //
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmoCell", for: indexPath) as! AmmosCell
            cell.titleLabel.text = amo.name
            let isInUse = amo.usedBy?.array.count != 0 || amo.usedByAttack?.array.count != 0 || amo.usedByItem != nil || amo.usedByArmor != nil
            if amo.isBattery && isInUse {
                var usedBy: String = ""
                if (amo.usedBy?.array as! [Weapon]).count != 0 {
                    usedBy = (amo.usedBy?.array as! [Weapon]).first?.name ?? ""
                }
                if (amo.usedByAttack?.array as! [Attack]).count != 0 {
                    usedBy = (amo.usedByAttack?.array as! [Attack]).first?.name ?? ""
                }
                if amo.usedByArmor != nil {
                    usedBy = amo.usedByArmor?.name ?? ""
                }
                if amo.usedByItem != nil {
                    usedBy = amo.usedByItem?.name ?? ""
                }
                cell.subtitleLabel.text = "Used By \(usedBy)"
            } else {
                cell.subtitleLabel.text = "Level \(amo.level)"
            }
            if amo.isBattery {
                cell.roundStack.isHidden = true
                cell.chargesProgress.progress = Float(amo.current)/Float(amo.capacity)
                cell.chargesLabel.text = "\(amo.current)/\(amo.capacity)"
            } else {
                cell.batteryStack.isHidden = true
                cell.remainingLabel.text = "\(amo.current)"
            }
            cell.contentView.backgroundColor = palette.bg
            cell.titleLabel.textColor = palette.text
            cell.subtitleLabel.textColor = palette.text
            cell.chargesLabel.textColor = palette.text
            cell.remainingLabel.textColor = palette.text
            cell.remainingTitle.textColor = palette.text
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iv = storyboard?.instantiateViewController(withIdentifier: "ItemView") as! ItemView
        iv.PC = PC
        switch tableView {
        case armorTable:
            iv.armor = armor[indexPath.row]
        case weaponsTable:
            iv.weapon = weaps[indexPath.row]
        case itemsTable:
            iv.item = items[indexPath.row]
        case ammoTable:
            iv.ammo = ammo[indexPath.row]
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        present(iv, animated: true)
    }
    
    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gravityArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.white ]
        
        return NSAttributedString(string: "\(gravityArray[row])", attributes: myAttributes)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PC.gravityModifier = gravityArray[row]
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for i in 0...(gravityArray.count-1) {
            if textField.text == "\(gravityArray[i])" {
                gravPicker.selectRow(i, inComponent: 0, animated: false)
            }
        }
    }
    
    @objc func donePicker() {
        gravityTextField.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Buy" {
            let vc = segue.destination as! BuyMenu
            vc.PC = PC
        }
        if segue.identifier == "Sell" {
            let vc = segue.destination as! Sell
            vc.PC = PC
        }
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

class ArmorCell: UITableViewCell {
    var armor = Armor()
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var quanitityLabel: UILabel!
    @IBAction func toggleTapped(_ sender: UIButton) {
        if sender.currentTitle == "○" {
            armor.equiped = true
            sender.setTitle("●", for: .normal)
        } else {
            armor.equiped = false
            sender.setTitle("○", for: .normal)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
}

class WeaponCell: UITableViewCell {
    var weapon = Weapon()
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var quanitityLabel: UILabel!
    @IBAction func toggleTapped(_ sender: UIButton) {
        if sender.currentTitle == "○" {
            weapon.equiped = true
            sender.setTitle("●", for: .normal)
        } else {
            weapon.equiped = false
            sender.setTitle("○", for: .normal)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
}

class ItemCell: UITableViewCell {
    var item = Item()
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var quanitityLabel: UILabel!
    @IBAction func toggleTapped(_ sender: UIButton) {
        if sender.currentTitle == "○" {
            item.equiped = true
            sender.setTitle("●", for: .normal)
        } else {
            item.equiped = false
            sender.setTitle("○", for: .normal)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
}

class AmmosCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var batteryStack: UIStackView!
    @IBOutlet weak var roundStack: UIStackView!
    @IBOutlet weak var chargesProgress: UIProgressView!
    @IBOutlet weak var chargesLabel: UILabel!
    @IBOutlet weak var remainingTitle: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
}



class ItemView: UIViewController {
    
    // MARK: - Attributes
    var mode = ""
    var PC = PlayerCharacter()
    var armor = Armor()
    var weapon = Weapon()
    var item = Item()
    var ammo = Ammo()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var powerStack: UIStackView!
    @IBOutlet weak var chargeProgress: UIProgressView!
    @IBOutlet weak var loadBtn: UIButton!
    @IBOutlet weak var useBtn: UIButton!
    
    
    @IBOutlet weak var minus10: UIButton!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var plus10: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        if armor.managedObjectContext == context {
            mode = "armor"
            setUpForArmor()
        }
        if weapon.managedObjectContext == context {
            mode = "weapon"
            setUpForWeapon()
        }
        if item.managedObjectContext == context {
            mode = "item"
            setUpForItem()
        }
        if ammo.managedObjectContext == context {
            mode = "ammo"
            setUpForAmmo()
        }
        
        adjustQuantity(by: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        var num: Float = 0
        var denom: Float = 1
        switch mode {
        case "armor":
            if armor.capacity != 0 {
                num = Float(armor.charges)
                denom = Float(armor.capacity)
            }
        case "weapon":
            if weapon.capacity != 0 {
                num = Float(weapon.charges)
                denom = Float(weapon.capacity)
            }
        case "item":
            if item.capacity != 0 {
                num = Float(item.charges)
                denom = Float(item.capacity)
            }
        default:
            break
        }
        chargeProgress.progress = num/denom
    }
    
    func updatePalette() {
        windowView.backgroundColor = palette.bg
        nameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        quantityLabel.textColor = palette.text
        let btns: Array<UIButton> = [loadBtn, useBtn, minus10, minus, plus, plus10]
        for btn in btns {
            btn.setTitleColor(palette.alt, for: .normal)
            btn.backgroundColor = palette.main
        }
    }
    
    func setUpForArmor() {
        nameLabel.text = armor.name
        let attString = NSMutableAttributedString()
        var eac = 0
        var kac = 0
        var speed  = 0
        for bonus in armor.armorBonus?.array as! [Bonus] {
            if bonus.type == "EAC" {
                eac = Int(bonus.bonus)
            } else if bonus.type == "KAC" {
                kac = Int(bonus.bonus)
            } else if bonus.type?.lowercased() == "speed" {
                speed = Int(bonus.bonus)
            }
        }
        attString
            .bold("Price ")
            .normal("\(armor.price)\n")
            .bold("\(armor.type ?? "Untyped") Armor\n")
            .bold("Level ")
            .normal("\(armor.level)\n")
            .bold("Price ")
            .normal("\(armor.price)\n")
            .bold("EAC Bonus ")
            .normal("\(eac)\n")
            .bold("KAC Bonus ")
            .normal("\(kac)\n")
            .bold("Maximum Dex Bonus ")
            .normal("\(armor.maxDexBonus)\n")
            .bold("Armor Check Penalty ")
            .normal("\(armor.checkPenalty)\n")
        if speed != 0 {
            attString
                .bold("Speed Adjustment ")
                .normal("\(speed)\n")
        }
        attString
            .bold("Upgrade Slots ")
            .normal("\(armor.upgradeSlots)\n")
            .bold("Bulk ")
        if armor.bulk == 0.1 {
            attString.normal("L\n")
        } else {
            attString.normal("\(armor.bulk)\n".replacingOccurrences(of: ".0", with: ""))
        }
        
        if armor.capacity != 0 {
            attString.bold("Usage ")
            .normal("\(armor.usage) / \(armor.usageDuration ?? "")\n")
            .bold("Capacity ")
            .normal("\(armor.capacity)\n")
            powerStack.isHidden = false
            chargeProgress.progress = Float(armor.charges) / Float(armor.capacity)
        } else {
            powerStack.isHidden = true
        }
        
        attString
            .normal("\n\(armor.content ?? "")")
        if (armor.armorFusion?.array as! [Fusion]).count > 0 {
            attString
                .bold("\n\nUpgrades")
            for upgrade in armor.armorFusion?.array as! [Fusion] {
                attString
                    .bold("\n\(upgrade.name ?? "")")
                    .normal("\n\(upgrade.content ?? "")")
            }
        }
        let mods: Array<Bonus> = armor.armorBonus?.array as! Array<Bonus>
        if mods.count > 0 {
            attString.h1("\n\nModifiers")
            for mod in mods {
                attString.bold("\n\(mod.type ?? "")")
                    .normal(" \(cleanPossNeg(of: Int(mod.bonus)))")
            }
            
        }
        
        contentLabel.attributedText = attString
    }
    
    func setUpForWeapon() {
        nameLabel.text = weapon.name
        
        let attString = NSMutableAttributedString()
        attString
            .bold("\(weapon.type ?? "Untyped")\n")
            .bold("Level ")
            .normal("\(weapon.level)\n")
            .bold("Price ")
            .normal("\(weapon.price)\n")
        if weapon.range != 0 {
            attString
                .bold("Range ")
                .normal("\(weapon.range)ft\n")
        }
        attString
            .bold("Damage ")
            .normal("\(weapon.damage ?? "")")
        if let dtype = weapon.damageType?.uppercased() {
            if dtype.contains("B") {
                attString.physicalDamage(" B")
            }
            if dtype.contains("P") {
                attString.physicalDamage(" P")
            }
            if dtype.contains("S") {
                attString.physicalDamage(" S")
            }
            if dtype.contains("A") {
                attString.acid(" A")
            }
            if dtype.contains("C") {
                attString.cold(" C")
            }
            if dtype.contains("E") {
                attString.electric(" E")
            }
            if dtype.contains("F") {
                attString.fire(" F")
            }
            if dtype.contains("O") {
                attString.sonic(" s")
            }
        }
        attString
            .bold("\nCritical ")
            .normal("\(weapon.critical ?? "-")\n")
        if weapon.capacity != 0 {
            attString
                .bold("Capacity ")
                .normal("\(weapon.capacity)\n")
        }
        if weapon.usage != 0 {
            attString
                .bold("Usage ")
                .normal("\(weapon.usage)\n")
        }
        attString
            .bold("Bulk ")
        if weapon.bulk == 0.1 {
            attString.normal("L\n")
        } else {
            attString.normal("\(weapon.bulk)\n".replacingOccurrences(of: ".0", with: ""))
        }
        attString
            .bold("Special ")
            .normal("\(weapon.special ?? "")\n")
            
        if weapon.capacity != 0 {
            attString.bold("Usage ")
                .normal("\(weapon.usage) \n")
                .bold("Capacity ")
                .normal("\(weapon.capacity)\n")
            powerStack.isHidden = false
            chargeProgress.progress = Float(weapon.charges) / Float(weapon.capacity)
        } else {
            powerStack.isHidden = true
        }
        
        attString
            .normal("\n\(weapon.content ?? "")")
        let mods: Array<Bonus> = weapon.weaponBonus?.array as! Array<Bonus>
        if mods.count > 0 {
            attString.h1("\n\nModifiers")
            for mod in mods {
                attString.bold("\n\(mod.type ?? "")")
                    .normal(" \(cleanPossNeg(of: Int(mod.bonus)))")
            }
            
        }
        
        contentLabel.attributedText = attString
    }
    
    func setUpForItem() {
        nameLabel.text = item.name
        
        let attString = NSMutableAttributedString()
        attString
            .bold("Category ")
            .normal("\(item.category ?? "None")\n")
            .bold("Level ")
            .normal("\(item.level)\n")
            .bold("Price ")
            .normal("\(item.price)\n")
            .bold("Bulk ")
        if item.bulk == 0.1 {
            attString.normal("L\n")
        } else {
            attString.normal("\(item.bulk)\n".replacingOccurrences(of: ".0", with: ""))
        }
        
        if item.capacity != 0 {
            attString.bold("Usage ")
                .normal("\(item.usage) \n")
                .bold("Capacity ")
                .normal("\(item.capacity)\n")
            powerStack.isHidden = false
            chargeProgress.progress = Float(item.charges) / Float(item.capacity)
        } else {
            powerStack.isHidden = true
        }
        
        attString
            .normal("\n\(item.content ?? "")")
        
        let mods: Array<Bonus> = item.itemBonus?.array as! Array<Bonus>
        if mods.count > 0 {
            attString.h1("\n\nModifiers")
            for mod in mods {
                attString.bold("\n\(mod.type ?? "")")
                    .normal(" \(cleanPossNeg(of: Int(mod.bonus)))")
            }
            
        }
        
        contentLabel.attributedText = attString
    }
    
    func setUpForAmmo() {
        nameLabel.text = ammo.name
        let price = String(ammo.price).replacingOccurrences(of: ".0", with: "")
        let attString = NSMutableAttributedString()
            .bold("Level ")
            .normal("\(ammo.level)\n")
            .bold("Price ")
            .normal("\(price)\n")
        if ammo.isBattery {
            attString
                .bold("Capacity ")
                .normal("\(ammo.capacity)\n")
        }
        attString
            .bold("Bulk ")
        if ammo.bulk == 0.1 {
            attString.normal("L\n")
        } else {
            attString.normal("\(ammo.bulk)\n".replacingOccurrences(of: ".0", with: ""))
        }
        if ammo.special != nil && ammo.special != "" {
            attString
                .bold("Special ")
                .normal("\(ammo.special!)\n")
        }
        attString
            .normal("\n\(ammo.content ?? "")")
        contentLabel.attributedText = attString
        
        powerStack.isHidden = true
    }
    
    // MARK: - Buttons
    @IBAction func minus10(_ sender: Any) {
        adjustQuantity(by: -10)
    }
    
    @IBAction func plus10(_ sender: Any) {
        adjustQuantity(by: 10)
    }
    
    @IBAction func minusOne(_ sender: Any) {
        adjustQuantity(by: -1)
    }
    
    @IBAction func plusOne(_ sender: Any) {
        adjustQuantity(by: 1)
    }
    
    @IBAction func load(_ sender: Any) {
        let loader = storyboard?.instantiateViewController(withIdentifier: "ReloadView") as! ReloadView
        loader.PC = PC
        switch mode {
        case "armor":
            loader.weapon = armor
        case "weapon":
            loader.weapon = weapon
        case "item":
            loader.weapon = item
        default:
            break
        }
        present(loader, animated: true)
    }
    
    
    @IBAction func use(_ sender: Any) {
        switch mode {
        case "armor":
            if armor.charges >= armor.usage {
                armor.charges -= armor.usage
                
                armor.using?.current -= armor.usage
            } else {
                let ac = UIAlertController(title: "Insufficient Charge", message: "Load new battery to use.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
                present(ac, animated: true)
            }
        case "item":
            if item.charges >= item.usage {
                item.charges -= item.usage
                
                item.using?.current -= item.usage
            } else {
                let ac = UIAlertController(title: "Insufficient Charge", message: "Load new battery to use.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
                present(ac, animated: true)
            }
        case "weapon":
            if weapon.charges >= weapon.usage {
                weapon.charges -= weapon.usage
                if weapon.using?.isBattery ?? false {
                    weapon.using?.current -= weapon.usage
                }
            } else {
                let ac = UIAlertController(title: "Insufficient Ammunition", message: "Reload to use.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
                present(ac, animated: true)
            }
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func adjustQuantity(by: Int) {
        switch mode {
        case "armor":
            armor.quantity += Int64(by)
            if armor.quantity <= 0 {
                armor.quantity = 0
                askToDelete()
            }
            quantityLabel.text = "Quantity: \(armor.quantity)"
        case "weapon":
            weapon.quantity += Int64(by)
            if weapon.quantity <= 0 {
                weapon.quantity = 0
                askToDelete()
            }
            quantityLabel.text = "Quantity: \(weapon.quantity)"
        case "item":
            item.quantity += Int64(by)
            if item.quantity <= 0 {
                item.quantity = 0
                askToDelete()
            }
            quantityLabel.text = "Quantity: \(item.quantity)"
        case "ammo":
            if ammo.isBattery {
                ammo.current += Int16(by)
                if ammo.current <= 0 {
                    ammo.current = 0
                }
                if ammo.current > ammo.capacity {
                    ammo.current = ammo.capacity
                }
                quantityLabel.text = "Charge: \(ammo.current)/\(ammo.capacity)"
                if ammo.isBattery {
                    if let weap = (ammo.usedBy?.array as? [Weapon])?.first {
                        weap.charges = ammo.current
                    }
                    if let attk = (ammo.usedByAttack?.array as? [Weapon])?.first {
                        attk.charges = ammo.current
                    }
                    if let armr = ammo.usedByArmor {
                        armr.charges = ammo.current
                    }
                    if let item = ammo.usedByItem {
                        item.charges = ammo.current
                    }
                }
                
            } else {
                ammo.current += Int16(by)
                if ammo.current <= 0 {
                    ammo.current = 0
                    askToDelete()
                }
                quantityLabel.text = "Cartridges: \(ammo.current)"
            }
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    func askToDelete() {
        let ac = UIAlertController(title: "Quantity 0", message: "Delete the entry for this item?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: deleteItem))
        ac.addAction(UIAlertAction(title: "No", style: .cancel))
        present(ac, animated: true)
    }
    
    func deleteItem(action: UIAlertAction! = nil) {
        switch mode {
        case "armor":
            context.delete(armor)
        case "weapon":
            context.delete(weapon)
        case "item":
            context.delete(item)
        case "ammo":
            context.delete(ammo)
        default:
            break
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    
}
    

class BuyMenu: UIViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var buyTitle: UILabel!
    @IBOutlet weak var buySpacer: UIView!
    
    @IBOutlet weak var armorBtn: UIButton!
    @IBOutlet weak var weaponsBtn: UIButton!
    @IBOutlet weak var itemsBtn: UIButton!
    @IBOutlet weak var ammoBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePalette()
    }
    
    func updatePalette() {
        windowView.backgroundColor = palette.bg
        buyTitle.textColor = palette.main
        buySpacer.backgroundColor = palette.main
        let btns: Array<UIButton> = [armorBtn, weaponsBtn, itemsBtn, ammoBtn]
        for btn in btns {
            btn.backgroundColor = palette.alt
            btn.setTitleColor(palette.main, for: .normal)
        }
    }
    
    // MARK: - Buttons
    @IBAction func buy(_ sender: UIButton) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BuyNav") as! BuyNav
            vc.PC = self.PC
            vc.mode = sender.title(for: .normal)!.lowercased()
            pvc?.present(vc, animated: true)
        })
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
    


class Sell: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var keep = [Any]() {
        didSet {
            ownedTable.reloadData()
        }
    }
    var sell = [Any]() {
        didSet {
            sellTable.reloadData()
            updateSalePrice()
        }
    }
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    
    
    // MARK: - Outlets
    @IBOutlet weak var ownedTitle: UILabel!
    @IBOutlet weak var ownedSpacer: UIView!
    
    @IBOutlet weak var ownedTable: UITableView!
    
    @IBOutlet weak var sellTitle: UILabel!
    @IBOutlet weak var sellSpacer: UIView!
    
    @IBOutlet weak var sellTable: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sellBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        for obj in PC.ownsArmor?.array as! [Armor] {
            keep.append(obj)
        }
        for obj in PC.ownsWeapon?.array as! [Weapon] {
            keep.append(obj)
        }
        for obj in PC.ownsItem?.array as! [Item] {
            keep.append(obj)
        }
        for obj in PC.ownsBattery?.array as! [Ammo] {
            keep.append(obj)
        }
        
        
        keep = sortItems(keep)
        sell = sortItems(sell)
        
        ownedTable.delegate = self
        ownedTable.dataSource = self
        sellTable.delegate = self
        sellTable.dataSource = self
        
    }
    
    func updatePalette() {
        view.backgroundColor = palette.bg
        let titles: Array<UILabel> = [ownedTitle, sellTitle]
        for title in titles {
            title.textColor = palette.main
        }
        let spacers: Array<UIView> = [ownedSpacer, sellSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        cancelBtn.backgroundColor = palette.button
        cancelBtn.setTitleColor(palette.text
            , for: .normal)
        sellBtn.backgroundColor = palette.main
        sellBtn.setTitleColor(palette.alt
            , for: .normal)
        let tables: Array<UITableView> = [ownedTable, sellTable]
        for table in tables {
            table.separatorColor = palette.main
            table.backgroundColor = palette.bg
        }
    }
    
    func updateSalePrice() {
        var total = 0
        for obj in sell {
            if let object = obj as? Armor {
                total += (Int(object.price) * Int(object.quantity)) / 10
            }
            if let object = obj as? Weapon {
                total += (Int(object.price) * Int(object.quantity)) / 10
            }
            if let object = obj as? Item {
                total += (Int(object.price) * Int(object.quantity)) / 10
            }
            if let object = obj as? Ammo {
                if object.isBattery {
                    total += Int(object.price) / 10
                } else {
                    total += (Int(object.price * Float(object.current))) / 10
                }
            }
        }
        sellBtn.setTitle("Sell \(total)", for: .normal)
    }
    
    func sortItems(_ array: [Any]) -> Array<Any> {
        let sortedArray = array.sorted(by: { (obj1, obj2) -> Bool in
            var obj1name = String()
            var obj2name = String()
            
            var objs = [obj1, obj2]
            for i in 0...1 {
                if let name = (objs[i] as? Armor)?.name {
                    if i == 0 {
                        obj1name = name
                    } else {
                        obj2name = name
                    }
                }
                if let name = (objs[i] as? Weapon)?.name {
                    if i == 0 {
                        obj1name = name
                    } else {
                        obj2name = name
                    }
                }
                if let name = (objs[i] as? Item)?.name {
                    if i == 0 {
                        obj1name = name
                    } else {
                        obj2name = name
                    }
                }
                if let name = (objs[i] as? Ammo)?.name {
                    if i == 0 {
                        obj1name = name
                    } else {
                        obj2name = name
                    }
                }
            }
            return obj1name < obj2name
        })
        return sortedArray
    }
    
    // MARK: - Buttons
    @IBAction func cancel(_ sender: Any) {
        context.rollback()
        self.dismiss(animated: true)
    }
    
    @IBAction func sell(_ sender: UIButton) {
        keepGoodEntries()
        let saleTotal = Int((sender.title(for: .normal)?.replacingOccurrences(of: "Sell ", with: ""))!)
        for obj in sell {
            if obj is Armor {
                context.delete(obj as! Armor)
            } else if obj is Weapon {
                context.delete(obj as! Weapon)
            } else if obj is Item {
                context.delete(obj as! Item)
            } else if obj is Ammo {
                context.delete(obj as! Ammo)
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let svc = self.storyboard?.instantiateViewController(withIdentifier: "SaleSplit") as! SaleSplit
            svc.saleTotal = saleTotal ?? 0
            svc.PC = self.PC
            pvc?.present(svc, animated: true)
        })
        
    }
    
    
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case ownedTable:
            return keep.count
        case sellTable:
            return sell.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = palette.bg
        cell.textLabel?.textColor = palette.text
        cell.detailTextLabel?.textColor = palette.text
        var array = [Any]()
        switch tableView {
        case ownedTable:
            array = keep
        case sellTable:
            array = sell
        default:
            return UITableViewCell()
        }
        if let armor = array[indexPath.row] as? Armor {
            cell.textLabel?.text = "x\(armor.quantity) \(armor.name ?? "")"
            cell.detailTextLabel?.text = "\(armor.price/10)"
        }
        if let weapon = array[indexPath.row] as? Weapon {
            cell.textLabel?.text = "x\(weapon.quantity) \(weapon.name ?? "")"
            cell.detailTextLabel?.text = "\(weapon.price/10)"
        }
        if let item = array[indexPath.row] as? Item {
            cell.textLabel?.text = "x\(item.quantity) \(item.name ?? "")"
            cell.detailTextLabel?.text = "\(item.price/10)"
        }
        if let battery = array[indexPath.row] as? Ammo {
            if battery.isBattery {
                cell.textLabel?.text = "x1 \(battery.name ?? "")(\(battery.current)/\(battery.capacity))"
                cell.detailTextLabel?.text = "\(battery.price/10)".replacingOccurrences(of: ".0", with: "")
            } else {
                cell.textLabel?.text = "x\(battery.current) \(battery.name ?? "")"
                cell.detailTextLabel?.text = "\(battery.price/10)".replacingOccurrences(of: ".0", with: "")
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case ownedTable:
            let newArrays = moveItem(item: indexPath.row, from: keep, to: sell)
            keep = newArrays[0]
            sell = newArrays[1]
        case sellTable:
            let newArrays = moveItem(item: indexPath.row, from: sell, to: keep)
            sell = newArrays[0]
            keep = newArrays[1]
        default:
            break
        }
        
        
        
    }
    
    func moveItem(item: Int, from: [Any], to: [Any]) -> Array<Array<Any>> {
        var array1 = from
        var array2 = to
        let selectedObj = array1[item]
        switch selectedObj {
        case is Armor:
            var isLast = false
            if (selectedObj as! Armor).quantity >= 2 {
                (selectedObj as! Armor).quantity -= 1
            } else {
                isLast = true
                array1.remove(at: item)
            }
            if isLast {
                var foundMatch = false
                if array2.count > 0 {
                    for i in 0...(array2.count - 1) {
                        let obj = array2[i]
                        if obj is Armor {
                            if (obj as! Armor).name == (selectedObj as! Armor).name && (obj as! Armor).price == (selectedObj as! Armor).price {
                                (selectedObj as! Armor).quantity = (obj as! Armor).quantity + 1
                                array2.remove(at: i)
                                array2.append(selectedObj)
                                foundMatch = true
                            }
                        }
                    }
                }
                if !foundMatch {
                    array2.append(selectedObj)
                }
            } else {
                var foundMatch = false
                for obj in array2 {
                    if obj is Armor {
                        if (obj as! Armor).name == (selectedObj as! Armor).name && (obj as! Armor).price == (selectedObj as! Armor).price {
                            (obj as! Armor).quantity += 1
                            foundMatch = true
                        }
                    }
                }
                if !foundMatch {
                    let newArmor = Armor(context: context)
                    newArmor.name = (selectedObj as! Armor).name
                    newArmor.price = (selectedObj as! Armor).price
                    newArmor.quantity = 1
                    array2.append(newArmor)
                }
            }
            
        case is Weapon:
            var isLast = false
            if (selectedObj as! Weapon).quantity >= 2 {
                (selectedObj as! Weapon).quantity -= 1
            } else {
                isLast = true
                array1.remove(at: item)
            }
            if isLast {
                var foundMatch = false
                if array2.count > 0 {
                    for i in 0...(array2.count - 1) {
                        let obj = array2[i]
                        if obj is Weapon {
                            if (obj as! Weapon).name == (selectedObj as! Weapon).name && (obj as! Weapon).price == (selectedObj as! Weapon).price {
                                (selectedObj as! Weapon).quantity = (obj as! Weapon).quantity + 1
                                array2.remove(at: i)
                                array2.append(selectedObj)
                                foundMatch = true
                            }
                        }
                    }
                }
                if !foundMatch {
                    array2.append(selectedObj)
                }
            } else {
                var foundMatch = false
                for obj in array2 {
                    if obj is Weapon {
                        if (obj as! Weapon).name == (selectedObj as! Weapon).name && (obj as! Weapon).price == (selectedObj as! Weapon).price {
                            (obj as! Weapon).quantity += 1
                            foundMatch = true
                        }
                    }
                }
                if !foundMatch {
                    let newArmor = Weapon(context: context)
                    newArmor.name = (selectedObj as! Weapon).name
                    newArmor.price = (selectedObj as! Weapon).price
                    newArmor.quantity = 1
                    array2.append(newArmor)
                }
            }
        case is Item:
            var isLast = false
            if (selectedObj as! Item).quantity >= 2 {
                (selectedObj as! Item).quantity -= 1
            } else {
                isLast = true
                array1.remove(at: item)
            }
            if isLast {
                var foundMatch = false
                if array2.count > 0 {
                    for i in 0...(array2.count - 1) {
                        let obj = array2[i]
                        if obj is Item {
                            if (obj as! Item).name == (selectedObj as! Item).name && (obj as! Item).price == (selectedObj as! Item).price {
                                (selectedObj as! Item).quantity = (obj as! Item).quantity + 1
                                array2.remove(at: i)
                                array2.append(selectedObj)
                                foundMatch = true
                            }
                        }
                    }
                }
                if !foundMatch {
                    array2.append(selectedObj)
                }
            } else {
                var foundMatch = false
                for obj in array2 {
                    if obj is Item {
                        if (obj as! Item).name == (selectedObj as! Item).name && (obj as! Item).price == (selectedObj as! Item).price {
                            (obj as! Item).quantity += 1
                            foundMatch = true
                        }
                    }
                }
                if !foundMatch {
                    let newArmor = Item(context: context)
                    newArmor.name = (selectedObj as! Item).name
                    newArmor.price = (selectedObj as! Item).price
                    newArmor.quantity = 1
                    array2.append(newArmor)
                }
            }
            
        case is Ammo:
            if (selectedObj as! Ammo).isBattery {
                array1.remove(at: item)
                array2.append(selectedObj)
            } else {
                var isLast = false
                if (selectedObj as! Ammo).current >= 2 {
                    (selectedObj as! Ammo).current -= 1
                } else {
                    isLast = true
                    array1.remove(at: item)
                }
                if isLast {
                    var foundMatch = false
                    if array2.count > 0 {
                        for i in 0...(array2.count - 1) {
                            let obj = array2[i]
                            if obj is Ammo {
                                if (obj as! Ammo).name == (selectedObj as! Ammo).name && (obj as! Ammo).price == (selectedObj as! Ammo).price {
                                    (selectedObj as! Ammo).current = (obj as! Ammo).current + 1
                                    array2.remove(at: i)
                                    array2.append(selectedObj)
                                    foundMatch = true
                                }
                            }
                        }
                    }
                    if !foundMatch {
                        array2.append(selectedObj)
                    }
                } else {
                    var foundMatch = false
                    for obj in array2 {
                        if obj is Ammo {
                            if (obj as! Ammo).name == (selectedObj as! Ammo).name && (obj as! Ammo).price == (selectedObj as! Ammo).price {
                                (obj as! Ammo).current += 1
                                foundMatch = true
                            }
                        }
                    }
                    if !foundMatch {
                        let newAmmo = Ammo(context: context)
                        newAmmo.name = (selectedObj as! Ammo).name
                        newAmmo.price = (selectedObj as! Ammo).price
                        newAmmo.current = 1
                        array2.append(newAmmo)
                    }
                }
            }
            
        default:
            break
        }
        return [sortItems(array1), sortItems(array2)]
    }

    func keepGoodEntries() {
        if keep.count >= 1 {
            for x in 0...(keep.count - 1) {
                for y in 0...(sell.count - 1) {
                    var xName = ""
                    var xPrice: Int64 = 0
                    let xType = type(of: keep[x])
                    var xPC = PlayerCharacter()
                    var xQuantity: Int64 = 0
                    var yName = ""
                    var yPrice: Int64 = 0
                    let yType = type(of: sell[y])
                    var yQuantity: Int64 = 0
                    switch keep[x] {
                    case is Armor:
                        xName = (keep[x] as! Armor).name ?? ""
                        xPrice = (keep[x] as! Armor).price
                        xQuantity = (keep[x] as! Armor).quantity
                        xPC = (keep[x] as! Armor).ownsArmor ?? PlayerCharacter()
                    case is Weapon:
                        xName = (keep[x] as! Weapon).name ?? ""
                        xPrice = (keep[x] as! Weapon).price
                        xQuantity = (keep[x] as! Weapon).quantity
                        xPC = (keep[x] as! Weapon).ownsWeapon ?? PlayerCharacter()
                    case is Item:
                        xName = (keep[x] as! Item).name ?? ""
                        xPrice = (keep[x] as! Item).price
                        xQuantity = (keep[x] as! Item).quantity
                        xPC = (keep[x] as! Item).ownsItem ?? PlayerCharacter()
                    case is Ammo:
                        xName = (keep[x] as! Ammo).name ?? ""
                        xPrice = Int64((keep[x] as! Ammo).price)
                        xQuantity = Int64((keep[x] as! Ammo).current)
                        xPC = (keep[x] as! Ammo).ownsBattery ?? PlayerCharacter()
                    default: break
                    }
                    switch sell[y] {
                    case is Armor:
                        yName = (sell[y] as! Armor).name ?? ""
                        yPrice = (sell[y] as! Armor).price
                        yQuantity = (sell[y] as! Armor).quantity
                    case is Weapon:
                        yName = (sell[y] as! Weapon).name ?? ""
                        yPrice = (sell[y] as! Weapon).price
                        yQuantity = (sell[y] as! Weapon).quantity
                    case is Item:
                        yName = (sell[y] as! Item).name ?? ""
                        yPrice = (sell[y] as! Item).price
                        yQuantity = (sell[y] as! Item).quantity
                    default: break
                    }
                    if xType == yType
                        && xName == yName
                        && xPrice == yPrice
                    {
                        if xPC != PC {
                            let xItem = keep[x]
                            let yItem = sell[y]
                            keep.remove(at: x)
                            sell.remove(at: y)
                            switch xItem {
                            case is Armor:
                                (xItem as! Armor).quantity = yQuantity
                                (yItem as! Armor).quantity = xQuantity
                            case is Weapon:
                                (xItem as! Weapon).quantity = yQuantity
                                (yItem as! Weapon).quantity = xQuantity
                            case is Item:
                                (xItem as! Item).quantity = yQuantity
                                (yItem as! Item).quantity = xQuantity
                            default:
                                break
                            }
                            keep.append(yItem)
                            sell.append(xItem)
                            keep = sortItems(keep)
                            sell = sortItems(sell)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
}


class SaleSplit: UIViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var saleTotal = 0
    var numberOfShares = 1 {
        didSet{
            calcPayout()
        }
    }
    var pay = 0
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleSpacer: UIView!
    
    @IBOutlet weak var divideUpperText: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var payoutLabel: UILabel!
    @IBOutlet weak var claimBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePalette()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: saleTotal))
        titleLabel.text = "\(formattedNumber ?? "0") Credits"
        calcPayout()
    }
    
    func updatePalette() {
        windowView.backgroundColor = palette.bg
        let labels: Array<UILabel> = [titleLabel, divideUpperText, payoutLabel]
        for label in labels {
            label.textColor = palette.main
        }
        titleSpacer.backgroundColor = palette.main
        numberLabel.textColor = palette.text
        slider.minimumTrackTintColor = palette.main
        slider.maximumTrackTintColor = palette.text
        claimBtn.backgroundColor = palette.main
        claimBtn.setTitleColor(palette.alt, for: .normal)
    }
    
    func calcPayout() {
        pay = saleTotal/numberOfShares
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: pay))
        payoutLabel.text = "Each player recieves:\n\(formattedNumber ?? "0") Credits"
        claimBtn.setTitle("Claim \(formattedNumber ?? "0") Credits", for: .normal)
    }
    
    // MARK: - Buttons
    @IBAction func claim(_ sender: Any) {
        PC.credits += Int64(pay)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        self.dismiss(animated: true)
    }
    
    
    // MARK: - Slider
    @IBAction func sliderAdjust(_ sender: UISlider) {
        numberOfShares = Int(sender.value)
        numberLabel.text = "\(numberOfShares)"
    }
    
    
    
}




















