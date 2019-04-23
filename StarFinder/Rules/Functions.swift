//
//  RollLogic.swift
//  StarFinder
//
//  Created by Tom on 4/5/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import Foundation
import GameplayKit
import os.signpost
import UIKit

class Palette {
    var main: UIColor
    var bg: UIColor
    var button: UIColor
    var text: UIColor
    var alt: UIColor
    
    init(_ paletteName: String) {
        main = UIColor(named: "\(paletteName)Main")!
        bg = UIColor(named: "\(paletteName)BG")!
        switch paletteName {
        case "Space", "Fire", "Hazard", "Void":
            button = UIColor.darkGray
            text = UIColor.white
            alt = UIColor.black
        default:
            button = UIColor.lightGray
            text = UIColor.black
            alt = UIColor.white
        }
    }
    
    
}


/*
extension UIApplication {
    public var isSplitOrSlideOver: Bool {
        guard let w = self.delegate?.window, let window = w else { return false }
        return !window.frame.equalTo(window.screen.bounds)
    }
    public var splitStyle: CGFloat {
        guard let w = self.delegate?.window, let window = w else { return 0 }
        switch window.frame.width / window.screen.bounds.width {
        case 0.0...0.35:
            return CGFloat(1) / CGFloat(3)
        case 0.35...0.55:
            return CGFloat(1) / CGFloat(2)
        case 0.55...0.85:
            return CGFloat(2) / CGFloat(3)
        default:
            return 1
        }
    }
}
*/


extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = shouldBeArchived
        newConstraint.identifier = identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

extension NSMutableAttributedString {
    @discardableResult func shadowTitle(_ text: String) -> NSMutableAttributedString {
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 2
        myShadow.shadowOffset = CGSize(width: 1, height: 1)
        myShadow.shadowColor = UIColor.black
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial-BoldMT", size: 24)!, .foregroundColor: UIColor.white, .shadow: myShadow]
        let shdwString = NSMutableAttributedString(string:text, attributes: attrs)
        append(shdwString)
        
        return self
    }
    
    @discardableResult func shadowSub(_ text: String) -> NSMutableAttributedString {
        let myShadow = NSShadow()
        myShadow.shadowBlurRadius = 2
        myShadow.shadowOffset = CGSize(width: 1, height: 1)
        myShadow.shadowColor = UIColor.black
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial-BoldMT", size: 17)!, .foregroundColor: UIColor.white, .shadow: myShadow]
        let shdwString = NSMutableAttributedString(string:text, attributes: attrs)
        append(shdwString)
        
        return self
    }
    
