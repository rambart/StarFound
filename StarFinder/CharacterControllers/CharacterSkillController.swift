//
//  CharacterSkillController.swift
//  StarFinder
//
//  Created by Tom on 4/14/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterSkillController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var skillNameTitle: UILabel!
    @IBOutlet weak var csLabel: UILabel!
    @IBOutlet weak var trainedLabel: UILabel!
    
    @IBOutlet weak var skillsTableView: UITableView!
    @IBOutlet weak var spacerHeight: NSLayoutConstraint!
    
    //MARK: - Attributes
    var PC = PlayerCharacter()
    var skills = [Skill]()
    var bonuses = [Bonus]()
    var armorCheckPenalty = 0
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    //MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            spacerHeight.constant = 0
        }
        
        skillsTableView.delegate = self
        skillsTableView.dataSource = self
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        for armor in PC.ownsArmor?.array as! [Armor] {
            if armor.equiped {
                armorCheckPenalty = Int(armor.checkPenalty)
            }
        }
        
        skills = PC.skills?.allObjects as! [Skill]
        skills = skills.sorted { $0.name! < $1.name! }
        
        if skillsTableView != nil {
            skillsTableView.reloadData()
        }
    }
    
    func updatePalette() {
        view.backgroundColor = palette.bg
        skillsTableView.backgroundColor = palette.bg
        skillsTableView.separatorColor = palette.main
        skillNameTitle.textColor = palette.text
        csLabel.textColor = palette.text
        trainedLabel.textColor = palette.text
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterSkillCell", for: indexPath) as! CharacterSkillCell
        let skill = skills[indexPath.row]
        cell.skillNameLabel.text = skill.name
        if skill.classSkill {
            cell.classSkillLabel.text = "✦"
        } else {
            cell.classSkillLabel.text = "✧"
        }
        if skill.ranks > 0 {
            cell.trainedLabel.text = "●"
        } else {
            cell.trainedLabel.text = "○"
        }
        var rollBonus: Int = Int(skill.ranks) + bonus(to: skill.name!, forPC: PC) + bonus(to: "Skills", forPC: PC)
        switch skill.ability?.lowercased() {
        case "str"?:
            rollBonus += mod(of: "strength", forPC: PC)
            cell.abilityLabel.text = "STR"
        case "dex"?:
            rollBonus += mod(of: "dexterity", forPC: PC)
            cell.abilityLabel.text = "DEX"
        case "int"?:
            rollBonus += mod(of: "intelligence", forPC: PC)
            cell.abilityLabel.text = "INT"
        case "wis"?:
            rollBonus += mod(of: "wisdom", forPC: PC)
            cell.abilityLabel.text = "WIS"
        case "cha"?:
            rollBonus += mod(of: "charisma", forPC: PC)
            cell.abilityLabel.text = "CHA"
        default:
            break
        }
        if skill.classSkill && skill.ranks > 0 {
            rollBonus += 3
        }
        if skill.armorCheck {
            rollBonus += armorCheckPenalty
        }
        cell.rollBonusLabel.text = cleanPossNeg(of: rollBonus)
        
        cell.contentView.backgroundColor = palette.bg
        cell.rollBonusLabel.backgroundColor = palette.button
        cell.rollBonusLabel.textColor = palette.text
        cell.skillNameLabel.textColor = palette.text
        cell.classSkillLabel.textColor = palette.main
        cell.trainedLabel.textColor = palette.main
        cell.abilityLabel.textColor = palette.main
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! CharacterSkillCell
        let rvc = self.storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        rvc.expression = "1d20+" + (selectedCell.rollBonusLabel.text!).replacingOccurrences(of: "+", with: "")
        rvc.PC = PC
        rvc.rollName = selectedCell.skillNameLabel.text!
        present(rvc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class CharacterSkillCell: UITableViewCell {
    
    @IBOutlet weak var rollBonusLabel: UILabel!
    @IBOutlet weak var skillNameLabel: UILabel!
    @IBOutlet weak var classSkillLabel: UILabel!
    @IBOutlet weak var trainedLabel: UILabel!
    @IBOutlet weak var abilityLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
