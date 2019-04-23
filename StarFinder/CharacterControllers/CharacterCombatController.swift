//
//  CharacterCombatController.swift
//  StarFinder
//
//  Created by Tom on 5/24/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterCombatController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var attacks = [Attack]()
    var equipedWeaps = [Weapon]()
    var trackers = [Tracker]()
    var modifiers = [Bonus]()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as? String ?? "Space")
    
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var background: UIView!
    
    @IBOutlet weak var statsTitle: UILabel!
    @IBOutlet weak var statsSpacer: UIView!
    
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var initTitle: UILabel!
    @IBOutlet weak var babTitle: UILabel!
    @IBOutlet weak var meleeTitle: UILabel!
    @IBOutlet weak var rangeTitle: UILabel!
    
    @IBOutlet weak var speedBtn: UIButton!
    @IBOutlet weak var initBtn: UIButton!
    @IBOutlet weak var babBtn: UIButton!
    @IBOutlet weak var meleeBtn: UIButton!
    @IBOutlet weak var rangeBtn: UIButton!
    
    @IBOutlet weak var attacksTitle: UILabel!
    @IBOutlet weak var attacksSpacer: UIView!
    
    @IBOutlet weak var attacksTable: UITableView!
    @IBOutlet weak var attacksHeight: NSLayoutConstraint!
    
    @IBOutlet weak var countersTitle: UILabel!
    @IBOutlet weak var countersSpacer: UIView!
    
    @IBOutlet weak var countersTable: UITableView!
    @IBOutlet weak var countersHeight: NSLayoutConstraint!
    
    @IBOutlet weak var modifiersTitle: UILabel!
    @IBOutlet weak var newModifierButton: UIButton!
    @IBOutlet weak var modfiersSpacer: UIView!
    
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var modifiersHeight: NSLayoutConstraint!

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self

        attacksTable.delegate = self
        attacksTable.dataSource = self
        countersTable.delegate = self
        countersTable.dataSource = self
        modifiersTable.delegate = self
        modifiersTable.dataSource = self

        
        PCChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        updatePalette()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        modifiersTable.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        
        speedBtn.setTitle("\(30+bonus(to: "speed", forPC: PC))ft", for: .normal)
        initBtn.setTitle(cleanPossNeg(of: (roll(from: "DEX+\(bonus(to: "initiative", forPC: PC))", forPC: PC).result)), for: .normal)
        babBtn.setTitle(cleanPossNeg(of: roll(from: "BAB", forPC: PC).result), for: .normal)
        meleeBtn.setTitle(cleanPossNeg(of: roll(from: "BAB+STR", forPC: PC).result), for: .normal)
        rangeBtn.setTitle(cleanPossNeg(of: roll(from: "BAB+DEX", forPC: PC).result), for: .normal)
        
        
        equipedWeaps = [Weapon]()
        
        for weap in PC.ownsWeapon?.array as! [Weapon] {
            if weap.equiped {
                equipedWeaps.append(weap)
            }
        }
        
        attacks = PC.attack?.array as! [Attack]
        
        trackers = PC.trackers?.array as! [Tracker]
        modifiers = PC.conditionalBonus?.array as! [Bonus]
        
        
        attacksTable.reloadData()
        attacksHeight.constant = attacksTable.contentSize.height
        countersTable.reloadData()
        countersHeight.constant = countersTable.contentSize.height
        modifiersTable.reloadData()
        modifiersHeight.constant = modifiersTable.contentSize.height
        modifiersTable.reloadData()
    }
    
    func updatePalette() {
        
        background.backgroundColor = palette.bg
        let titles: Array<UILabel> = [statsTitle, attacksTitle, countersTitle, modifiersTitle, speedTitle, initTitle, babTitle, meleeTitle, rangeTitle]
        for title in titles {
            title.textColor = palette.main
        }
        newModifierButton.setTitleColor(palette.main, for: .normal)
        let spacers: Array<UIView> = [statsSpacer, attacksSpacer, countersSpacer, modfiersSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        let texts: Array<UILabel> = []
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        let btns: Array<UIButton> = [speedBtn, initBtn, babBtn, meleeBtn, rangeBtn]
        for button in btns {
            button.backgroundColor = palette.button
            button.setTitleColor(palette.text, for: .normal)
        }
        let tables: Array<UITableView> = [attacksTable, countersTable, modifiersTable]
        for table in tables {
            table.separatorColor = palette.main
            table.backgroundColor = palette.bg
        }
        
    }

    // MARK: - Buttons
    @IBAction func topRoll(_ sender: UIButton) {
        let rvc = storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        rvc.PC = PC
        switch sender.tag {
        case 1:
            rvc.rollName = "Initiative"
            let ex = "1d20+DEX+\(bonus(to: "initiative", forPC: PC))"
            rvc.expression = simplifyNonVariables(forPC: PC, input: ex)
        case 2:
            rvc.rollName = "Base Attack Bonus"
            let ex = "1d20+BAB+\(bonus(to: "attack", forPC: PC))"
            rvc.expression = simplifyNonVariables(forPC: PC, input: ex)
        case 3:
            rvc.rollName = "Melee"
            let ex = "1d20+BAB+STR+\(bonus(to: "attack", forPC: PC))"
            rvc.expression = simplifyNonVariables(forPC: PC, input: ex)
        case 4:
            rvc.rollName = "Range"
            let ex = "1d20+BAB+DEX+\(bonus(to: "attack", forPC: PC))"
            rvc.expression = simplifyNonVariables(forPC: PC, input: ex)
        default:
            break
        }
        present(rvc, animated: true)
    }
    
    @IBAction func newModTapped(_ sender: Any) {
        let mvc = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
        mvc.PC = PC
        mvc.forObject = PC
        present(mvc, animated: true)
    }
    
    
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case attacksTable:
            return equipedWeaps.count + attacks.count
        case countersTable:
            return trackers.count
        case modifiersTable:
            return modifiers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case attacksTable:
            var name = ""
            var attack = ""
            var damage = ""
            var dtype = ""
            var crit = ""
            var capacity = 0
            var currentCharge = 0
            if indexPath.row > (equipedWeaps.count - 1) {
                let i = indexPath.row - equipedWeaps.count
                name = attacks[i].name ?? ""
                attack = (attacks[i].roll ?? "") + cleanPossNeg(of: bonus(to: "attack", forPC: PC, weapon: Weapon()))
                damage = (attacks[i].damage ?? "") + cleanPossNeg(of: bonus(to: "damage", forPC: PC, weapon: Weapon()))
                dtype = attacks[i].damageType ?? ""
                crit = attacks[i].critical ?? ""
                currentCharge = Int(attacks[i].charges)
                capacity = Int(attacks[i].capacity)
                
            } else {
                name = equipedWeaps[indexPath.row].name ?? ""
                attack = (equipedWeaps[indexPath.row].roll ?? "") + cleanPossNeg(of: (bonus(to: "attack", forPC: PC, weapon: equipedWeaps[indexPath.row])))
                damage = equipedWeaps[indexPath.row].damage ?? ""
                if bonus(to: "damage", forPC: PC, weapon: equipedWeaps[indexPath.row]) != 0 {
                    damage += cleanPossNeg(of: (bonus(to: "damage", forPC: PC, weapon: equipedWeaps[indexPath.row])))
                }
                dtype = equipedWeaps[indexPath.row].damageType ?? ""
                crit = equipedWeaps[indexPath.row].critical ?? "-"
                currentCharge = Int(equipedWeaps[indexPath.row].charges)
                capacity = Int(equipedWeaps[indexPath.row].capacity)
            }
            let attString = NSMutableAttributedString()
            attString.damageNormal(simplifyNonVariables(forPC: PC, input: damage) + " ")
            if dtype.contains("B") {
                attString.physicalDamage("B")
            }
            if dtype.contains("P") {
                attString.physicalDamage("P")
            }
            if dtype.contains("S") {
                attString.physicalDamage("S")
            }
            if dtype.contains("A") {
                attString.acid("A")
            }
            if dtype.contains("C") {
                attString.cold("C")
            }
            if dtype.contains("E") {
                attString.electric("E")
            }
            if dtype.contains("F") {
                attString.fire("F")
            }
            if dtype.contains("O") {
                attString.sonic("s")
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttackCell", for: indexPath) as! AttackCell
            cell.attackNameLabel.text = name
            cell.attackNameLabel.textColor = palette.text
            cell.attackBonusTitle.textColor = palette.main
            cell.attackBonusLabel.text = cleanPossNeg(of: roll(from: attack, forPC: PC).result)
            cell.attackBonusLabel.textColor = palette.text
            cell.damageTitleLabel.textColor = palette.main
            cell.damageLabel.attributedText = attString
            cell.crit.text = "\(crit) "
            cell.critTitle.textColor = palette.main
            cell.crit.textColor = palette.text
            if capacity <= 0 {
                cell.chargesWidth.constant = 0
            } else {
                cell.chargesWidth.constant = 150
                cell.chargesProgress.progress = Float(currentCharge) / Float(capacity)
            }
            cell.backgroundColor = palette.bg
            return cell
        case countersTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTrackerCell", for: indexPath) as! CharacterTrackerCell
            cell.nameLabel.text = trackers[indexPath.row].name
            cell.nameLabel.textColor = palette.text
            cell.countLabel.text = "\(trackers[indexPath.row].value)"
            cell.countLabel.textColor = palette.text
            cell.backgroundColor = palette.bg
            return cell
        case modifiersTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModCell", for: indexPath) as! ModCell
            cell.modifier = modifiers[indexPath.row]
            cell.nameLabel.text = (modifiers[indexPath.row].type ?? "") + " " + cleanPossNeg(of: Int(modifiers[indexPath.row].bonus))
            cell.nameLabel.textColor = palette.text
            if !modifiers[indexPath.row].enabled {
                cell.enabledBtn.setTitle("○", for: .normal)
            }
            cell.enabledBtn.setTitleColor(palette.main, for: .normal)
            cell.backgroundColor = palette.bg
            cell.tintColor = palette.bg
            cell.BG.backgroundColor = palette.bg
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView {
        case attacksTable:
            let advc  = storyboard?.instantiateViewController(withIdentifier: "AttackDisplay") as! AttackDisplay
            advc.PC = PC
            if indexPath.row > (equipedWeaps.count - 1) {
                let i = indexPath.row - equipedWeaps.count
                advc.attack = attacks[i]
            } else {
                advc.weapon = equipedWeaps[indexPath.row]
            }
            present(advc, animated: true)
        case modifiersTable:
            let cmvc = storyboard?.instantiateViewController(withIdentifier: "ConModView") as! ConModView
            cmvc.modifier = modifiers[indexPath.row]
            cmvc.PC = PC
            present(cmvc, animated: true)
        case countersTable:
            let tvc = storyboard?.instantiateViewController(withIdentifier: "TrackerView") as! TrackerView
            tvc.tracker = trackers[indexPath.row]
            present(tvc, animated: true)
        default:
            break
        }
    }
    
    
    /*
    // MARK: - Scroll View
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

class ModCell: UITableViewCell {
    var modifier = Bonus()
    @IBOutlet weak var enabledBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var BG: UIView!
    @IBAction func enabledTapped(_ sender: Any) {
        if modifier.enabled {
            modifier.enabled = false
            enabledBtn.setTitle("○", for: .normal)
        } else {
            modifier.enabled = true
            enabledBtn.setTitle("●", for: .normal)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
}


class AttackCell: UITableViewCell {
    
    @IBOutlet weak var attackNameLabel: UILabel!
    @IBOutlet weak var chargesProgress: UIProgressView!
    @IBOutlet weak var attackBonusTitle: UILabel!
    @IBOutlet weak var attackBonusLabel: UILabel!
    @IBOutlet weak var damageTitleLabel: UILabel!
    @IBOutlet weak var damageLabel: UILabel!
    @IBOutlet weak var critTitle: UILabel!
    @IBOutlet weak var crit: UILabel!
    @IBOutlet weak var chargesWidth: NSLayoutConstraint!
    
}
class CharacterTrackerCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
}


class ConModView: UIViewController {
    
    // MARK: - Attributes
    var modifier = Bonus()
    var PC = PlayerCharacter()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePalette()
        setupForMod()
    }
    
    func setupForMod() {
        nameLabel.text = (modifier.type ?? "") + " " + cleanPossNeg(of: Int(modifier.bonus))
        contentLabel.isHidden = true
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        nameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        contentLabel.textColor = palette.text
        editBtn.backgroundColor = palette.main
        deleteBtn.backgroundColor = palette.main
        editBtn.setTitleColor(palette.alt, for: .normal)
        deleteBtn.setTitleColor(palette.alt, for: .normal)
       
    }
    
    // MARK: - Buttons
    @IBAction func edit(_ sender: Any) {
        weak var pvc = self.presentingViewController
        dismiss(animated: true, completion: {
            let mvc = self.storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            mvc.PC = self.PC
            mvc.forObject = self.PC
            mvc.previousMod = self.modifier
            pvc?.present(mvc, animated: true)
        })
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if modifier.managedObjectContext == context {
            context.delete(modifier)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}

class TrackerView: UIViewController {
    
    // MARK: - Attributes
    var tracker = Tracker()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var lessBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTracker()
        updatePalette()
    }
    
    // MARK: - Functions
    func loadTracker() {
        nameLabel.text = tracker.name
        valueLabel.text = "\(tracker.value)"
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        nameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        valueLabel.textColor = palette.text
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
    @IBAction func adjust(_ sender: UIButton) {
        tracker.value += Int64(sender.tag)
        valueLabel.text = "\(tracker.value)"
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}





class AttackDisplay: UIViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var attack = Attack()
    var weapon = Weapon()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    
    @IBOutlet weak var attackTitle: UILabel!
    @IBOutlet weak var attackBtn: UIButton!
    @IBOutlet weak var damageTitle: UILabel!
    @IBOutlet weak var damageBtn: UIButton!
    @IBOutlet weak var criticalTitle: UILabel!
    @IBOutlet weak var criticalLabel: UILabel!
    @IBOutlet weak var damageTypeTitle: UILabel!
    @IBOutlet weak var damageTypeLabel: UILabel!
    @IBOutlet weak var ammoStack: UIStackView!
    @IBOutlet weak var ammoTitle: UILabel!
    @IBOutlet weak var ammoLabel: UILabel!
    @IBOutlet weak var usageTitle: UILabel!
    @IBOutlet weak var usageLabel: UILabel!
    @IBOutlet weak var ammoProgress: UIProgressView!
    @IBOutlet weak var useBtn: UIButton!
    @IBOutlet weak var reloadBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        loadAttack()
        
        PCChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
        
    
    @objc func PCChanged() {
        if attack.managedObjectContext != nil {
            if attack.usage <= 0 || attack.capacity <= 0 {
                ammoStack.isHidden = true
            } else {
                ammoLabel.text = "Ammunition \(attack.charges)/\(attack.capacity)"
                usageLabel.text = "Usage \(attack.usage)"
                ammoProgress.progress = Float(attack.charges)/Float(attack.capacity)
            }
        }
        if weapon.managedObjectContext != nil {
            if weapon.usage <= 0 || weapon.capacity <= 0 {
                ammoStack.isHidden = true
            } else {
                ammoLabel.text = "Ammunition \(weapon.charges)/\(weapon.capacity)"
                usageLabel.text = "Usage \(weapon.usage)"
                ammoProgress.progress = Float(weapon.charges)/Float(weapon.capacity)
            }
        }
    }
    
    func loadAttack() {
        var dtype = ""
        if attack.managedObjectContext != nil {
            nameLabel.text = attack.name
            let atk = (attack.roll ?? "") + "+\(bonus(to: "attack", forPC: PC, weapon: Weapon()))"
            let attackRoll = simplifyNonVariables(forPC: PC, input: atk)
            let damage = (attack.damage ?? "") + cleanPossNeg(of: bonus(to: "damage", forPC: PC, weapon: Weapon()))
            attackBtn.setTitle(cleanPossNeg(of: roll(from: (attackRoll), forPC: PC).result), for: .normal)
            damageBtn.setTitle(simplifyNonVariables(forPC: PC, input: damage), for: .normal)
            criticalLabel.text = attack.critical ?? "-"
            dtype = (attack.damageType ?? "").uppercased()
            
        }
        if weapon.managedObjectContext != nil {
            nameLabel.text = weapon.name
            let attackRoll = (weapon.roll ?? "") + cleanPossNeg(of: bonus(to: "attack", forPC: PC, weapon: weapon))
            let damageRoll = (weapon.damage ?? "") + cleanPossNeg(of: bonus(to: "damage", forPC: PC, weapon: weapon))
            attackBtn.setTitle(cleanPossNeg(of: roll(from: attackRoll, forPC: PC).result), for: .normal)
            damageBtn.setTitle(simplifyNonVariables(forPC: PC, input: damageRoll), for: .normal)
            criticalLabel.text = weapon.critical ?? "-"
            dtype = (weapon.damageType ?? "").uppercased()
            let contentString = NSMutableAttributedString()
            if weapon.range != 0 {
                contentString
                    .bold("Range ")
                    .normal("\(weapon.range)ft\n")
            }
            contentString
                .bold("Special ")
                .normal("\(weapon.special ?? "")\n")
                .normal("\n\(weapon.content ?? "")")
        }
        let attString = NSMutableAttributedString()
        if dtype.contains("B") {
            attString.physicalDamage("B")
        }
        if dtype.contains("P") {
            attString.physicalDamage("P")
        }
        if dtype.contains("S") {
            attString.physicalDamage("S")
        }
        if dtype.contains("A") {
            attString.acid("A")
        }
        if dtype.contains("C") {
            attString.cold("C")
        }
        if dtype.contains("E") {
            attString.electric("E")
        }
        if dtype.contains("F") {
            attString.fire("F")
        }
        if dtype.contains("O") {
            attString.sonic("s")
        }
        damageTypeLabel.attributedText = attString
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        nameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        let titles: Array<UILabel> = [nameLabel, attackTitle, damageTitle, criticalTitle, damageTypeTitle, ammoTitle, usageTitle]
        for title in titles {
            title.textColor = palette.main
        }
        let spacers: Array<UIView> = [nameSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        let texts: Array<UILabel> = [criticalLabel]
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        let btns: Array<UIButton> = [attackBtn, damageBtn, reloadBtn]
        for button in btns {
            button.backgroundColor = palette.button
            button.setTitleColor(palette.text, for: .normal)
        }
        useBtn.backgroundColor = palette.main
        if palette.text == UIColor.white {
            useBtn.setTitleColor(UIColor.black, for: .normal)
        } else {
            useBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: - Buttons
    @IBAction func attack(_ sender: UIButton) {
        let rvc = storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        rvc.PC = PC
        rvc.rollName = nameLabel.text ?? ""
        rvc.expression = "1d20\(sender.title(for: .normal) ?? "")"
        present(rvc, animated: true)
    }
    
    @IBAction func damage(_ sender: UIButton) {
        let rvc = storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        rvc.PC = PC
        rvc.rollName = nameLabel.text ?? ""
        rvc.expression = "\(sender.title(for: .normal) ?? "")"
        present(rvc, animated: true)
    }
    
    @IBAction func use(_ sender: Any) {
        if attack.managedObjectContext != nil {
            if attack.charges >= attack.usage {
                attack.charges -= attack.usage
                if attack.using?.isBattery ?? false {
                    attack.using?.current -= attack.usage
                }
            } else {
                let ac = UIAlertController(title: "Insufficient Ammunition", message: "Reload to use.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
                present(ac, animated: true)
            }
        }
        if weapon.managedObjectContext != nil {
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
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @IBAction func reload(_ sender: Any) {
        let rld = storyboard?.instantiateViewController(withIdentifier: "ReloadView") as! ReloadView
        rld.PC = PC
        if attack.managedObjectContext != nil {
            rld.weapon = attack
        }
        if weapon.managedObjectContext != nil {
            rld.weapon = weapon
        }
        present(rld, animated: true)
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}