    @discardableResult func h1(_ text: String) -> NSMutableAttributedString {
        let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica-Bold", size: 22)!, .foregroundColor: palette.main]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func physicalDamage(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor.lightGray]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func acid(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor(red:0.36, green:0.85, blue:0.07, alpha:1.0)]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func cold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor(red:0.52, green:0.95, blue:1.00, alpha:1.0)]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func electric(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor(red:0.99, green:1.00, blue:0.39, alpha:1.0)]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func fire(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor(red:0.99, green:0.40, blue:0.32, alpha:1.0)]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func sonic(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "KGCountingStars", size: 19)!, .foregroundColor: UIColor(red:0.77, green:0.32, blue:0.99, alpha:1.0)]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    
    @discardableResult func damageNormal(_ text: String) -> NSMutableAttributedString {
        let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica", size: 17)!, .foregroundColor: palette.text]
        let circleString = NSMutableAttributedString(string:text, attributes: attrs)
        append(circleString)
        
        return self
    }
    
    @discardableResult func bold(_ text: String, editor: Bool = false) -> NSMutableAttributedString {
        var color = UIColor.black
        if !editor {
            color = Palette(UserDefaults.standard.value(forKey: "palette") as! String).text
        }
        
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica-Bold", size: 17)!, .foregroundColor: color]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String, editor: Bool = false) -> NSMutableAttributedString {
        var color = UIColor.black
        if !editor {
            color = Palette(UserDefaults.standard.value(forKey: "palette") as! String).text
        }
        let normalString = NSAttributedString(string: text, attributes: [.foregroundColor: color])
        append(normalString)
        
        return self
    }
}

func roll(x: Int, d: Int) -> (result: Int, rolls: [Int]) {
    var total: Int = 0
    var rolls = [Int]()
    let dice = GKRandomDistribution(lowestValue: 1, highestValue: d)
    for _ in 1...x {
        let rollResult = dice.nextInt()
        total += rollResult
        rolls.append(rollResult)
    }
    return (total, rolls)
}

func roll(from: String, forPC: PlayerCharacter) -> (result: Int, dice: [Int]) {
    var result = 0
    var dice = [Int]()
    var bab = 0
    var levels = 0
    for lvl in forPC.classLevels?.array as! [Level] {
        bab += Int(lvl.bab)
        levels += Int(lvl.levels)
    }
    let replaceExpression = from.lowercased()
        .replacingOccurrences(of: "bab", with: "\(bab)")
        .replacingOccurrences(of: "lvl", with: "\(levels)")
        .replacingOccurrences(of: "str", with: "\(mod(of: "strength", forPC: forPC))")
        .replacingOccurrences(of: "dex", with: "\(mod(of: "dexterity", forPC: forPC))")
        .replacingOccurrences(of: "con", with: "\(mod(of: "constitution", forPC: forPC))")
        .replacingOccurrences(of: "int", with: "\(mod(of: "intelligence", forPC: forPC))")
        .replacingOccurrences(of: "wis", with: "\(mod(of: "wisdom", forPC: forPC))")
        .replacingOccurrences(of: "cha", with: "\(mod(of: "charisma", forPC: forPC))")
        .replacingOccurrences(of: "-", with: "+-")
    let diceExpression = replaceExpression.components(separatedBy: "+")
    for segment in diceExpression {
        var diceParser = segment.components(separatedBy: "d")
        if diceParser.count == 2 {
            if diceParser[0] == "" {
                diceParser[0] = "1"
            }
            let dieRolls = roll(x: Int(diceParser[0]) ?? 0, d: Int(diceParser[1]) ?? 0)
            result += dieRolls.result
            for rolls in dieRolls.rolls {
                dice.append(rolls)
            }
        } else {
            result += Int(diceParser[0]) ?? 0
        }
    }
    return (result, dice)
}

/*
func roll(from: String) -> Int {
    var result = 0
    let diceExpression = from.components(separatedBy: "+")
    for segment in diceExpression {
        var diceParser = segment.components(separatedBy: "d")
        if diceParser.count == 2 {
            result += roll(x: Int(diceParser[0])!, d: Int(diceParser[1])!)
        } else {
            result += Int(diceParser[0])!
        }
    }
    return result
}
*/

func rollMin(from: String, forPC: PlayerCharacter)  -> Int {
    var result = 0
    var bab = 0
    var levels = 0
    for lvl in forPC.classLevels?.array as! [Level] {
        bab += Int(lvl.bab)
        levels += Int(lvl.levels)
    }
    let replaceExpression = from.lowercased()
        .replacingOccurrences(of: "bab", with: "\(bab)")
        .replacingOccurrences(of: "lvl", with: "\(levels)")
        .replacingOccurrences(of: "str", with: "\(mod(of: "strength", forPC: forPC))")
        .replacingOccurrences(of: "dex", with: "\(mod(of: "dexterity", forPC: forPC))")
        .replacingOccurrences(of: "con", with: "\(mod(of: "constitution", forPC: forPC))")
        .replacingOccurrences(of: "int", with: "\(mod(of: "intelligence", forPC: forPC))")
        .replacingOccurrences(of: "wis", with: "\(mod(of: "wisdom", forPC: forPC))")
        .replacingOccurrences(of: "cha", with: "\(mod(of: "charisma", forPC: forPC))")
        .replacingOccurrences(of: "-", with: "+-")
    let diceExpression = replaceExpression.components(separatedBy: "+")
    for segment in diceExpression {
        var diceParser = segment.components(separatedBy: "d")
        result += Int(diceParser[0]) ?? 0
    }
    return result
}

func rollMax(from: String, forPC: PlayerCharacter) -> Int {
    var result = 0
    var bab = 0
    var levels = 0
    for lvl in forPC.classLevels?.array as! [Level] {
        bab += Int(lvl.bab)
        levels += Int(lvl.levels)
    }
    let replaceExpression = from.lowercased()
        .replacingOccurrences(of: "bab", with: "\(bab)")
        .replacingOccurrences(of: "lvl", with: "\(levels)")
        .replacingOccurrences(of: "str", with: "\(mod(of: "strength", forPC: forPC))")
        .replacingOccurrences(of: "dex", with: "\(mod(of: "dexterity", forPC: forPC))")
        .replacingOccurrences(of: "con", with: "\(mod(of: "constitution", forPC: forPC))")
        .replacingOccurrences(of: "int", with: "\(mod(of: "intelligence", forPC: forPC))")
        .replacingOccurrences(of: "wis", with: "\(mod(of: "wisdom", forPC: forPC))")
        .replacingOccurrences(of: "cha", with: "\(mod(of: "charisma", forPC: forPC))")
        .replacingOccurrences(of: "-", with: "+-")
    let diceExpression = replaceExpression.components(separatedBy: "+")
    for segment in diceExpression {
        var diceParser = segment.components(separatedBy: "d")
        if diceParser.count == 2 {
            result += ((Int(diceParser[0]) ?? 0)*(Int(diceParser[1]) ?? 0))
        } else {
            result += Int(diceParser[0]) ?? 0
        }
    }
    return result
}


func mod(of: String, forPC: PlayerCharacter) -> Int {
    var abilityScore: Int = 0
    var bonuses: Int = 0
    switch of.lowercased() {
    case "strength":
        abilityScore = Int(forPC.strength)
        bonuses = Int(bonus(to: "strength", forPC: forPC))
    case "dexterity":
        abilityScore = Int(forPC.dexterity)
        bonuses = Int(bonus(to: "dexterity", forPC: forPC))
    case "constitution":
        abilityScore = Int(forPC.constitution)
        bonuses = Int(bonus(to: "constitution", forPC: forPC))
    case "intelligence":
        abilityScore = Int(forPC.intelligence)
        bonuses = Int(bonus(to: "intelligence", forPC: forPC))
    case "wisdom":
        abilityScore = Int(forPC.wisdom)
        bonuses = Int(bonus(to: "wisdom", forPC: forPC))
    case "charisma":
        abilityScore = Int(forPC.charisma)
        bonuses = Int(bonus(to: "charisma", forPC: forPC))
    default:
        break
    }
    
    let result = ((abilityScore + bonuses) / 2) - 5
    
    return result
}


/*
func fetchBonuses(PC: PlayerCharacter) -> Array<Bonus> {
    var allBonuses = [Bonus]()
    
    if let condBonuses = PC.conditionalBonus {
        for bonus in condBonuses {
            allBonuses.append(bonus as! Bonus)
        }
    }
    
    if let ownedObject = PC.ownsArmor {
        for objectAny in ownedObject{
            let object = objectAny as! Armor
            if object.equiped {
                if let objectBonus = object.armorBonus {
                    for bonus in objectBonus {
                        allBonuses.append(bonus as! Bonus)
                    }
                }
            }
        }
    }
    
    if let ownedObject = PC.ownsWeapon {
        for objectAny in ownedObject{
            let object = objectAny as! Weapon
            if object.equiped {
                if let objectBonus = object.weaponBonus {
                    for bonus in objectBonus {
                        allBonuses.append(bonus as! Bonus)
                    }
                }
            }
        }
    }
    
    if let ownedObject = PC.ownsItem {
        for objectAny in ownedObject{
            let object = objectAny as! Item
            if object.equiped {
                if let objectBonus = object.itemBonus {
                    for bonus in objectBonus {
                        allBonuses.append(bonus as! Bonus)
                    }
                }
            }
        }
    }
    
    if let raceFeatures = PC.race?.racialFeature {
        for featureAny in raceFeatures {
            let feature = featureAny as! Feature
            if let featureBonus = feature.featureBonus {
                for bonus in featureBonus {
                    allBonuses.append(bonus as! Bonus)
                }
            }
        }
    }
    
    if let raceBonus = PC.race?.racialBonus {
        for bonus in raceBonus {
            allBonuses.append(bonus as! Bonus)
        }
    }
    
    if let themeFeatures = PC.theme?.themeFeature {
        for featureAny in themeFeatures {
            let feature = featureAny as! Feature
            if let featureBonus = feature.featureBonus {
                for bonus in featureBonus {
                    allBonuses.append(bonus as! Bonus)
                }
            }
        }
    }
    
    if let themeBonus = PC.theme?.themeBonus {
        for bonus in themeBonus {
            allBonuses.append(bonus as! Bonus)
        }
    }
    
    if let classLevels = PC.classLevels {
        for classLevelAny in classLevels {
            let classLevel = classLevelAny as! Level
            if let levelFeatures = classLevel.classFeature {
                for featuresAny in levelFeatures {
                    let features = featuresAny as! Feature
                    if let featureBonuses = features.featureBonus {
                        for bonus in featureBonuses {
                            allBonuses.append(bonus as! Bonus)
                        }
                    }
                }
            }
        }
    }
    
    if let feats = PC.feats {
        for featuresAny in feats {
            let features = featuresAny as! Feature
            if let featureBonuses = features.featureBonus {
                for bonus in featureBonuses {
                    allBonuses.append(bonus as! Bonus)
                }
            }
        }
    }
    
    return allBonuses
}
*/


func fetchBonuses(PC: PlayerCharacter) -> [Bonus] {
    var appWideBonuses = [Bonus]()
    do {
        try appWideBonuses = context.fetch(Bonus.fetchRequest())
    } catch {
        print("Did not fetch")
    }
    
    var playerBonuses = [Bonus]()
    for bonus in appWideBonuses {
        if (bonus.conditionalBonus == PC
            || (bonus.armorBonus?.ownsArmor == PC && (bonus.armorBonus?.equiped) ?? false)
            || (bonus.weaponBonus?.ownsWeapon == PC && (bonus.weaponBonus?.equiped) ?? false)
            || (bonus.itemBonus?.ownsItem == PC && (bonus.itemBonus?.equiped) ?? false)
            || bonus.racialBonus?.pc == PC
            || bonus.forTheme?.pc == PC
            || bonus.featureBonus?.classFeature?.classLevels == PC
            || bonus.featureBonus?.feats == PC
            || bonus.featureBonus?.forTheme?.pc == PC
            || bonus.featureBonus?.racialFeatures?.pc == PC) && bonus.enabled {
            playerBonuses.append(bonus)
        }
    }
    return playerBonuses
}


func fetchBonuses(PC: PlayerCharacter, weapon: Weapon) -> [Bonus] {
    var appWideBonuses = [Bonus]()
    do {
        try appWideBonuses = context.fetch(Bonus.fetchRequest())
    } catch {
        print("Did not fetch")
    }
    
    var playerBonuses = [Bonus]()
    for bonus in appWideBonuses {
        if (bonus.conditionalBonus == PC
            || (bonus.armorBonus?.ownsArmor == PC && (bonus.armorBonus?.equiped) ?? false)
            || bonus.weaponBonus == weapon
            || (bonus.itemBonus?.ownsItem == PC && (bonus.itemBonus?.equiped) ?? false)
            || bonus.racialBonus?.pc == PC
            || bonus.forTheme?.pc == PC
            || bonus.featureBonus?.classFeature?.classLevels == PC
            || bonus.featureBonus?.feats == PC
            || bonus.featureBonus?.forTheme?.pc == PC
            || bonus.featureBonus?.racialFeatures?.pc == PC) && bonus.enabled {
            playerBonuses.append(bonus)
        }
    }
    return playerBonuses
}


func fetchBonusesAlt(PC: PlayerCharacter) -> [Bonus] {
    var allBonuses = [Bonus]()
    
    for bonus in PC.conditionalBonus?.array as! [Bonus] {
        allBonuses.append(bonus)
    }
    
    if let racialBonuses = PC.race?.racialBonus {
        for bonus in racialBonuses.array as! [Bonus] {
            allBonuses.append(bonus)
        }
    }
    
    if let racialFeatures = PC.race?.racialFeature {
        for feat in racialFeatures.array as! [Feature] {
            for bonus in feat.featureBonus?.array as! [Bonus] {
                allBonuses.append(bonus)
            }
        }
    }
    
    if let themeBonuses = PC.theme?.themeBonus {
        for bonus in themeBonuses.array as! [Bonus] {
            allBonuses.append(bonus)
        }
    }
    
    if let themeFeatures = PC.theme?.themeFeature {
        for feat in themeFeatures.array as! [Feature] {
            for bonus in feat.featureBonus?.array as! [Bonus] {
                allBonuses.append(bonus)
            }
        }
    }
    
    if let items = PC.ownsItem {
        for item in items.array as! [Item] {
            if item.equiped {
                for bonus in item.itemBonus?.array as! [Bonus] {
                    allBonuses.append(bonus)
                }
            }
        }
    }
    
    if let armor = PC.ownsArmor {
        for item in armor.array as! [Armor] {
            if item.equiped {
                for bonus in item.armorBonus?.array as! [Bonus] {
                    allBonuses.append(bonus)
                }
            }
        }
    }
    
    if let weapon = PC.ownsWeapon {
        for item in weapon.array as! [Weapon] {
            if item.equiped {
                for bonus in item.weaponBonus?.array as! [Bonus] {
                    allBonuses.append(bonus)
                }
            }
        }
    }
    
    if let feats = PC.feats {
        for feat in feats.array as! [Feature] {
            for bonus in feat.featureBonus?.array as! [Bonus] {
                allBonuses.append(bonus)
            }
        }
    }
    
    if let levels = PC.classLevels {
        for level in levels.array as! [Level] {
            for feat in level.classFeature?.array as! [Feature] {
                for bonus in feat.featureBonus?.array as! [Bonus] {
                    allBonuses.append(bonus)
                }
            }
        }
    }
    
    
    return allBonuses
}
 
 
func bonus(to: String, forPC: PlayerCharacter, weapon: Weapon? = nil) -> Int {
    var bonuses = [Bonus]()
    if let weap = weapon {
        bonuses =  fetchBonuses(PC: forPC, weapon: weap)
    } else {
        bonuses =  fetchBonuses(PC: forPC)
    }
    var bonusValue: Int = 0
    for bonus in bonuses {
        if bonus.type?.lowercased() == to.lowercased() && bonus.enabled {
            bonusValue += Int(bonus.bonus)
        }
    }
    return bonusValue
}

func cleanPossNeg(of: Int) -> String {
    if of >= 0 {
        return "+\(of)"
    } else {
        return "\(of)"
    }
}

func maxStamina(forPC: PlayerCharacter) -> Int {
    var result = 0
    if forPC.classLevels != nil {
        for levelAny in forPC.classLevels! {
            let level = levelAny as! Level
            let staminaPerLevel = mod(of: "constitution", forPC: forPC) + Int(level.stamina)
            result += (staminaPerLevel * Int(level.levels))
        }
        result += bonus(to: "stamina", forPC: forPC)
        return result
    } else {
        return mod(of: "constitution", forPC: forPC)
    }
}

func maxHP(forPC: PlayerCharacter) -> Int {
    var result = 0
    if forPC.classLevels != nil {
        for levelAny in forPC.classLevels! {
            let level = levelAny as! Level
            result += (Int(level.hitPoints) * Int(level.levels))
        }
        result += bonus(to: "hit points", forPC: forPC)
        return result
    } else {
     return 0
    }
}

func simplifyNonVariables(forPC: PlayerCharacter, input: String) -> String {
    var dice = [String]()
    var runningBonus = 0
    for seg in (input.replacingOccurrences(of: "-", with: "+-")).components(separatedBy: "+") {
        switch seg.lowercased() {
        case "str":
            runningBonus += mod(of: "strength", forPC: forPC)
        case "dex":
            runningBonus += mod(of: "dexterity", forPC: forPC)
        case "con":
            runningBonus += mod(of: "constitution", forPC: forPC)
        case "int":
            runningBonus += mod(of: "intelligence", forPC: forPC)
        case "wis":
            runningBonus += mod(of: "wisdom", forPC: forPC)
        case "cha":
            runningBonus += mod(of: "charisma", forPC: forPC)
        default:
            if seg.contains("d") {
                dice.append(seg)
            } else {
                runningBonus += Int(seg) ?? 0
            }
        }
    }
    var returnString = String()
    for die in dice {
        returnString.append("+" + die)
    }
    if runningBonus != 0 {
        returnString.append(cleanPossNeg(of: runningBonus))
    }
    return String(returnString.dropFirst())
}

func maxResolve(forPC: PlayerCharacter) -> Int {
    var characterLevel = 0
    var abilityMod = 0
    switch forPC.resolveAbility?.lowercased() {
    case "strength"?:
        abilityMod = mod(of: "strength", forPC: forPC)
    case "dexterity"?:
        abilityMod = mod(of: "dexterity", forPC: forPC)
    case "constitution"?:
        abilityMod = mod(of: "constitution", forPC: forPC)
    case "intelligence"?:
        abilityMod = mod(of: "intelligence", forPC: forPC)
    case "wisdom"?:
        abilityMod = mod(of: "wisdom", forPC: forPC)
    case "charisma"?:
        abilityMod = mod(of: "charisma", forPC: forPC)
    default:
        abilityMod = 0
    }
    if forPC.classLevels != nil {
        for levelAny in forPC.classLevels! {
            let level = levelAny as! Level
            characterLevel += Int(level.levels)
        }
    }
    if characterLevel < 2 {
        characterLevel = 2
    }
    var result = (characterLevel / 2) + abilityMod
    result += bonus(to: "resolve", forPC: forPC)
    return result
}

func levelUp(_ classLevel: Level, forPC: PlayerCharacter) {
    if classLevel.levels >= 20 {
        return
    }
    if classLevel.compendiumClass == nil || classLevel.compendiumClass == "" {
        classLevel.levels += 1
    } else {
        let updatedLevel = classLevel
        updatedLevel.levels += 1
        // Mark: - Pull out the level to copy
        var compendium = [CompendiumClass]()
        do {
            try compendium = context.fetch(CompendiumClass.fetchRequest())
        } catch {
            print("Did not fetch")
        }
        var compClass = CompendiumClass()
        for cl in compendium {
            if cl.name == classLevel.compendiumClass {
                print("Class Match")
                compClass = cl
            }
        }
        var levelToCopy = CompendiumLevel()
        for compLvl in compClass.classLevel?.allObjects as! [CompendiumLevel] {
            if compLvl.level == updatedLevel.levels {
                print("found level \(compLvl.level)")
                levelToCopy = compLvl
            }
        }
        
        // Mark: - Assign compendium values to PC's Level
        updatedLevel.bab = levelToCopy.bab
        updatedLevel.fortitude = levelToCopy.fort
        updatedLevel.reflex = levelToCopy.ref
        updatedLevel.will = levelToCopy.will
        
        // Mark: - Update spell slots
        if (levelToCopy.compendiumClassSlots?.array as! [SpellSlot]).count >= 6 {
            if updatedLevel.classSlots?.count ?? 0 != 6 {
                for slot in updatedLevel.classSlots?.array as! [SpellSlot] {
                    context.delete(slot)
                }
                for _ in 0...5 {
                    let newSlot = SpellSlot(context: context)
                    newSlot.slots = 0
                    newSlot.used = 0
                    updatedLevel.addToClassSlots(newSlot)
                }
            }
            for i in 0...5 {
                (updatedLevel.classSlots?.array as! [SpellSlot])[i].slots = (levelToCopy.compendiumClassSlots?.array as! [SpellSlot])[i].slots
            }
        }
        
        // Mark: - Add new Class Features
        for classFeature in levelToCopy.compendiumClassFeature?.array as! [Feature] {
            let newFeature = Feature(context: context)
            newFeature.name = classFeature.name
            newFeature.content = classFeature.content
            if classFeature.featureOptions != nil {
                for opt in classFeature.featureOptions?.array as! [Option] {
                    let newOpt = Option(context: context)
                    newOpt.name = opt.name
                    newOpt.content = opt.content
                    newFeature.addToFeatureOptions(newOpt)
                }
            }
            if classFeature.featureBonus != nil {
                for bon in classFeature.featureBonus?.array as! [Bonus] {
                    let newBon = Bonus(context: context)
                    newBon.type = bon.type
                    newBon.bonus = bon.bonus
                    newBon.enabled = true
                    newFeature.addToFeatureBonus(newBon)
                }
            }
            updatedLevel.addToClassFeature(newFeature)
        }
    }
}

func characterLevel(forPC: PlayerCharacter) -> Int {
    var totalLevel = 0
    for level in forPC.classLevels?.array as! [Level] {
        totalLevel += Int(level.levels)
    }
    return totalLevel
}

func bonusSpells(forPC: PlayerCharacter, basedOn: String) -> Array<Int> {
    let modifier = mod(of: basedOn, forPC: forPC)
    var levels = [0, 0, 0, 0, 0, 0]
    var ones = modifier
    var twos = modifier - 4
    var threes = modifier - 8
    for i in 0...5 {
        if ones > 0 {
            levels[i] += 1
            ones -= 1
        }
        if twos > 0 {
            levels[i] += 1
            twos -= 1
        }
        if threes > 0 {
            levels[i] += 1
            threes -= 1
        }
    }
    return levels
}

func saveBonus(to: String, forPC: PlayerCharacter) -> Int {
    var saveTotal = 0
    switch to.lowercased() {
    case "fort", "fortitude":
        saveTotal += mod(of: "Constitution", forPC: forPC)
        for level in forPC.classLevels?.array as! [Level] {
            saveTotal += Int(level.fortitude)
        }
    case "ref", "reflex":
        saveTotal += mod(of: "Dexterity", forPC: forPC)
        for level in forPC.classLevels?.array as! [Level] {
            saveTotal += Int(level.reflex)
        }
    case "will":
        saveTotal += mod(of: "Wisdom", forPC: forPC)
        for level in forPC.classLevels?.array as! [Level] {
            saveTotal += Int(level.will)
        }
    default:
        break
    }
    saveTotal += bonus(to: to, forPC: forPC)
    
    return saveTotal
}

extension PlayerCharacter {
    
