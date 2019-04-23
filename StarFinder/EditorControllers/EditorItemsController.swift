//
//  EditorItemsController.swift
//  StarFinder
//
//  Created by Tom on 5/14/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorItemsController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var armors = [Armor]()
    var weapons = [Weapon]()
    var items = [Item]()
    var ammo = [Ammo]()
    
    // MARK: - Outlets
    @IBOutlet weak var creditsTextField: UITextField!
    @IBOutlet weak var armorTable: UITableView!
    @IBOutlet weak var armorHeight: NSLayoutConstraint!
    @IBOutlet weak var weaponsTable: UITableView!
    @IBOutlet weak var weaponsHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsTable: UITableView!
    @IBOutlet weak var itemsHeight: NSLayoutConstraint!
    @IBOutlet weak var ammoTable: UITableView!
    @IBOutlet weak var ammoHeight: NSLayoutConstraint!
    
    
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        creditsTextField.delegate = self
        armorTable.delegate = self
        armorTable.dataSource = self
        armorTable.setEditing(true, animated: false)
        weaponsTable.delegate = self
        weaponsTable.dataSource = self
        weaponsTable.setEditing(true, animated: false)
        itemsTable.delegate = self
        itemsTable.dataSource = self
        itemsTable.setEditing(true, animated: false)
        ammoTable.delegate = self
        ammoTable.dataSource = self
        ammoTable.setEditing(true, animated: false)
        
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        creditsTextField.inputAccessoryView = toolBar
        
        creditsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        PCChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        creditsTextField.text = "\(PC.credits)"
        armors = [Armor]()
        for arm in PC.ownsArmor?.array as! [Armor] {
            armors.append(arm)
        }
        armorTable.reloadData()
        armorHeight.constant = armorTable.contentSize.height
        weapons = [Weapon]()
        for weap in PC.ownsWeapon?.array as! [Weapon] {
            weapons.append(weap)
        }
        weaponsTable.reloadData()
        weaponsHeight.constant = weaponsTable.contentSize.height
        items = [Item]()
        for item in PC.ownsItem?.array as! [Item] {
            items.append(item)
        }
        itemsTable.reloadData()
        itemsHeight.constant = itemsTable.contentSize.height
        ammo = [Ammo]()
        for ammos in PC.ownsBattery?.array as! [Ammo] {
            ammo.append(ammos)
        }
        ammoTable.reloadData()
        ammoHeight.constant = ammoTable.contentSize.height
    }
    
    @objc func donePicker() {
        creditsTextField.resignFirstResponder()
    }

    // MARK: - Buttons
    

    
    // MARK: - Text Fields
    func textFieldDidEndEditing(_ textField: UITextField) {
        PC.credits = Int64(creditsTextField.text!) ?? PC.credits
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        PC.credits = Int64(creditsTextField.text!) ?? PC.credits
    }
    
    
    
    // MARK: - TableViews
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .insert
        } else {
            return .delete
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case armorTable:
            return armors.count + 1
        case weaponsTable:
            return weapons.count + 1
        case itemsTable:
            return items.count + 1
        case ammoTable:
            return ammo.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case armorTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.sizeToFit()
                cell.textLabel?.text = "Add New Armor"
                return cell
            } else {
                let arm = armors[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArmorCell", for: indexPath) as! ArmorCell
                cell.title.text = arm.name
                var fusions = ""
                for fus in arm.armorFusion?.array as! [Fusion] {
                    fusions.append("\(fus.name ?? "") ")
                }
                if fusions == "" {
                    fusions = "Level \(arm.level)"
                }
                cell.subtitle.text = fusions
                return cell
            }
            
        case weaponsTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Add New Weapon"
                return cell
            } else {
                let weap = weapons[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeaponCell", for: indexPath) as! WeaponCell
                cell.title.text = weap.name
                var fusions = ""
                for fus in weap.weaponFusion?.array as! [Fusion] {
                    fusions.append("\(fus.name ?? "") ")
                }
                if fusions == "" {
                    fusions = "Level \(weap.level)"
                }
                cell.subtitle.text = fusions
                return cell
            }
            
        case itemsTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Add New Item"
                return cell
            } else {
                let it = items[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
                cell.title.text = it.name
                cell.subtitle.text = "Level \(it.level)"
                return cell
            }
        case ammoTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Add New Ammo"
                return cell
            } else {
                let it = ammo[indexPath.row - 1]
                let cell = tableView.dequeueReusableCell(withIdentifier: "AmmoCell", for: indexPath) as! AmmoCell
                cell.nameLabel.text = it.name
                cell.levelLabel.text = "Level \(it.level)"
                if it.isBattery {
                    cell.fullLabel.text = "Charges \(it.current)/\(it.capacity)"
                } else {
                    cell.fullLabel.text = "Remaining \(it.current)"
                }
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row != 0 {
            switch tableView {
            case armorTable:
                let vc = storyboard?.instantiateViewController(withIdentifier: "ArmorEditorNav") as! ArmorEditorNav
                vc.PC = PC
                vc.armor = armors[indexPath.row - 1]
                present(vc, animated: true)
            case weaponsTable:
                let vc = storyboard?.instantiateViewController(withIdentifier: "WeaponEditorNav") as! WeaponEditorNav
                vc.PC = PC
                vc.weapon = weapons[indexPath.row - 1]
                present(vc, animated: true)
            case itemsTable:
                let vc = storyboard?.instantiateViewController(withIdentifier: "ItemEditorNav") as! ItemEditorNav
                vc.PC = PC
                vc.item = items[indexPath.row - 1]
                present(vc, animated: true)
            case ammoTable:
                let iv = storyboard?.instantiateViewController(withIdentifier: "ItemView") as! ItemView
                iv.ammo = ammo[indexPath.row - 1]
                present(iv, animated: true)
            default:
                break
            }
        } else {
            performSegue(withIdentifier: "AddEquipment", sender: tableView)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            performSegue(withIdentifier: "AddEquipment", sender: tableView)
        } else if editingStyle == .delete {
            switch tableView {
            case armorTable:
                let itemToDelete = armors[indexPath.row - 1]
                itemToDelete.ownsArmor = nil
                context.delete(itemToDelete)
                armors.remove(at: indexPath.row - 1)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            case weaponsTable:
                let itemToDelete = weapons[indexPath.row - 1]
                weapons.remove(at: indexPath.row - 1)
                context.delete(itemToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            case itemsTable:
                let itemToDelete = items[indexPath.row - 1]
                items.remove(at: indexPath.row - 1)
                context.delete(itemToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            case ammoTable:
                let itemToDelete = ammo[indexPath.row - 1]
                ammo.remove(at: indexPath.row - 1)
                context.delete(itemToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            default:
                break
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddEquipment" {
            let vc = segue.destination as! AddItemController
            vc.PC = PC
            if let send = sender as? UITableView {
                switch send {
                case armorTable:
                    vc.mode = "armor"
                case weaponsTable:
                    vc.mode = "weapons"
                case itemsTable:
                    vc.mode = "items"
                case ammoTable:
                    vc.mode = "ammunition"
                default:
                    break
                }
            }
        }
    }
    
    
}

class AmmoCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var fullLabel: UILabel!
}

class BuyNav: UINavigationController {
    // MARK: - Attributes
    var mode = ""
    var PC = PlayerCharacter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


class AddItemController: UITableViewController {
    
    // MARK: - Attributes
    var mode = ""
    var PC = PlayerCharacter()
    
    var compArmor = [[CompendiumArmor]]()
    var sortedArmor = [[CompendiumArmor]]()
    var allArmor = [CompendiumArmor]()
    var nameArmor = [CompendiumArmor]()
    var contentArmor = [CompendiumArmor]()
    
    var compWeap = [[CompendiumWeapon]]()
    var sortedWeap = [[CompendiumWeapon]]()
    var allWeap = [CompendiumWeapon]()
    var nameWeap = [CompendiumWeapon]()
    var contentWeap = [CompendiumWeapon]()
    
    var compItem = [[CompendiumItem]]()
    var sortedItem = [[CompendiumItem]]()
    var allItem = [CompendiumItem]()
    var nameItem = [CompendiumItem]()
    var contentItem = [CompendiumItem]()
    
    var compAmmo = [CompendiumAmmo]()
    var sortedAmmo = [CompendiumAmmo]()
    var allAmmo = [CompendiumAmmo]()
    var nameAmmo = [CompendiumAmmo]()
    var contentAmmo = [CompendiumAmmo]()
    
    var searchController = UISearchController()
    
    
    // MARK: - Outlets
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = self.navigationController as? BuyNav {
            PC = nc.PC
            mode = nc.mode
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        }
        
        fetchAndSort(mode)
        tableView.reloadData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Equipment"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        var scopeButtons = [String]()
        switch mode {
        case "armor":
            scopeButtons = ["All", "Light", "Heavy", "Power"]
        case "weapons":
            scopeButtons = ["All", "Melee", "Ranged", "Other"]
        case "ammunition":
            scopeButtons = ["All", "Battery", "Round"]
        case "items":
            scopeButtons = ["All", "Magic", "Tech", "Hybrid"]
        default:
            break
        }
        searchController.searchBar.scopeButtonTitles = scopeButtons
        searchController.searchBar.delegate = self
        if mode != "ammunition" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create New", style: .plain, target: self, action: #selector(createNew))
        }
    }
    
    func fetchAndSort(_ mode: String) {
        switch mode {
        case "armor":
            do {
                allArmor = try context.fetch(CompendiumArmor.fetchRequest())
            } catch {
                print("failed to fetch comp armor")
            }
            var light = [CompendiumArmor]()
            var heavy = [CompendiumArmor]()
            var power = [CompendiumArmor]()
            for armor in allArmor {
                switch armor.type?.lowercased() {
                case "light":
                    light.append(armor)
                case "heavy":
                    heavy.append(armor)
                case "power":
                    power.append(armor)
                default:
                    break
                }
            }
            light = light.sorted { $0.name! < $1.name! }
            light = light.sorted { $0.level < $1.level }
            heavy = heavy.sorted { $0.name! < $1.name! }
            heavy = heavy.sorted { $0.level < $1.level }
            power = power.sorted { $0.name! < $1.name! }
            power = power.sorted { $0.level < $1.level }
            compArmor = [light, heavy, power]
        case "weapons":
            do {
                allWeap = try context.fetch(CompendiumWeapon.fetchRequest())
            } catch {
                print("failed to fetch comp weapons")
            }
            var BMOH = [CompendiumWeapon]()
            var BMTH = [CompendiumWeapon]()
            var AMOH = [CompendiumWeapon]()
            var AMTH = [CompendiumWeapon]()
            var small = [CompendiumWeapon]()
            var long = [CompendiumWeapon]()
            var heavy = [CompendiumWeapon]()
            var snipe = [CompendiumWeapon]()
            var grenade = [CompendiumWeapon]()
            var special = [CompendiumWeapon]()
            
            for weap in allWeap {
                switch weap.type?.lowercased() {
                case "basic melee one-handed":
                    BMOH.append(weap)
                case "basic melee two-handed":
                    BMTH.append(weap)
                case "advanced melee one-handed":
                    AMOH.append(weap)
                case "advanced melee two-handed":
                    AMTH.append(weap)
                case "small arm":
                    small.append(weap)
                case "long arm":
                    long.append(weap)
                case "heavy weapon":
                    heavy.append(weap)
                case "sniper":
                    snipe.append(weap)
                case "grenade":
                    grenade.append(weap)
                case "special":
                    special.append(weap)
                default:
                    break
                }
                compWeap = [[CompendiumWeapon]]()
                let unsortedWeap = [BMOH, BMTH, AMOH, AMTH, small, long, heavy, snipe, grenade, special]
                for weapCat in unsortedWeap {
                    let nameSort = weapCat.sorted { $0.name! < $1.name! }
                    compWeap.append(nameSort.sorted { $0.level < $1.level })
                }
            }
        case "ammunition":
            do {
                allAmmo = try context.fetch(CompendiumAmmo.fetchRequest())
            } catch {
                print("failed to fetch comp ammo")
            }
            compAmmo = allAmmo.sorted {$0.name! < $1.name!}
        case "items":
            do {
                allItem = try context.fetch(CompendiumItem.fetchRequest())
            } catch {
                print("failed to fetch comp ammo")
            }
            var magic = [CompendiumItem]()
            var tech = [CompendiumItem]()
            var hybrid = [CompendiumItem]()
            var other = [CompendiumItem]()
            for item in allItem {
                switch item.magicOrTech {
                case "M":
                    magic.append(item)
                case "T":
                    tech.append(item)
                case "MT":
                    hybrid.append(item)
                default:
                    other.append(item)
                }
                
            }
            compItem = [[CompendiumItem]]()
            let unsortedItem = [magic, tech, hybrid, other]
            for itemCat in unsortedItem {
                let nameSort = itemCat.sorted { $0.name! < $1.name! }
                compItem.append(nameSort.sorted { $0.level < $1.level })
            }
        default:
            print("Mode Unrecognized 👌")
        }
        
    }
    
    @objc func createNew() {
        switch mode {
        case "armor":
            let vc = storyboard?.instantiateViewController(withIdentifier: "ArmorEditorNav") as! ArmorEditorNav
            vc.PC = PC
            vc.armor = Armor(context: context)
            
            let eac = Bonus(context: context)
            eac.bonus = 0
            eac.type = "EAC"
            eac.enabled = true
            eac.armorBonus = vc.armor
            
            let kac = Bonus(context: context)
            kac.bonus = 0
            kac.type = "KAC"
            kac.enabled = true
            kac.armorBonus = vc.armor
            
            vc.armor.quantity = 1
            present(vc, animated: true)
        case "weapons":
            let vc = storyboard?.instantiateViewController(withIdentifier: "WeaponEditorNav") as! WeaponEditorNav
            vc.PC = PC
            vc.weapon = Weapon(context: context)
            vc.weapon.quantity = 1
            present(vc, animated: true)
        case "items":
            let vc = storyboard?.instantiateViewController(withIdentifier: "ItemEditorNav") as! ItemEditorNav
            vc.PC = PC
            vc.item = Item(context: context)
            vc.item.quantity = 1
            present(vc, animated: true)
        default:
            break
        }
    }
    
    @objc func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    // MARK: - Search Bar
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        switch mode {
        case "armor":
            nameArmor = allArmor.filter({ (compArm: CompendiumArmor) -> Bool in
                let doesCategoryMatch = (scope == "All") || (compArm.type?.lowercased() == scope.lowercased())
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && compArm.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
                    
                }
            })
            
            contentArmor = allArmor.filter({ (compArm: CompendiumArmor) -> Bool in
                let doesCategoryMatch = (scope == "All") || (compArm.type?.lowercased() == scope.lowercased())
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && compArm.content!.lowercased().contains(searchController.searchBar.text!.lowercased())
                }
            })
        case "weapons":
            nameWeap = allWeap.filter({ (cWeap: CompendiumWeapon) -> Bool in
                var category = ""
                switch cWeap.type {
                case "Basic Melee One-Handed", "Basic Melee Two-Handed", "Advanced Melee One-Handed", "Advanced Melee Two-Handed":
                    category = "Melee"
                case "Small Arm", "Long Arm", "Heavy Weapon", "Sniper":
                    category = "Ranged"
                case "Grenade", "Special":
                    category = "Other"
                default:
                    break
                }
                let doesCategoryMatch = (scope == "All") || (category.lowercased() == scope.lowercased())
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && cWeap.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
                    
                }
            })
            
            contentWeap = allWeap.filter({ (cWeap: CompendiumWeapon) -> Bool in
                var category = ""
                switch cWeap.type {
                case "Basic Melee One-Handed", "Basic Melee Two-Handed", "Advanced Melee One-Handed", "Advanced Melee Two-Handed":
                    category = "Melee"
                case "Small Arm", "Long Arm", "Heavy Weapon", "Sniper":
                    category = "Ranged"
                case "Grenade", "Special":
                    category = "Other"
                default:
                    break
                }
                let doesCategoryMatch = (scope == "All") || (category.lowercased() == scope.lowercased())
                
                var damageTypeMatch = false
                if ((cWeap.damageType ?? "").contains("A")) && (searchController.searchBar.text?.lowercased().contains("acid"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("B")) && (searchController.searchBar.text?.lowercased().contains("bludgeoning"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("C")) && (searchController.searchBar.text?.lowercased().contains("cold"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("E")) && (searchController.searchBar.text?.lowercased().contains("electricity"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("F")) && (searchController.searchBar.text?.lowercased().contains("fire"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("P")) && (searchController.searchBar.text?.lowercased().contains("piercing"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("S")) && (searchController.searchBar.text?.lowercased().contains("slashing"))! {
                    damageTypeMatch = true
                }
                if ((cWeap.damageType ?? "").contains("O")) && (searchController.searchBar.text?.lowercased().contains("sonic"))! {
                    damageTypeMatch = true
                }
                
                let searchMatch = (cWeap.content ?? "").lowercased().contains(searchController.searchBar.text!.lowercased()) || (cWeap.special ?? "").lowercased().contains(searchController.searchBar.text!.lowercased()) || (cWeap.critical ?? "").lowercased().contains(searchController.searchBar.text!.lowercased()) || damageTypeMatch
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && searchMatch
                }
            })
        case "ammunition":
            nameAmmo = compAmmo.filter({ (compAmmo: CompendiumAmmo) -> Bool in
                let doesCategoryMatch = (scope == "All") || (compAmmo.name?.lowercased().contains(scope.lowercased()))!
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && compAmmo.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
                    
                }
            })
            
            contentAmmo = compAmmo.filter({ (compAmmo: CompendiumAmmo) -> Bool in
                let doesCategoryMatch = (scope == "All") || (compAmmo.name?.lowercased().contains(scope.lowercased()))!
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && (compAmmo.content ?? "").lowercased().contains(searchController.searchBar.text!.lowercased())
                }
            })
        case "items":
            nameItem = allItem.filter({ (cItem: CompendiumItem) -> Bool in
                var catMatchesScope = false
                switch scope.lowercased() {
                case "magic":
                    catMatchesScope = cItem.magicOrTech?.contains("M") ?? false
                case "tech":
                    catMatchesScope = cItem.magicOrTech?.contains("T") ?? false
                case "hybrid":
                    catMatchesScope = cItem.magicOrTech?.contains("M") ?? false && cItem.magicOrTech?.contains("T") ?? false
                default:
                    catMatchesScope = false
                }
                let doesCategoryMatch = (scope == "All") || catMatchesScope
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && cItem.name!.lowercased().contains(searchController.searchBar.text!.lowercased())
                    
                }
            })
            
            contentItem = allItem.filter({ (cItem: CompendiumItem) -> Bool in
                var catMatchesScope = false
                switch scope.lowercased() {
                case "magic":
                    catMatchesScope = cItem.magicOrTech?.contains("M") ?? false
                case "tech":
                    catMatchesScope = cItem.magicOrTech?.contains("T") ?? false
                case "hybrid":
                    catMatchesScope = cItem.magicOrTech?.contains("M") ?? false && cItem.magicOrTech?.contains("T") ?? false
                default:
                    catMatchesScope = false
                }
                let doesCategoryMatch = (scope == "All") || catMatchesScope
                
                let doesContentMatch = (cItem.content ?? "").lowercased().contains(searchController.searchBar.text!.lowercased())
                || (cItem.category ?? "").lowercased().contains(searchController.searchBar.text!.lowercased())
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && doesContentMatch
                    
                }
            })
            
            
        default:
            break
        }
        
        nameArmor = nameArmor.sorted { $0.name! < $1.name! }.sorted { $0.level < $1.level }
        contentArmor = contentArmor.sorted { $0.name! < $1.name! }.sorted { $0.level < $1.level }
        nameWeap = nameWeap.sorted { $0.name! < $1.name! }.sorted { $0.level < $1.level }
        contentWeap = contentWeap.sorted { $0.name! < $1.name! }.sorted { $0.level < $1.level }

        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 2
        } else {
            switch mode {
            case "armor":
                return compArmor.count
            case "weapons":
                return compWeap.count
            case "items":
                return compItem.count
            case "ammunition":
                return 1
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            switch section {
            case 0:
                return "Name Match"
            case 1:
                return "Content Match"
            default:
                return nil
            }
        } else {
            switch mode {
            case "armor":
                switch section {
                case 0:
                    return "Light Armor"
                case 1:
                    return "Heavy Armor"
                case 2:
                    return "Power Armor"
                default:
                    return nil
                }
            case "weapons":
                switch section {
                case 0:
                    return "Basic Melee One-Handed"
                case 1:
                    return "Basic Melee Two-Handed"
                case 2:
                    return "Advanced Melee One-Handed"
                case 3:
                    return "Advanced Melee Two-Handed"
                case 4:
                    return "Small Arms"
                case 5:
                    return "Long Arms"
                case 6:
                    return "Heavy Weapons"
                case 7:
                    return "Snipers"
                case 8:
                    return "Grenades"
                case 9:
                    return "Special Weapons"
                default:
                    return nil
                }
            case "items":
                switch section {
                case 0:
                    return "Magic"
                case 1:
                    return "Tech"
                case 2:
                    return "Hybrid"
                case 3:
                    return "Other"
                default:
                    return nil
                }
            case "ammunition":
                return nil
            default:
                return nil
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case "armor":
            if isFiltering() {
                if section == 0 {
                    return nameArmor.count
                } else {
                    return contentArmor.count
                }
            } else {
                return compArmor[section].count
            }
        case "weapons":
            if isFiltering() {
                if section == 0 {
                    return nameWeap.count
                } else {
                    return contentWeap.count
                }
            } else {
                return compWeap[section].count
            }
        case "ammunition":
            if isFiltering() {
                if section == 0 {
                    return nameAmmo.count
                } else {
                    return contentAmmo.count
                }
            } else {
                return compAmmo.count
            }
        case "items":
            if isFiltering() {
                if section == 0 {
                    return nameItem.count
                } else {
                    return contentItem.count
                }
            } else {
                return compItem[section].count
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch mode {
        case "armor":
            if isFiltering() {
                if indexPath.section == 0 {
                    cell.textLabel?.text = nameArmor[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(nameArmor[indexPath.row].level)"
                } else {
                    cell.textLabel?.text = contentArmor[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(contentArmor[indexPath.row].level)"
                }
            } else {
                cell.textLabel?.text = compArmor[indexPath.section][indexPath.row].name
                cell.detailTextLabel?.text = "Level \(compArmor[indexPath.section][indexPath.row].level)"
            }
        case "weapons":
            if isFiltering() {
                if indexPath.section == 0 {
                    cell.textLabel?.text = nameWeap[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(nameWeap[indexPath.row].level)"
                } else {
                    cell.textLabel?.text = contentWeap[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(contentWeap[indexPath.row].level)"
                }
            } else {
                cell.textLabel?.text = compWeap[indexPath.section][indexPath.row].name
                cell.detailTextLabel?.text = "Level \(compWeap[indexPath.section][indexPath.row].level)"

            }
        case "ammunition":
            if isFiltering() {
                if indexPath.section == 0 {
                    cell.textLabel?.text = nameAmmo[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(nameAmmo[indexPath.row].level)"
                } else {
                    cell.textLabel?.text = contentAmmo[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(contentAmmo[indexPath.row].level)"
                }
            } else {
                cell.textLabel?.text = compAmmo[indexPath.row].name
                cell.detailTextLabel?.text = "Level \(compAmmo[indexPath.row].level)"
            }
        case "items":
            if isFiltering() {
                if indexPath.section == 0 {
                    cell.textLabel?.text = nameItem[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(nameItem[indexPath.row].level)"
                } else {
                    cell.textLabel?.text = contentItem[indexPath.row].name
                    cell.detailTextLabel?.text = "Level \(contentItem[indexPath.row].level)"
                }
            } else {
                cell.textLabel?.text = compItem[indexPath.section][indexPath.row].name
                cell.detailTextLabel?.text = "Level \(compItem[indexPath.section][indexPath.row].level)"
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ip = storyboard?.instantiateViewController(withIdentifier: "ItemPreview") as! ItemPreview
        ip.PC = PC
        switch mode {
        case "armor":
            if isFiltering() {
                if indexPath.section == 0 {
                    ip.armor = nameArmor[indexPath.row]
                } else {
                    ip.armor = contentArmor[indexPath.row]
                }
            } else {
                ip.armor = compArmor[indexPath.section][indexPath.row]
            }
        case "weapons":
            if isFiltering() {
                if indexPath.section == 0 {
                    ip.weapon = nameWeap[indexPath.row]
                } else {
                    ip.weapon = contentWeap[indexPath.row]
                }
            } else {
                ip.weapon = compWeap[indexPath.section][indexPath.row]
            }
        case "ammunition":
            if isFiltering() {
                if indexPath.section == 0 {
                    ip.ammo = nameAmmo[indexPath.row]
                } else {
                    ip.ammo = contentAmmo[indexPath.row]
                }
            } else {
                ip.ammo = compAmmo[indexPath.row]
            }
        case "items":
            if isFiltering() {
                if indexPath.section == 0 {
                    ip.item = nameItem[indexPath.row]
                } else {
                    ip.item = contentItem[indexPath.row]
                }
            } else {
                ip.item = compItem[indexPath.section][indexPath.row]
            }
        default:
            break
        }
        present(ip, animated: true)
    }
    
}

extension AddItemController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
}

extension AddItemController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


class ItemPreview: UIViewController {
    
    var PC = PlayerCharacter()
    var armor = CompendiumArmor()
    var weapon = CompendiumWeapon()
    var item = CompendiumItem()
    var ammo = CompendiumAmmo()
    var mode = ""
    var price = 0
    var name = ""
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemContent: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if armor.managedObjectContext == context {
            setupForArmor()
        } else if weapon.managedObjectContext == context {
            setupForWeapon()
        } else if item.managedObjectContext == context {
            setupForItem()
        } else if ammo.managedObjectContext == context {
            setupForAmmo()
        }
        
        itemNameLabel.text = name
        buyButton.setTitle("Buy \(price)", for: .normal)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true
        )
    }
    
    @IBAction func buy(_ sender: Any) {
        let ac = UIAlertController(title: "Confirm Purchase", message: "Buy \(name) for \(price)?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: confirmPurchase))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func pickUp(_ sender: Any) {
        switch mode {
        case "armor":
            addNewArmor()
        case "weapon":
            addNewWeapon()
        case "item":
            addNewItem()
        case "ammo":
            addNewAmmo()
        default:
            break
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true
        )
    }
    
    func confirmPurchase(action: UIAlertAction! = nil) {
        if PC.credits < Int64(price) {
            let ac = UIAlertController(title: "Insufficient Credits!", message: "You only have \(PC.credits) credits", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
            present(ac, animated: true)
        } else {
            PC.credits -= Int64(price)
            pickUp(0)
        }
    }
    
    func setupForArmor() {
        mode = "armor"
        name = armor.name ?? ""
        price = Int(armor.price)
        
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
        var type = "Untyped"
        if armor.type != nil || (armor.type?.count)! > 0 {
            type = armor.type!.prefix(1).uppercased() + armor.type!.dropFirst()
        }
        attString
            .bold("\(type) Armor\n", editor: true)
            .bold("Level ", editor: true)
            .normal("\(armor.level)\n", editor: true)
            .bold("Price ", editor: true)
            .normal("\(armor.price)\n", editor: true)
            .bold("EAC Bonus ", editor: true)
            .normal("\(eac)\n", editor: true)
            .bold("KAC Bonus ", editor: true)
            .normal("\(kac)\n", editor: true)
            .bold("Maximum Dex Bonus ", editor: true)
            .normal("\(armor.maxDexBonus)\n", editor: true)
            .bold("Armor Check Penalty ", editor: true)
            .normal("\(armor.checkPenalty)\n", editor: true)
        if speed != 0 {
            attString
                .bold("Speed Adjustment ", editor: true)
                .normal("\(speed)\n", editor: true)
        }
        attString
            .bold("Upgrade Slots ", editor: true)
            .normal("\(armor.upgradeSlots)\n", editor: true)
            .bold("Bulk ", editor: true)
        if armor.bulk == 0.1 {
            attString.normal("L\n", editor: true)
        } else {
            attString.normal("\(armor.bulk)\n".replacingOccurrences(of: ".0", with: ""), editor: true)
        }
        attString
            .normal("\n\(armor.content ?? "")", editor: true)
        itemContent.attributedText = attString
    }
    
    func setupForWeapon() {
        mode = "weapon"
        name = weapon.name ?? ""
        price = Int(weapon.price)
        
        let attString = NSMutableAttributedString()
        attString
            .bold("\(weapon.type ?? "Untyped")\n", editor: true)
            .bold("Level ", editor: true)
            .normal("\(weapon.level)\n", editor: true)
            .bold("Price ", editor: true)
            .normal("\(weapon.price)\n", editor: true)
        if weapon.range != 0 {
            attString
                .bold("Range ", editor: true)
                .normal("\(weapon.range)\n", editor: true)
        }
        attString
            .bold("Damage ", editor: true)
            .normal("\(weapon.damage ?? "")", editor: true)
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
            .bold("\nCritical ", editor: true)
            .normal("\(weapon.critical ?? "-")\n", editor: true)
        if weapon.capacity != 0 {
            attString
                .bold("Capacity ", editor: true)
                .normal("\(weapon.capacity)\n", editor: true)
        }
        if weapon.usage != 0 {
            attString
                .bold("Usage ", editor: true)
                .normal("\(weapon.usage)\n", editor: true)
        }
        attString
            .bold("Bulk ", editor: true)
        if weapon.bulk == 0.1 {
            attString.normal("L\n", editor: true)
        } else {
            attString.normal("\(weapon.bulk)\n".replacingOccurrences(of: ".0", with: ""), editor: true)
        }
        attString
            .bold("Special ", editor: true)
            .normal("\(weapon.special ?? "")\n", editor: true)
            
            .normal("\n\(weapon.content ?? "")", editor: true)
        
        itemContent.attributedText = attString
    }
    
    func setupForItem() {
        mode = "item"
        name = item.name ?? ""
        price = Int(item.price)
        
        let attString = NSMutableAttributedString()
        attString
            .bold("Category ", editor: true)
            .normal("\(item.category ?? "None")\n", editor: true)
            .bold("Level ", editor: true)
            .normal("\(item.level)\n", editor: true)
            .bold("Price ", editor: true)
            .normal("\(item.price)\n", editor: true)
        if item.capacity != 0 {
            attString
                .bold("Capacity ", editor: true)
                .normal("\(item.capacity)\n", editor: true)
        }
        if item.usage != 0 {
            attString
                .bold("Usage ", editor: true)
                .normal("\(item.usage)\n", editor: true)
        }
        attString
            .bold("Bulk ", editor: true)
        if item.bulk == 0.1 {
            attString.normal("L\n", editor: true)
        } else {
            attString.normal("\(item.bulk)\n".replacingOccurrences(of: ".0", with: ""), editor: true)
        }
        attString
            .normal("\n\(item.content ?? "")", editor: true)
        
        itemContent.attributedText = attString
    }
    
    func setupForAmmo() {
        mode = "ammo"
        name = ammo.name ?? ""
        price = Int(ammo.price)
        
        let attString = NSMutableAttributedString()
            .bold("Level ", editor: true)
            .normal("\(ammo.level)\n", editor: true)
            .bold("Price ", editor: true)
            .normal("\(ammo.price)\n", editor: true)
        if ammo.isBattery {
            attString
                .bold("Charges ", editor: true)
                .normal("\(ammo.charges)\n", editor: true)
        } else {
            attString
                .bold("Cartridges ", editor: true)
                .normal("\(ammo.comesAs)\n", editor: true)
        }
        attString
            .bold("Bulk ", editor: true)
        if ammo.bulk == 0.1 {
            attString.normal("L\n", editor: true)
        } else {
            attString.normal("\(ammo.bulk)\n".replacingOccurrences(of: ".0", with: ""), editor: true)
        }
        if ammo.special != nil && ammo.special != "" {
            attString
                .bold("Special ", editor: true)
                .normal("\(ammo.special!)\n", editor: true)
        }
        attString
            .normal("\n\(ammo.content ?? "")", editor: true)
        
        itemContent.attributedText = attString
    }
    
    
    func addNewArmor() {
        let newArmor = Armor(context: context)
        newArmor.quantity = 1
        newArmor.name = armor.name
        newArmor.price = armor.price
        newArmor.level = armor.level
        newArmor.type = armor.type
        newArmor.name = armor.name
        newArmor.maxDexBonus = armor.maxDexBonus
        newArmor.checkPenalty = armor.checkPenalty
        newArmor.upgradeSlots = armor.upgradeSlots
        newArmor.bulk = armor.bulk
        newArmor.usage = armor.usage
        newArmor.usageDuration = armor.usageDuration
        newArmor.capacity = armor.capacity
        newArmor.equiped = false
        newArmor.content = armor.content
        for bon in armor.armorBonus?.array as! [Bonus] {
            let newBonus = Bonus(context: context)
            newBonus.type = bon.type
            newBonus.bonus = bon.bonus
            newBonus.enabled = true
            newArmor.addToArmorBonus(newBonus)
        }
        PC.addToOwnsArmor(newArmor)
    }
    
    func addNewWeapon() {
        let newWeap = Weapon(context: context)
        newWeap.name = weapon.name
        newWeap.type = weapon.type
        newWeap.level = weapon.level
        newWeap.price = weapon.price
        newWeap.damage = weapon.damage
        newWeap.damageType = weapon.damageType
        newWeap.critical = weapon.critical
        newWeap.bulk = weapon.bulk
        newWeap.special = weapon.special
        newWeap.quantity = 1
        newWeap.usage = weapon.usage
        newWeap.capacity = weapon.capacity
        newWeap.content = weapon.content
        newWeap.equiped = false
        for bon in weapon.weaponBonus?.array as! [Bonus] {
            let newBonus = Bonus(context: context)
            newBonus.type = bon.type
            newBonus.bonus = bon.bonus
            newBonus.enabled = true
            newWeap.addToWeaponBonus(newBonus)
        }
        if (newWeap.type?.lowercased().contains("melee"))! {
            newWeap.roll = "BAB+STR"
        } else {
            newWeap.roll = "BAB+DEX"
        }
        PC.addToOwnsWeapon(newWeap)
    }
    
    func addNewItem() {
        let newItem = Item(context: context)
        newItem.quantity = 1
        newItem.name = item.name
        newItem.price = item.price
        newItem.level = item.level
        newItem.category = item.category
        newItem.bulk = item.bulk
        newItem.usage = item.usage
        newItem.capacity = item.capacity
        newItem.equiped = false
        newItem.content = item.content
        for bon in item.itemBonus?.array as! [Bonus] {
            let newBonus = Bonus(context: context)
            newBonus.type = bon.type
            newBonus.bonus = bon.bonus
            newBonus.enabled = true
            newItem.addToItemBonus(newBonus)
        }
        PC.addToOwnsItem(newItem)
    }
    
    func addNewAmmo() {
        let newAmmo = Ammo(context: context)
        newAmmo.name = ammo.name
        newAmmo.price = Float(ammo.price)/Float(ammo.comesAs)
        newAmmo.level = ammo.level
        newAmmo.isBattery = ammo.isBattery
        if ammo.isBattery {
            newAmmo.capacity = ammo.charges
            newAmmo.current = ammo.charges
        } else {
            newAmmo.current = ammo.comesAs
        }
        newAmmo.bulk = ammo.bulk
        newAmmo.perUnits = ammo.comesAs
        newAmmo.special = ammo.special
        newAmmo.ownsBattery = PC
    }
    
}


class ArmorEditorNav: UINavigationController {
    var armor = Armor()
    var PC = PlayerCharacter()
}


class ArmorEditor: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var armor = Armor()
    var modifiers = [Bonus]()
    var upgrades = [Fusion]()
    var currentTextField = UITextField()
    let typePicker = UIPickerView()
    let types = ["Light", "Heavy", "Power"]
    let levelPicker = UIPickerView()
    let maxDexPicker = UIPickerView()
    let checkPenaltyPicker = UIPickerView()
    let upgradeSlotsPicker = UIPickerView()
    let bulkPicker = UIPickerView()
    let bulks = ["0", "L", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    var pickersPick = ""
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var maxDexTextField: UITextField!
    @IBOutlet weak var armorCheckTextField: UITextField!
    @IBOutlet weak var upgradeSlotsTextField: UITextField!
    @IBOutlet weak var bulkTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var modifiersHeight: NSLayoutConstraint!
    @IBOutlet weak var upgradesTable: UITableView!
    @IBOutlet weak var upgradesHeight: NSLayoutConstraint!
    @IBOutlet weak var powerArmorStack: UIStackView!
    @IBOutlet weak var usageTextField: UITextField!
    @IBOutlet weak var usagePerTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        armor = (self.navigationController as! ArmorEditorNav).armor
        PC = (self.navigationController as! ArmorEditorNav).PC
        
        nameTextField.delegate = self
        typeTextField.delegate = self
        levelTextField.delegate = self
        priceTextField.delegate = self
        maxDexTextField.delegate = self
        armorCheckTextField.delegate = self
        upgradeSlotsTextField.delegate = self
        bulkTextField.delegate = self
        quantityTextField.delegate = self
        usageTextField.delegate = self
        usagePerTextField.delegate = self
        capacityTextField.delegate = self
        modifiersTable.delegate = self
        modifiersTable.dataSource = self
        upgradesTable.delegate = self
        upgradesTable.dataSource = self
        typePicker.delegate = self
        typePicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        maxDexPicker.delegate = self
        maxDexPicker.dataSource = self
        checkPenaltyPicker.delegate = self
        checkPenaltyPicker.dataSource = self
        upgradeSlotsPicker.delegate = self
        upgradeSlotsPicker.dataSource = self
        bulkPicker.delegate = self
        bulkPicker.dataSource = self
        
        modifiersTable.setEditing(true, animated: false)
        upgradesTable.setEditing(true, animated: false)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        typeTextField.inputAccessoryView = toolBar
        levelTextField.inputAccessoryView = toolBar
        maxDexTextField.inputAccessoryView = toolBar
        armorCheckTextField.inputAccessoryView = toolBar
        upgradeSlotsTextField.inputAccessoryView = toolBar
        bulkTextField.inputAccessoryView = toolBar
        priceTextField.inputAccessoryView = toolBar
        quantityTextField.inputAccessoryView = toolBar
        usageTextField.inputAccessoryView = toolBar
        capacityTextField.inputAccessoryView = toolBar
        
        typeTextField.inputView = typePicker
        levelTextField.inputView = levelPicker
        maxDexTextField.inputView = maxDexPicker
        armorCheckTextField.inputView = checkPenaltyPicker
        upgradeSlotsTextField.inputView = upgradeSlotsPicker
        bulkTextField.inputView = bulkPicker
        
        loadArmor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    func loadArmor() {
        nameTextField.text = armor.name
        typeTextField.text = armor.type
        if (armor.type ?? "").lowercased().contains("power") {
            powerArmorStack.isHidden = false
        } else {
            powerArmorStack.isHidden = true
        }
        levelTextField.text = "\(armor.level)"
        priceTextField.text = "\(armor.price)"
        maxDexTextField.text = "\(armor.maxDexBonus)"
        armorCheckTextField.text = "\(armor.checkPenalty)"
        upgradeSlotsTextField.text = "\(armor.upgradeSlots)"
        if armor.bulk == 0.1 {
            bulkTextField.text = "L"
        } else {
            bulkTextField.text = "\(armor.bulk)".replacingOccurrences(of: ".0", with: "")
        }
        quantityTextField.text = "\(armor.quantity)"
        
        contentLabel.text = armor.content
        
        modifiers = armor.armorBonus?.array as! [Bonus]
        upgrades = armor.armorFusion?.array as! [Fusion]
        
        modifiersTable.reloadData()
        upgradesTable.reloadData()
        modifiersHeight.constant = modifiersTable.contentSize.height
        upgradesHeight.constant = upgradesTable.contentSize.height
    }
    
    @objc func PCChanged() {
        contentLabel.text = armor.content
        
        modifiers = armor.armorBonus?.array as! [Bonus]
        upgrades = armor.armorFusion?.array as! [Fusion]

        modifiersTable.reloadData()
        upgradesTable.reloadData()
        modifiersHeight.constant = modifiersTable.contentSize.height
        upgradesHeight.constant = upgradesTable.contentSize.height
    }
    
    // MARK: - Buttons
    @objc func cancel() {
        if armor.ownsArmor == nil {
            context.delete(armor)
        }
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        armor.name = nameTextField.text
        armor.type = typeTextField.text
        armor.level = Int16(levelTextField.text ?? "0") ?? 0
        armor.price = Int64(priceTextField.text ?? "0") ?? 0
        armor.maxDexBonus = Int16(maxDexTextField.text ?? "0") ?? 0
        armor.checkPenalty = Int16(armorCheckTextField.text ?? "0") ?? 0
        armor.upgradeSlots = Int16(upgradeSlotsTextField.text ?? "0") ?? 0
        if bulkTextField.text == "L" {
            armor.bulk = 0.1
        } else {
            armor.bulk = Float(bulkTextField.text ?? "0") ?? 0.0
        }
        armor.quantity = Int64(quantityTextField.text ?? "0") ?? 0
        if powerArmorStack.isHidden {
            armor.using = nil
            armor.usage = 0
            armor.usageDuration = nil
            armor.capacity = 0
        } else {
            armor.usage = Int16(usageTextField.text ?? "0") ?? 0
            armor.usageDuration = usagePerTextField.text
            armor.capacity = Int16(capacityTextField.text ?? "0") ?? 0
        }
        armor.content = contentLabel.text
        armor.ownsArmor = PC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func contentTapped(_ sender: Any) {
        let textEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditorNavController") as! TextEditorNavController
        textEditVC.armor = self.armor
        present(textEditVC, animated: true)
    }
    
    // MARK: - Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField {
        case typeTextField:
            setDefaultPick(picker: typePicker, textField: textField)
        case levelTextField:
            setDefaultPick(picker: levelPicker, textField: textField)
        case maxDexTextField:
            setDefaultPick(picker: maxDexPicker, textField: textField)
        case armorCheckTextField:
            setDefaultPick(picker: checkPenaltyPicker, textField: textField)
        case upgradeSlotsTextField:
            setDefaultPick(picker: upgradeSlotsPicker, textField: textField)
        case bulkTextField:
            setDefaultPick(picker: bulkPicker, textField: textField)
        default:
            return
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if typeTextField.text?.lowercased().contains("power") ?? false {
            powerArmorStack.isHidden = false
        } else {
            powerArmorStack.isHidden = true
        }
    }
    
    // MARK: - Picker View
    func setDefaultPick(picker: UIPickerView, textField: UITextField, component: Int = 0) {
        var titles: Array<String> = []
        for i in 0...(picker.numberOfRows(inComponent: component) - 1) {
            titles.append(pickerView(picker, titleForRow: i, forComponent: component)!)
        }
        
        for i in 0...(titles.count - 1) {
            if textField.text == titles[i] {
                picker.selectRow(i, inComponent: component, animated: false)
                
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case typePicker:
            return types.count
        case levelPicker:
            return 20
        case maxDexPicker:
            return 11
        case checkPenaltyPicker:
            return 11
        case upgradeSlotsPicker:
            return 11
        case bulkPicker:
            return bulks.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case typePicker:
            return types[row]
        case levelPicker:
            return "\(row + 1)"
        case maxDexPicker:
            return "\(row)"
        case checkPenaltyPicker:
            return "\(-row)"
        case upgradeSlotsPicker:
            return "\(row)"
        case bulkPicker:
            return bulks[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerview: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickersPick = pickerView(pickerview, titleForRow: row, forComponent: component) ?? ""
        currentTextField.text = pickerView(pickerview, titleForRow: row, forComponent: component)
    }
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case modifiersTable:
            return modifiers.count + 1
        case upgradesTable:
            return upgrades.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case modifiersTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Modifier"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ModifierCell", for: indexPath) as! ModifierCell
                cell.nameLabel.text = modifiers[indexPath.row - 1].type
                cell.bonusLabel.text = "\(cleanPossNeg(of: Int(modifiers[indexPath.row - 1].bonus)))"
                return cell
            }
        case upgradesTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Upgrade"
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = upgrades[indexPath.row - 1].name
                cell.textLabel?.font = UIFont(name: "Helvetica", size: 17)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case modifiersTable:
            if indexPath.row == 0 {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = armor
                present(newModVC, animated: true)
            } else {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.previousMod = modifiers[indexPath.row - 1]
                newModVC.forObject = armor
                present(newModVC, animated: true)
            }
        case upgradesTable:
            let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
            nvc.armor = armor
            if indexPath.row == 0 {
                nvc.fusion = Fusion(context: context)
            } else {
                nvc.fusion = upgrades[indexPath.row - 1]
            }
            present(nvc, animated: true)
        default:
            break
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
        if tableView == modifiersTable {
            if editingStyle == .delete {
                let modifier = modifiers[indexPath.row - 1]
                modifiers.remove(at: indexPath.row - 1)
                context.delete(modifier)
                
                modifiersTable.reloadData()
                modifiersHeight.constant = modifiersTable.contentSize.height
            }
            if editingStyle == .insert {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = armor
                present(newModVC, animated: true)
            }
        } else {
            if editingStyle == .delete {
                let upgrade = upgrades[indexPath.row - 1]
                upgrades.remove(at: indexPath.row - 1)
                context.delete(upgrade)
                
                upgradesTable.reloadData()
                upgradesHeight.constant = upgradesTable.contentSize.height
            }
            if editingStyle == .insert {
                let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
                nvc.armor = armor
                nvc.fusion = Fusion(context: context)
                present(nvc, animated: true)
            }
        }
    }
    
}


class WeaponEditorNav: UINavigationController {
    var weapon = Weapon()
    var PC = PlayerCharacter()
}

class WeaponEditor: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: - Attributes
    var weapon = Weapon()
    var PC = PlayerCharacter()
    var modifiers = [Bonus]()
    var fusions = [Fusion]()
    let levelPicker = UIPickerView()
    let weaponTypePicker = UIPickerView()
    let weaponTypes = ["Basic Melee One-Handed", "Basic Melee Two-Handed", "Advanced Melee One-Handed", "Advanced Melee Two-Handed", "Small Arm", "Long Arm", "Heavy Weapon", "Sniper", "Grenade", "Special"]
    let bulkPicker = UIPickerView()
    let bulks = ["0", "L", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var currentTextField = UITextField()
    var damageType = ""
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var weaponTypeTextField: UITextField!
    @IBOutlet weak var rangeTextField: UITextField!
    @IBOutlet weak var attackRollTextField: UIButton!
    @IBOutlet weak var criticalTextField: UITextField!
    @IBOutlet weak var damageTextField: UIButton!
    @IBOutlet weak var usageTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    @IBOutlet weak var specialTextField: UITextField!
    @IBOutlet weak var bulkTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var modifiersHeight: NSLayoutConstraint!
    @IBOutlet weak var fusionsTable: UITableView!
    @IBOutlet weak var fusionsHeight: NSLayoutConstraint!
    @IBOutlet weak var bBtn: UIButton!
    @IBOutlet weak var pBtn: UIButton!
    @IBOutlet weak var sBtn: UIButton!
    @IBOutlet weak var aBtn: UIButton!
    @IBOutlet weak var cBtn: UIButton!
    @IBOutlet weak var eBtn: UIButton!
    @IBOutlet weak var fBtn: UIButton!
    @IBOutlet weak var oBtn: UIButton!
    
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PC = (self.navigationController as! WeaponEditorNav).PC
        weapon = (self.navigationController as! WeaponEditorNav).weapon
        damageType = weapon.damageType ?? ""
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        nameTextField.delegate = self
        levelTextField.delegate = self
        priceTextField.delegate = self
        weaponTypeTextField.delegate = self
        rangeTextField.delegate = self
        criticalTextField.delegate = self
        usageTextField.delegate = self
        capacityTextField.delegate = self
        specialTextField.delegate = self
        bulkTextField.delegate = self
        quantityTextField.delegate = self
        
        modifiersTable.delegate = self
        modifiersTable.dataSource = self
        modifiersTable.setEditing(true, animated: false)
        fusionsTable.delegate = self
        fusionsTable.dataSource = self
        fusionsTable.setEditing(true, animated: false)
        
        levelPicker.delegate = self
        levelPicker.dataSource = self
        weaponTypePicker.delegate = self
        weaponTypePicker.dataSource = self
        bulkPicker.delegate = self
        bulkPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        levelTextField.inputView = levelPicker
        weaponTypeTextField.inputView = weaponTypePicker
        bulkTextField.inputView = bulkPicker
        
        levelTextField.inputAccessoryView = toolBar
        weaponTypeTextField.inputAccessoryView = toolBar
        bulkTextField.inputAccessoryView = toolBar
        priceTextField.inputAccessoryView = toolBar
        rangeTextField.inputAccessoryView = toolBar
        usageTextField.inputAccessoryView = toolBar
        capacityTextField.inputAccessoryView = toolBar
        quantityTextField.inputAccessoryView = toolBar
        
        loadWeapon()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RollReturned), name:NSNotification.Name(rawValue: "RollReturned"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
    }
    
    //MARK: - Buttons
    @objc func cancel() {
        if weapon.ownsWeapon == nil {
            context.delete(weapon)
        }
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        weapon.name = nameTextField.text
        weapon.level = Int16(levelTextField.text ?? "") ?? 0
        weapon.price = Int64(priceTextField.text ?? "") ?? 0
        weapon.type = weaponTypeTextField.text
        weapon.range = Int64(rangeTextField.text ?? "0") ?? 0
        weapon.roll = attackRollTextField.title(for: .normal)
        weapon.critical = criticalTextField.text
        weapon.damage = damageTextField.title(for: .normal)
        weapon.damageType = damageType
        weapon.usage = Int16(usageTextField.text ?? "") ?? 0
        weapon.capacity = Int16(capacityTextField.text ?? "") ?? 0
        weapon.special = specialTextField.text
        weapon.quantity = Int64(quantityTextField.text ?? "") ?? 0
        if bulkTextField.text == "L" {
            weapon.bulk = 0.1
        } else {
            weapon.bulk = Float(bulkTextField.text ?? "") ?? 0.0
        }
        weapon.ownsWeapon = PC
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
    
    @objc func RollReturned() {
        attackRollTextField.setTitle(weapon.roll ?? "", for: .normal)
        damageTextField.setTitle(weapon.damage ?? "", for: .normal)
    }
    
    @objc func PCChanged() {
        modifiers = weapon.weaponBonus?.array as! [Bonus]
        fusions = weapon.weaponFusion?.array as! [Fusion]
        modifiersTable.reloadData()
        modifiersHeight.constant = modifiersTable.contentSize.height
        fusionsTable.reloadData()
        fusionsHeight.constant = fusionsTable.contentSize.height
        descriptionLabel.text = weapon.content
    }
    
    func loadWeapon() {
        nameTextField.text = weapon.name ?? ""
        levelTextField.text = "\(weapon.level)"
        priceTextField.text = "\(weapon.price)"
        weaponTypeTextField.text = weapon.type ?? ""
        rangeTextField.text = "\(weapon.range)"
        criticalTextField.text = weapon.critical ?? ""
        attackRollTextField.setTitle(weapon.roll ?? "", for: .normal)
        damageTextField.setTitle(weapon.damage ?? "", for: .normal)
        usageTextField.text = "\(weapon.usage)"
        capacityTextField.text = "\(weapon.capacity)"
        specialTextField.text = weapon.special ?? ""
        if weapon.bulk == 0.1 {
            bulkTextField.text = "L"
        } else {
            bulkTextField.text = "\(weapon.bulk)".replacingOccurrences(of: ".0", with: "")
        }
        quantityTextField.text = "\(weapon.quantity)"
        
        setButtonSelections()
        
        PCChanged()
    }
    
    @IBAction func editContent(_ sender: Any) {
        let textEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditorNavController") as! TextEditorNavController
        textEditVC.weapon = self.weapon
        present(textEditVC, animated: true)
    }
    
    
    // MARK: - TextField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField)
        print("Did End Editing")
        textField.resignFirstResponder()
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTextField.resignFirstResponder()

        
        switch textField {
        case levelTextField:
            currentTextField = textField
            let rowToSelect = (Int(levelTextField.text ?? "0") ?? 0) - 1
            levelPicker.selectRow(rowToSelect, inComponent: 0, animated: false)
        case weaponTypeTextField:
            currentTextField = textField
            setDefaultPick(picker: weaponTypePicker, array: weaponTypes, textField: weaponTypeTextField)
        case bulkTextField:
            currentTextField = textField
            setDefaultPick(picker: bulkPicker, array: bulks, textField: bulkTextField)
        default:
            currentTextField = textField
        }
    }
    
    @IBAction func showCalc(_ sender: UIButton) {
        if sender == attackRollTextField {
            currentTextField.resignFirstResponder()
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = true
            rcvc.inputExpression = weapon.roll ?? ""
            rcvc.weapon = weapon
            present(rcvc, animated: true)
        }
        
        if sender == damageTextField {
            currentTextField.resignFirstResponder()
            let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
            rcvc.PC = PC
            rcvc.inputMode = true
            rcvc.attackMode = false
            rcvc.inputExpression = weapon.damage ?? ""
            rcvc.weapon = weapon
            present(rcvc, animated: true)
        }
    }
    
    // MARK: - PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case levelPicker:
            return 20
        case weaponTypePicker:
            return weaponTypes.count
        case bulkPicker:
            return bulks.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case levelPicker:
            return "\(row + 1)"
        case weaponTypePicker:
            return weaponTypes[row]
        case bulkPicker:
            return bulks[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case levelPicker:
            currentTextField.text = "\(row + 1)"
        case weaponTypePicker:
            currentTextField.text = weaponTypes[row]
        case bulkPicker:
            currentTextField.text = bulks[row]
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
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case modifiersTable:
            return modifiers.count + 1
        case fusionsTable:
            return fusions.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case modifiersTable:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Modifier"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ModifierCell", for: indexPath) as! ModifierCell
                cell.nameLabel.text = modifiers[indexPath.row - 1].type
                cell.bonusLabel.text = "\(cleanPossNeg(of: Int(modifiers[indexPath.row - 1].bonus)))"
                return cell
            }
        default:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Fusion"
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = fusions[indexPath.row - 1].name
                cell.textLabel?.font = UIFont(name: "Helvetica", size: 17)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case modifiersTable:
            if indexPath.row == 0 {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = weapon
                present(newModVC, animated: true)
            } else {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.previousMod = modifiers[indexPath.row - 1]
                newModVC.forObject = weapon
                present(newModVC, animated: true)
            }
        case fusionsTable:
            let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
            nvc.weapon = weapon
            if indexPath.row == 0 {
                nvc.fusion = Fusion(context: context)
            } else {
                nvc.fusion = fusions[indexPath.row - 1]
            }
            present(nvc, animated: true)
        default:
            break
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
        if tableView == modifiersTable {
            if editingStyle == .delete {
                let modifier = modifiers[indexPath.row - 1]
                modifiers.remove(at: indexPath.row - 1)
                context.delete(modifier)
                
                modifiersTable.reloadData()
                modifiersHeight.constant = modifiersTable.contentSize.height
            }
            if editingStyle == .insert {
                let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
                newModVC.PC = PC
                newModVC.forObject = weapon
                present(newModVC, animated: true)
            }
        } else {
            if editingStyle == .delete {
                let upgrade = fusions[indexPath.row - 1]
                fusions.remove(at: indexPath.row - 1)
                context.delete(upgrade)
                
                fusionsTable.reloadData()
                fusionsHeight.constant = fusionsTable.contentSize.height
            }
            if editingStyle == .insert {
                let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
                nvc.weapon = weapon
                nvc.fusion = Fusion(context: context)
                present(nvc, animated: true)
            }
        }
    }
}

class ItemEditorNav: UINavigationController {
    var item = Item()
    var PC = PlayerCharacter()
}

class ItemEditor: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var item = Item()
    var modifiers = [Bonus]()
    var currentTextField = UITextField()
    let levelPicker = UIPickerView()
    let bulkPicker = UIPickerView()
    let bulks = ["0", "L", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var usageTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    @IBOutlet weak var bulkTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var contentField: UILabel!
    @IBOutlet weak var modifiersTable: UITableView!
    @IBOutlet weak var modifiersTableHeight: NSLayoutConstraint!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PC = (self.navigationController as! ItemEditorNav).PC
        item = (self.navigationController as! ItemEditorNav).item
        modifiers = item.itemBonus?.array as! [Bonus]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        nameTextField.delegate = self
        levelTextField.delegate = self
        priceTextField.delegate = self
        categoryTextField.delegate = self
        bulkTextField.delegate = self
        quantityTextField.delegate = self
        usageTextField.delegate = self
        capacityTextField.delegate = self
        
        modifiersTable.delegate = self
        modifiersTable.dataSource = self
        modifiersTable.setEditing(true, animated: false)
        
        levelPicker.delegate = self
        levelPicker.dataSource = self
        bulkPicker.delegate = self
        bulkPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        levelTextField.inputView = levelPicker
        bulkTextField.inputView = bulkPicker
        
        levelTextField.inputAccessoryView = toolBar
        bulkTextField.inputAccessoryView = toolBar
        priceTextField.inputAccessoryView = toolBar
        quantityTextField.inputAccessoryView = toolBar
        usageTextField.inputAccessoryView = toolBar
        capacityTextField.inputAccessoryView = toolBar
        
        levelPicker.delegate = self
        bulkPicker.delegate = self
        
        
        loadItem()

        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        }
    
    // MARK: - Functions
    func loadItem() {
        nameTextField.text = item.name
        categoryTextField.text = item.category
        levelTextField.text = "\(item.level)"
        priceTextField.text = "\(item.price)"
        usageTextField.text = "\(item.usage)"
        capacityTextField.text = "\(item.capacity)"
        if item.bulk == 0.1 {
            bulkTextField.text = "L"
        } else {
            bulkTextField.text = "\(item.bulk)".replacingOccurrences(of: ".0", with: "")
        }
        quantityTextField.text = "\(item.quantity)"
        contentField.text = item.content
        
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
    }
    
    @objc func PCChanged() {
        modifiers = item.itemBonus?.array as! [Bonus]
        contentField.text = item.content
        modifiersTable.reloadData()
        modifiersTableHeight.constant = modifiersTable.contentSize.height
    }
    
    @objc func cancel() {
        if item.ownsItem == nil {
            context.delete(item)
        }
        self.dismiss(animated: true)
    }
    
    @objc func save() {
        item.name = nameTextField.text
        item.level = Int16(levelTextField.text ?? "") ?? 0
        item.price = Int64(priceTextField.text ?? "") ?? 0
        item.usage = Int16(usageTextField.text ?? "") ?? 0
        item.capacity = Int16(capacityTextField.text ?? "") ?? 0
        item.category = categoryTextField.text
        item.quantity = Int64(quantityTextField.text ?? "") ?? 0
        if bulkTextField.text == "L" {
            item.bulk = 0.1
        } else {
            item.bulk = Float(bulkTextField.text ?? "") ?? 0.0
        }
        item.ownsItem = PC
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func contentTapped(_ sender: Any) {
        let textEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditorNavController") as! TextEditorNavController
        textEditVC.item = self.item
        present(textEditVC, animated: true)
    }
    
    // MARK: - Text Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        switch textField {
        case levelTextField:
            let rowToSelect = (Int(levelTextField.text ?? "0") ?? 0) - 1
            levelPicker.selectRow(rowToSelect, inComponent: 0, animated: false)
        case bulkTextField:
            setDefaultPick(picker: bulkPicker, array: bulks, textField: bulkTextField)
        default:
            break
        }
    }
    
    // MARK: - Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case levelPicker:
            return 20
        case bulkPicker:
            return bulks.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case levelPicker:
            return "\(row + 1)"
        case bulkPicker:
            return bulks[row]
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case levelPicker:
            currentTextField.text = "\(row + 1)"
        case bulkPicker:
            currentTextField.text = bulks[row]
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
    
    @objc func donePicker() {
        currentTextField.resignFirstResponder()
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modifiers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add New Modifier"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModifierCell", for: indexPath) as! ModifierCell
            cell.nameLabel.text = modifiers[indexPath.row - 1].type
            cell.bonusLabel.text = "\(cleanPossNeg(of: Int(modifiers[indexPath.row - 1].bonus)))"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            newModVC.PC = PC
            newModVC.forObject = item
            present(newModVC, animated: true)
        } else {
            let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            newModVC.PC = PC
            newModVC.previousMod = modifiers[indexPath.row - 1]
            newModVC.forObject = item
            present(newModVC, animated: true)
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
            let modifier = modifiers[indexPath.row - 1]
            modifiers.remove(at: indexPath.row - 1)
            context.delete(modifier)
            
            modifiersTable.reloadData()
            modifiersTableHeight.constant = modifiersTable.contentSize.height
            modifiersTable.layoutIfNeeded()
        }
        if editingStyle == .insert {
            let newModVC = storyboard?.instantiateViewController(withIdentifier: "ModifierController") as! ModifierController
            newModVC.PC = PC
            newModVC.forObject = item
            present(newModVC, animated: true)
        }
    }
    
}













