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

public func deletePC(_ PC: PlayerCharacter) {
    if PC.portraitPath != nil {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
            print("Couldn't delete portrait")
        }
    }
    context.delete(PC)
}

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