    func isCaster() -> Bool {
        for level in self.classLevels?.array as! [Level] {
            if level.classSpells?.allObjects.count ?? 0 >= 1 {
                return true
            }
            for slot in level.classSlots?.array as! [SpellSlot] {
                if slot.slots >= 1 {
                    return true
                }
            }
        }
        return false
    }
    
}

extension PlayerCharacter {
    func export() -> URL? {
        
        var PCAttributes: [String : Any] = ["name": self.name ?? "",
                                            "alignment" : self.alignment ?? "",
                                            "charisma": self.charisma,
                                            "constitution": self.constitution,
                                            "credits": self.credits,
                                            "deity": self.deity ?? "",
                                            "dexterity": self.dexterity,
                                            "eyes": self.eyes ?? "",
                                            "gender": self.gender ?? "",
                                            "gravityModifier": self.gravityModifier,
                                            "hair" : self.hair ?? "",
                                            "height" : self.height ?? "",
                                            "homeworld" : self.homeworld ?? "",
                                            "hpCurrent" : self.hpCurrent,
                                            "intelligence" : self.intelligence,
                                            "order" : self.order,
                                            "resolveAbility" : self.resolveAbility ?? "",
                                            "resolveCurrent" : self.resolveCurrent,
                                            "size" : self.size ?? "",
                                            "speed" : self.speed,
                                            "staminaCurrent" : self.staminaCurrent,
                                            "strength" : self.strength,
                                            "weight" : self.weight  ?? "",
                                            "wisdom" : self.wisdom]
        if let race = self.race {
            let raceDict: Dictionary<String, Any> = ["name" : race.name ?? "",
                                                     "racialBonus" : bonusDict(race.racialBonus?.array as! [Bonus]),
                                                     "racialFeature" : featDict(race.racialFeature?.array as! [Feature])
            ]
            PCAttributes["race"] = raceDict
        }
        if let theme = self.theme {
            let themeDict: Dictionary<String, Any> = ["name": theme.name ?? "",
                                                      "themeBonus" : bonusDict(theme.themeBonus?.array as! [Bonus]),
                                                      "themeFeature" : featDict(theme.themeFeature?.array as! [Feature])
            ]
            PCAttributes["theme"] = themeDict
        }
        var levelsDict = Array<Dictionary<String, Any>>()
        for level in self.classLevels?.array as! [Level] {
            let levelDict: Dictionary<String, Any> = ["name" : level.name ?? "",
                                                      "bab" : level.bab,
                                                      "compendiumClass": level.compendiumClass ?? "",
                                                      "fortitude" : level.fortitude,
                                                      "hitPoints" : level.hitPoints,
                                                      "levels" : level.levels,
                                                      "reflex" : level.reflex,
                                                      "skillRanks" : level.skillRanks,
                                                      "spellcastingAbility" : level.spellcastingAbility ?? "",
                                                      "spellcastingType" : level.spellcastingType ?? "",
                                                      "stamina" : level.stamina,
                                                      "will" : level.will,
                                                      "classFeature" : featDict(level.classFeature?.array as! [Feature]),
                                                      "classSlots" : slotDict(level.classSlots?.array as! [SpellSlot]),
                                                      "classSpells" : spellDict(level.classSpells?.allObjects as! [Spell])
            ]
            levelsDict.append(levelDict)
        }
        PCAttributes["classLevels"] = levelsDict
        PCAttributes["skills"] = skillDict(self.skills?.allObjects as! [Skill])
        PCAttributes["feats"] = featDict(self.feats?.array as! [Feature])
        PCAttributes["conditionalBonus"] = bonusDict(self.conditionalBonus?.array as! [Bonus])
        PCAttributes["notes"] = noteDict(self.notes?.array as! [Note])
        PCAttributes["attack"] = attackDict(self.attack?.array as! [Attack])
        PCAttributes["trackers"] = trackerDict(self.trackers?.array as! [Tracker])
        PCAttributes["ownsArmor"] = armorDict(self.ownsArmor?.array as! [Armor])
        PCAttributes["ownsBattery"] = ammoDict(self.ownsBattery?.array as! [Ammo])
        PCAttributes["ownsWeapon"] = weaponDict(self.ownsWeapon?.array as! [Weapon])
        PCAttributes["ownsItem"] = itemDict(self.ownsItem?.array as! [Item])
        
        
        if self.portraitPath != nil {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(self.portraitPath!)
            if let image = UIImage(contentsOfFile: path.path) {
                if let data = image.jpegData(compressionQuality: 100) {
                    PCAttributes["portrait"] = data.base64EncodedString()
                }
            }
            
        }
        
        
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }
        
