//
//  Loader.swift
//  StarFound
//
//  Created by Tom on 3/11/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import UIKit

class ReloadView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var weapon: Any = 0
    var ammo = [Ammo]()
    var selectedAmmo = Ammo()
    var unload = true
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    @IBOutlet weak var windowBG: UIView!
    
    @IBOutlet weak var loadTitle: UILabel!
    @IBOutlet weak var titleSpacer: UIView!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var loadBtn: UIButton!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        table.delegate = self
        table.dataSource = self
        
        
        
        let allAmmo = PC.ownsBattery?.array as! [Ammo]
        let allBatteries = allAmmo.filter { $0.isBattery }
        //let usedBatteries = allBatteries.filter { $0.usedByAttack != nil || $0.usedBy != nil || $0.usedByArmor != nil || $0.usedByItem != nil }
        
        let nonBatteries = allAmmo.filter { !$0.isBattery }
        let unusedBatteries = allBatteries.filter { $0.usedByAttack?.array.count ?? 0 == 0 && $0.usedBy?.array.count ?? 0 == 0 && $0.usedByArmor == nil && $0.usedByItem == nil }
        
        var thisItemsBattery: Ammo?
        switch weapon {
        case is Weapon:
            thisItemsBattery = (weapon as! Weapon).using
        case is Attack:
            thisItemsBattery = (weapon as! Attack).using
        case is Item:
            thisItemsBattery = (weapon as! Item).using
        case is Armor:
            thisItemsBattery = (weapon as! Armor).using
        default :
            break
        }
        
        
        if weapon is Weapon || weapon is Attack {
            ammo = nonBatteries + unusedBatteries
        } else {
            ammo = unusedBatteries
        }
        
        if let tib = thisItemsBattery {
            ammo.append(tib)
        }
        
        
        table.reloadData()
        
        if ammo.count > 0 {
            for i in 0...(ammo.count - 1) {
                switch weapon {
                case is Weapon:
                    let item = weapon as! Weapon
                    if item.using == ammo[i] {
                        selectedAmmo = ammo[i]
                        unload = false
                        table.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .middle)
                    }
                case is Attack:
                    let item = weapon as! Attack
                    if item.using == ammo[i] {
                        selectedAmmo = ammo[i]
                        unload = false
                        table.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .middle)
                    }
                case is Armor:
                    let item = weapon as! Armor
                    if item.using == ammo[i] {
                        selectedAmmo = ammo[i]
                        unload = false
                        table.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .middle)
                    }
                case is Item:
                    let item = weapon as! Item
                    if item.using == ammo[i] {
                        selectedAmmo = ammo[i]
                        unload = false
                        table.selectRow(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .middle)
                    }
                default:
                    break
                }
                
            }
        }
        
        
        
    }
    
    func updatePalette() {
        windowBG.backgroundColor = palette.bg
        loadTitle.textColor = palette.main
        titleSpacer.backgroundColor = palette.main
        table.backgroundColor = palette.bg
        table.separatorColor = palette.main
        
        loadBtn.backgroundColor = palette.main
        if palette.text == UIColor.white {
            loadBtn.setTitleColor(UIColor.black, for: .normal)
        } else {
            loadBtn.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    // MARK: - Buttons
    @IBAction func load(_ sender: Any) {
        if unload {
            switch weapon {
            case is Weapon:
                let weap = weapon as! Weapon
                if let amo = weap.using {
                    if !amo.isBattery {
                        amo.current += weap.charges
                    }
                }
                weap.using = nil
                weap.charges = 0
            case is Attack:
                let weap = weapon as! Attack
                if let amo = weap.using {
                    if !amo.isBattery {
                        amo.current += weap.charges
                    }
                }
                weap.using = nil
                weap.charges = 0
            case is Armor:
                let weap = weapon as! Armor
                weap.using = nil
                weap.charges = 0
            case is Item:
                let weap = weapon as! Item
                weap.using = nil
                weap.charges = 0
            default:
                break
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            self.dismiss(animated: true)
        } else {
            switch weapon {
            case is Weapon:
                let weap = weapon as! Weapon
                if selectedAmmo.isBattery {
                    if weap.capacity < selectedAmmo.capacity {
                        showError()
                    } else {
                        weap.using = selectedAmmo
                        weap.charges = selectedAmmo.current
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    }
                } else {
                    weap.using = selectedAmmo
                    let missing = weap.capacity - weap.charges
                    if missing > selectedAmmo.current {
                        weap.charges += selectedAmmo.current
                        selectedAmmo.current = 0
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    } else {
                        weap.charges = weap.capacity
                        selectedAmmo.current -= missing
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    }
                }
            case is Attack:
                let weap = weapon as! Attack
                if selectedAmmo.isBattery {
                    if weap.capacity < selectedAmmo.capacity {
                        showError()
                    } else {
                        weap.using = selectedAmmo
                        weap.charges = selectedAmmo.current
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    }
                } else {
                    weap.using = selectedAmmo
                    let missing = weap.capacity - weap.charges
                    if missing > selectedAmmo.current {
                        weap.charges += selectedAmmo.current
                        selectedAmmo.current = 0
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    } else {
                        weap.charges = weap.capacity
                        selectedAmmo.current -= missing
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                        self.dismiss(animated: true)
                    }
                }
            case is Armor:
                let armor = weapon as! Armor
                if armor.capacity < selectedAmmo.capacity {
                    showError()
                } else {
                    armor.using = selectedAmmo
                    armor.charges = selectedAmmo.current
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                    self.dismiss(animated: true)
                }
            case is Item:
                let item = weapon as! Item
                if item.capacity < selectedAmmo.capacity {
                    showError()
                } else {
                    item.using = selectedAmmo
                    item.charges = selectedAmmo.current
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                    self.dismiss(animated: true)
                }
            default:
                break
            }
        }
    }
    
    func showError() {
        let ac = UIAlertController(title: "Incorrect Battery", message: "This battery's capacity excedes this item's maximum.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(ac, animated: true)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ammo.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row <= ammo.count - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AmmoCell", for: indexPath)
            cell.textLabel?.text = ammo[indexPath.row].name
            if ammo[indexPath.row].isBattery {
                cell.detailTextLabel?.text = "\(ammo[indexPath.row].current)/\(ammo[indexPath.row].capacity)"
            } else {
                cell.detailTextLabel?.text = "\(ammo[indexPath.row].current)"
            }
            cell.contentView.backgroundColor = palette.bg
            cell.textLabel?.textColor = palette.text
            cell.detailTextLabel?.textColor = palette.text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unload", for: indexPath)
            cell.contentView.backgroundColor = palette.bg
            cell.textLabel?.text = "Unload"
            cell.textLabel?.textColor = palette.text
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= ammo.count - 1{
            selectedAmmo = ammo[indexPath.row]
            unload = false
        } else {
            unload = true
        }
        
    }
    
    
    
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