        let saveFileURL = path.appendingPathComponent("/\(name ?? "StarFoundCharacter").char")
        (PCAttributes as NSDictionary).write(to: saveFileURL, atomically: true)
        return saveFileURL
        
    }
    
}
    
func importPC(from url: URL, order: Int? = nil) {
    
    guard let dictionary = NSDictionary(contentsOf: url),
        let PCinfo = dictionary as? [String: AnyObject] else {return}
    
    let PC = PlayerCharacter(context: context)
    if order != nil {
        PC.order = Int16(order!)
    } else {
        PC.order = PCinfo["order"] as! Int16
    }
    
    
    PC.name = PCinfo["name"] as? String
    PC.alignment = PCinfo["alignment"] as? String
    PC.charisma = PCinfo["charisma"] as! Int16
    PC.constitution = PCinfo["constitution"] as! Int16
    PC.credits = PCinfo["credits"] as! Int64
    PC.deity = PCinfo["deity"] as? String
    PC.dexterity = PCinfo["dexterity"] as! Int16
    PC.eyes = PCinfo["eyes"] as? String
    PC.gender = PCinfo["gender"] as? String
    PC.gravityModifier = PCinfo["gravityModifier"] as! Float
    PC.hair = PCinfo["hair"] as? String
    PC.height = PCinfo["height"] as? String
    PC.homeworld = PCinfo["homeworld"] as? String
    PC.hpCurrent = PCinfo["hpCurrent"] as! Int16
    PC.intelligence = PCinfo["intelligence"] as! Int16
    PC.resolveAbility = PCinfo["resolveAbility"] as? String
    PC.resolveCurrent = PCinfo["resolveCurrent"] as! Int16
    PC.size = PCinfo["size"] as? String
    PC.speed = PCinfo["speed"] as! Int16
    PC.staminaCurrent = PCinfo["staminaCurrent"] as! Int16
    PC.strength = PCinfo["strength"] as! Int16
    PC.weight = PCinfo["weight"] as? String
    PC.wisdom = PCinfo["wisdom"] as! Int16
    
    let raceInfo = PCinfo["race"] as! Dictionary<String, Any>
    let race = Race(context: context)
    race.pc = PC
    race.name = raceInfo["name"] as? String
    let racialBonuses = raceInfo["racialBonus"] as! Array<Dictionary<String, Any>>
    race.racialBonus = unwrapBonus(racialBonuses)
    let racialFeatures = raceInfo["racialFeature"] as! Array<Dictionary<String, Any>>
    race.racialFeature = unwrapFeat(racialFeatures)
    
    let themeInfo = PCinfo["theme"] as! Dictionary<String, Any>
    let theme = Theme(context: context)
    theme.pc = PC
    theme.name = themeInfo["name"] as? String
    let themeBonuses = themeInfo["themeBonus"] as! Array<Dictionary<String, Any>>
    theme.themeBonus = unwrapBonus(themeBonuses)
    let themeFeatures = themeInfo["themeFeature"] as! Array<Dictionary<String, Any>>
    theme.themeFeature = unwrapFeat(themeFeatures)
    
    let levelsInfo = PCinfo["classLevels"] as! Array<Dictionary<String, Any>>
    for levelInfo in levelsInfo {
        let level = Level(context: context)
        level.classLevels = PC
        level.name = levelInfo["name"] as? String
        level.bab = levelInfo["bab"] as! Int16
        level.compendiumClass = levelInfo["compendiumClass"] as? String
        level.fortitude = levelInfo["fortitude"] as! Int16
        level.hitPoints = levelInfo["hitPoints"] as! Int16
        level.levels = levelInfo["levels"] as! Int16
        level.reflex = levelInfo["reflex"] as! Int16
        level.skillRanks = levelInfo["skillRanks"] as! Int16
        level.spellcastingAbility = levelInfo["spellcastingAbility"] as? String
        level.spellcastingType = levelInfo["spellcastingType"] as? String
        level.stamina = levelInfo["stamina"] as! Int16
        level.will = levelInfo["will"] as! Int16
        let classFeature = levelInfo["classFeature"] as! Array<Dictionary<String, Any>>
        level.classFeature = unwrapFeat(classFeature)
        let classSlots = levelInfo["classSlots"] as! Array<Dictionary<String, Any>>
        level.classSlots = unwrapSlot(classSlots)
        let classSpells = levelInfo["classSpells"] as! Array<Dictionary<String, Any>>
        level.classSpells = unwrapSpell(classSpells)
    }
    
    let skills = PCinfo["skills"] as! Array<Dictionary<String, Any>>
    PC.skills = unwrapSkill(skills)
    
    let feats = PCinfo["feats"] as! Array<Dictionary<String, Any>>
    PC.feats = unwrapFeat(feats)
    
    let conditionalBonus = PCinfo["conditionalBonus"] as! Array<Dictionary<String, Any>>
    PC.conditionalBonus = unwrapBonus(conditionalBonus)
    
    let notes = PCinfo["notes"] as! Array<Dictionary<String, Any>>
    PC.notes = unwrapNote(notes)
    
    let attack = PCinfo["attack"] as! Array<Dictionary<String, Any>>
    PC.attack = unwrapAttack(attack)
    
    let trackers = PCinfo["trackers"] as! Array<Dictionary<String, Any>>
    PC.trackers = unwrapTracker(trackers)
    
    let ownsArmor = PCinfo["ownsArmor"] as! Array<Dictionary<String, Any>>
    PC.ownsArmor = unwrapArmor(ownsArmor)
    
    let ownsBattery = PCinfo["ownsBattery"] as! Array<Dictionary<String, Any>>
    PC.ownsBattery = unwrapAmmo(ownsBattery)
    
    let ownsWeapon = PCinfo["ownsWeapon"] as! Array<Dictionary<String, Any>>
    PC.ownsWeapon = unwrapWeapon(ownsWeapon)
    
    let ownsItem = PCinfo["ownsItem"] as! Array<Dictionary<String, Any>>
    PC.ownsItem = unwrapItem(ownsItem)
    
    
    if let base64 = PCinfo["portrait"] as? String,
        let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters),
        let image = UIImage(data: imageData) {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let imageName = UUID().uuidString
        let imagePath = documentsDirectory.appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 100) {
            try? jpegData.write(to: imagePath)
        }
        
        PC.portraitPath = imageName
        
    }
}


    
func bonusDict(_ bonuses: [Bonus]) -> Array<Dictionary<String, Any>> {
    var bonusesDict = Array<Dictionary<String, Any>>()
    for bonus in bonuses {
        bonusesDict.append(["type" : bonus.type ?? "",
                            "bonus" : bonus.bonus,
                            "enabled" : bonus.enabled
                            ])
    }
    return bonusesDict
}

func unwrapBonus(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var bonuses = [Bonus]()
    for dict in dictionaries {
        let bonus = Bonus(context: context)
        bonus.bonus = dict["bonus"] as! Int16
        bonus.type = dict["type"] as? String
        bonus.enabled = dict["enabled"] as! Bool
        bonuses.append(bonus)
    }
    return NSOrderedSet.init(array: bonuses)
}

func optionDict(_ options: [Option]) -> Array<Dictionary<String, Any>> {
    var optionsDict = Array<Dictionary<String, Any>>()
    for option in options {
        optionsDict.append(["name" : option.name ?? "",
                            "content" : option.content ?? "",
                            "selected" : option.selected
                            ])
    }
    return optionsDict
}

func unwrapOption(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var options = [Option]()
    for dict in dictionaries {
        let opt = Option(context: context)
        opt.name = dict["name"] as? String
        opt.content = dict["content"] as? String
        opt.selected = dict["selected"] as! Bool
        options.append(opt)
    }
    return NSOrderedSet.init(array: options)
}

func featDict(_ feats: [Feature]) -> Array<Dictionary<String, Any>> {
    var featsDict = Array<Dictionary<String, Any>>()
    for feat in feats {
        featsDict.append(["name" : feat.name ?? "",
                          "content" : feat.content ?? "",
                          "featureBonus" : bonusDict(feat.featureBonus?.array as! [Bonus]),
                          "featureOptions" : optionDict(feat.featureOptions?.array as! [Option])
                            ])
    }
    return featsDict
}

func unwrapFeat(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var feats = [Feature]()
    for dict in dictionaries {
        let feat = Feature(context: context)
        feat.name = dict["name"] as? String
        feat.content = dict["content"] as? String
        let featBonuses = dict["featureBonus"] as! Array<Dictionary<String, Any>>
        feat.featureBonus = unwrapBonus(featBonuses)
        let featureOption = dict["featureOptions"] as! Array<Dictionary<String, Any>>
        feat.featureOptions = unwrapOption(featureOption)
        feats.append(feat)
    }
    return NSOrderedSet.init(array: feats)
}


func slotDict(_ slots: [SpellSlot]) -> Array<Dictionary<String, Any>> {
    var slotsDict = Array<Dictionary<String, Any>>()
    for slot in slots {
        slotsDict.append(["slots" : slot.slots,
                          "used" : slot.used
            ])
    }
    return slotsDict
}

func unwrapSlot(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var slots = [SpellSlot]()
    for dict in dictionaries {
        let slot = SpellSlot(context: context)
        slot.slots = dict["slots"] as! Int16
        slot.used = dict["used"] as! Int16
        slots.append(slot)
    }
    return NSOrderedSet.init(array: slots)
}

func spellDict(_ spells: [Spell]) -> Array<Dictionary<String, Any>> {
    var spellsDict = Array<Dictionary<String, Any>>()
    for spell in spells {
        var spellDict: Dictionary<String, Any> = ["name" : spell.name ?? "",
                         "level" : spell.level,
                         "type" : spell.type ?? "",
                         "content" : spell.content ?? ""
                         ]
        spellDict ["area"] = spell.area ?? ""
        spellDict ["castingTime"] = spell.castingTime ?? ""
        spellDict ["duration"] = spell.duration ?? ""
        spellDict ["effect"] = spell.effect ?? ""
        spellDict ["range"] = spell.range ?? ""
        spellDict ["savingThrow"] = spell.savingThrow ?? ""
        spellDict ["school"] = spell.school ?? ""
        spellDict ["spellResistance"] = spell.spellResistance ?? ""
        spellDict ["targets"] = spell.targets ?? ""
        spellsDict.append(spellDict)
    }
    return spellsDict
}

func unwrapSpell(_ dictionaries: Array<Dictionary<String, Any>>) -> NSSet {
    var spells = [Spell]()
    for dict in dictionaries {
        let spell = Spell(context: context)
        spell.name = dict["name"] as? String
        spell.level = dict["level"] as! Int16
        spell.type = dict["type"] as? String
        spell.content = dict["content"] as? String
        spell.area = dict["area"] as? String
        spell.castingTime = dict["castingTime"] as? String
        spell.duration = dict["duration"] as? String
        spell.effect = dict["effect"] as? String
        spell.range = dict["range"] as? String
        spell.savingThrow = dict["savingThrow"] as? String
        spell.school = dict["school"] as? String
        spell.spellResistance = dict["spellResistance"] as? String
        spell.targets = dict["tagets"] as? String

        spells.append(spell)
    }
    return NSSet.init(array: spells)
}

func skillDict(_ skills: [Skill]) -> Array<Dictionary<String, Any>> {
    var skillsDict = Array<Dictionary<String, Any>>()
    for skill in skills {
        skillsDict.append(["name" : skill.name ?? "",
                          "ability" : skill.ability ?? "",
                          "armorCheck" : skill.armorCheck,
                          "classSkill" : skill.classSkill,
                          "ranks" : skill.ranks
            ])
    }
    return skillsDict
}

func unwrapSkill(_ dictionaries: Array<Dictionary<String, Any>>) -> NSSet {
    var skills = [Skill]()
    for dict in dictionaries {
        let skill = Skill(context: context)
        skill.name = dict["name"] as? String
        skill.ability = dict["ability"] as? String
        skill.armorCheck = dict["armorCheck"] as! Bool
        skill.classSkill = dict["classSkill"] as! Bool
        skill.ranks = dict["ranks"] as! Int16
        skills.append(skill)
    }
    return NSSet.init(array: skills)
}

func attackDict(_ attacks: [Attack]) -> Array<Dictionary<String, Any>> {
    var attacksDict = Array<Dictionary<String, Any>>()
    for attack in attacks {
        attacksDict.append(["name" : attack.name ?? "",
                            "capacity" : attack.capacity,
                            "charges" : attack.charges,
                            "critical" : attack.critical ?? "",
                            "damage" : attack.damage ?? "",
                            "damageType" : attack.damageType ?? "",
                            "roll" : attack.roll ?? "",
                            "usage" : attack.usage
            ])
    }
    return attacksDict
}

func unwrapAttack(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var attacks = [Attack]()
    for dict in dictionaries {
        let attack = Attack(context: context)
        attack.name = dict["name"] as? String
        attack.capacity = dict["capacity"] as! Int16
        attack.charges = dict["charges"] as! Int16
        attack.critical = dict["critical"] as? String
        attack.damage = dict["damage"] as? String
        attack.damageType = dict["damageType"] as? String
        attack.roll = dict["roll"] as? String
        attack.usage = dict["usage"] as! Int16
        
        attacks.append(attack)
    }
    return NSOrderedSet.init(array: attacks)
}

func noteDict(_ notes: [Note]) -> Array<Dictionary<String, Any>> {
    var notesDict = Array<Dictionary<String, Any>>()
    for note in notes {
        notesDict.append(["name" : note.name ?? "",
                          "content" : note.content ?? ""
            ])
    }
    return notesDict
}

func unwrapNote(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var notes = [Note]()
    for dict in dictionaries {
        let note = Note(context: context)
        note.name = dict["name"] as? String
        note.content = dict["content"] as? String
        notes.append(note)
    }
    return NSOrderedSet.init(array: notes)
}

func trackerDict(_ trackers: [Tracker]) -> Array<Dictionary<String, Any>> {
    var trackersDict = Array<Dictionary<String, Any>>()
    for tracker in trackers {
        trackersDict.append(["name" : tracker.name ?? "",
                          "doesReset" : tracker.doesReset,
                          "reset" : tracker.reset,
                          "value" : tracker.value
                          ])
    }
    return trackersDict
}

func unwrapTracker(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var trackers = [Tracker]()
    for dict in dictionaries {
        let tracker = Tracker(context: context)
        tracker.name = dict["name"] as? String
        tracker.doesReset = dict["doesReset"] as! Bool
        tracker.reset = dict["reset"] as! Int64
        tracker.value = dict["value"] as! Int64
        trackers.append(tracker)
    }
    return NSOrderedSet.init(array: trackers)
}

func armorDict(_ armors: [Armor]) -> Array<Dictionary<String, Any>> {
    var armorsDict = Array<Dictionary<String, Any>>()
    for armor in armors {
        armorsDict.append(["name" : armor.name ?? "",
                           "bulk" : armor.bulk,
                           "capacity" : armor.capacity,
                           "charges" : armor.charges,
                           "checkPenalty" : armor.checkPenalty,
                           "content" : armor.content ?? "",
                           "equiped" : armor.equiped,
                           "level" : armor.level,
                           "maxDexBonus" : armor.maxDexBonus,
                           "price" : armor.price,
                           "quantity" : armor.quantity,
                           "type" : armor.type ?? "",
                           "upgradeSlots" : armor.upgradeSlots,
                           "usage" : armor.usage,
                           "armorBonus" : bonusDict(armor.armorBonus?.array as! [Bonus]),
                           "armorFusion" : fusionDict(armor.armorFusion?.array as! [Fusion])
            ])
    }
    return armorsDict
}

func unwrapArmor(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var armors = [Armor]()
    for dict in dictionaries {
        let armor = Armor(context: context)
        armor.name = dict["name"] as? String
        armor.bulk = dict["bulk"] as! Float
        armor.capacity = dict["capacity"] as! Int16
        armor.type = dict["type"] as? String
        armor.charges = dict["charges"] as! Int16
        armor.checkPenalty = dict["checkPenalty"] as! Int16
        armor.content = dict["content"] as? String
        armor.equiped = dict["equiped"] as! Bool
        armor.level = dict["level"] as! Int16
        armor.maxDexBonus = dict["maxDexBonus"] as! Int16
        armor.price = dict["price"] as! Int64
        armor.quantity = dict["quantity"] as! Int64
        armor.upgradeSlots = dict["upgradeSlots"] as! Int16
        armor.usage = dict["usage"] as! Int16
        let armorBonuses = dict["armorBonus"] as! Array<Dictionary<String, Any>>
        armor.armorBonus = unwrapBonus(armorBonuses)
        let armorFusions = dict["armorFusion"] as! Array<Dictionary<String, Any>>
        armor.armorFusion = unwrapFusion(armorFusions)
        armors.append(armor)
    }
    return NSOrderedSet.init(array: armors)
}

func fusionDict(_ fusions: [Fusion]) -> Array<Dictionary<String, Any>> {
    var fusionsDict = Array<Dictionary<String, Any>>()
    for fusion in fusions {
        fusionsDict.append(["name" : fusion.name ?? "",
                          "content" : fusion.content ?? ""
                          ])
    }
    return fusionsDict
}

func unwrapFusion(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var fusions = [Fusion]()
    for dict in dictionaries {
        let fusion = Fusion(context: context)
        fusion.name = dict["name"] as? String
        fusion.content = dict["content"] as? String
        fusions.append(fusion)
    }
    return NSOrderedSet.init(array: fusions)
}

func ammoDict(_ ammos: [Ammo]) -> Array<Dictionary<String, Any>> {
    var ammosDict = Array<Dictionary<String, Any>>()
    for ammo in ammos {
        ammosDict.append(["name" : ammo.name ?? "",
                          "content" : ammo.content ?? "",
                          "bulk" : ammo.bulk,
                          "capacity" : ammo.capacity,
                          "current" : ammo.current,
                          "isBattery" : ammo.isBattery,
                          "level" : ammo.level,
                          "perUnits" : ammo.perUnits,
                          "price" : ammo.price,
                          "special" : ammo.special ?? ""
                            ])
    }
    return ammosDict
}

func unwrapAmmo(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var ammos = [Ammo]()
    for dict in dictionaries {
        let ammo = Ammo(context: context)
        ammo.name = dict["name"] as? String
        ammo.bulk = dict["bulk"] as! Float
        ammo.capacity = dict["capacity"] as! Int16
        ammo.current = dict["current"] as! Int16
        ammo.content = dict["content"] as? String
        ammo.isBattery = dict["isBattery"] as! Bool
        ammo.level = dict["level"] as! Int16
        ammo.price = dict["price"] as! Float
        ammo.perUnits = dict["perUnits"] as! Int16
        ammo.special = dict["special"] as? String
        ammos.append(ammo)
    }
    return NSOrderedSet.init(array: ammos)
}

func weaponDict(_ weapons: [Weapon]) -> Array<Dictionary<String, Any>> {
    var weaponsDict = Array<Dictionary<String, Any>>()
    for weapon in weapons {
        weaponsDict.append(["name" : weapon.name ?? "",
                            "capacity" : weapon.capacity,
                            "charges" : weapon.charges,
                            "critical" : weapon.critical ?? "",
                            "damage" : weapon.damage ?? "",
                            "damageType" : weapon.damageType ?? "",
                            "roll" : weapon.roll ?? "",
                            "usage" : weapon.usage,
                            "bulk" : weapon.bulk,
                            "equiped" : weapon.equiped,
                            "level" : weapon.level,
                            "price" : weapon.price,
                            "quantity" : weapon.quantity,
                            "range" : weapon.range,
                            "special" : weapon.special ?? "",
                            "type" : weapon.type ?? "",
                            "weaponBonus" : bonusDict(weapon.weaponBonus?.array as! [Bonus]),
                            "weaponFusion" : fusionDict(weapon.weaponFusion?.array as! [Fusion])
            ])
    }
    return weaponsDict
}

func unwrapWeapon(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var weapons = [Weapon]()
    for dict in dictionaries {
        let weapon = Weapon(context: context)
        weapon.name = dict["name"] as? String
        weapon.capacity = dict["capacity"] as! Int16
        weapon.charges = dict["charges"] as! Int16
        weapon.critical = dict["critical"] as? String
        weapon.damage = dict["damage"] as? String
        weapon.damageType = dict["damageType"] as? String
        weapon.roll = dict["roll"] as? String
        weapon.usage = dict["usage"] as! Int16
        weapon.bulk = dict["bulk"] as! Float
        weapon.equiped = dict["equiped"] as! Bool
        weapon.level = dict["level"] as! Int16
        weapon.price = dict["price"] as! Int64
        weapon.quantity = dict["quantity"] as! Int64
        weapon.range = dict["range"] as! Int64
        weapon.special = dict["special"] as? String
        weapon.type = dict["type"] as? String
        let weaponBonuses = dict["weaponBonus"] as! Array<Dictionary<String, Any>>
        weapon.weaponBonus = unwrapBonus(weaponBonuses)
        let weaponFusions = dict["weaponFusion"] as! Array<Dictionary<String, Any>>
        weapon.weaponFusion = unwrapFusion(weaponFusions)
        
        weapons.append(weapon)
    }
    return NSOrderedSet.init(array: weapons)
}

func itemDict(_ items: [Item]) -> Array<Dictionary<String, Any>> {
    var itemsDict = Array<Dictionary<String, Any>>()
    for item in items {
        itemsDict.append(["name" : item.name ?? "",
                           "bulk" : item.bulk,
                           "capacity" : item.capacity,
                           "category" : item.category ?? "",
                           "charges" : item.charges,
                           "content" : item.content ?? "",
                           "equiped" : item.equiped,
                           "level" : item.level,
                           "price" : item.price,
                           "quantity" : item.quantity,
                           "usage" : item.usage,
                           "itemBonus" : bonusDict(item.itemBonus?.array as! [Bonus])
            ])
    }
    return itemsDict
}

func unwrapItem(_ dictionaries: Array<Dictionary<String, Any>>) -> NSOrderedSet {
    var items = [Item]()
    for dict in dictionaries {
        let item = Item(context: context)
        item.name = dict["name"] as? String
        item.bulk = dict["bulk"] as! Float
        item.capacity = dict["capacity"] as! Int16
        item.category = dict["category"] as? String
        item.charges = dict["charges"] as! Int16
        item.content = dict["content"] as? String
        item.equiped = dict["equiped"] as! Bool
        item.level = dict["level"] as! Int16
        item.price = dict["price"] as! Int64
        item.quantity = dict["quantity"] as! Int64
        item.usage = dict["usage"] as! Int16
        let itemBonuses = dict["itemBonus"] as! Array<Dictionary<String, Any>>
        item.itemBonus = unwrapBonus(itemBonuses)
        items.append(item)
    }
    return NSOrderedSet.init(array: items)
}

