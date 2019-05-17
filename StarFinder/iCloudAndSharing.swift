//
//  iCloud.swift
//  StarFound
//
//  Created by Tom on 4/23/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import CloudKit
import UIKit


func createPC(from string: String, portrait: UIImage? = nil) {
    
    guard let path = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
    }
    
    let saveFileURL = path.appendingPathComponent("/backup.char")
    
    do {
        try (string as String).write(to: saveFileURL, atomically: true, encoding: .utf8)
    } catch {
        print("could not save")
    }
    
    importPC(from: saveFileURL, portrait: portrait )
    
    
    do {
        try FileManager.default.removeItem(at: saveFileURL)
    } catch {
        print("could not delete")
    }
}

extension PlayerCharacter {
    func export(withPortrait: Bool = false) -> URL? {
        
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
        
        if self.portraitPath != nil && withPortrait {
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

func importPC(from url: URL, order: Int? = nil, portrait: UIImage? = nil) {
    
    guard let dictionary = NSDictionary(contentsOf: url),
        let PCinfo = dictionary as? [String: AnyObject] else {print("couldn't create dict"); return}
    
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
        
    } else if portrait != nil {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let imageName = UUID().uuidString
        let imagePath = documentsDirectory.appendingPathComponent(imageName)
        
        if let jpegData = portrait!.jpegData(compressionQuality: 100) {
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



func loadiCloudBackup(PCs: [PlayerCharacter], completion: @escaping (Bool) -> Void ) {
    let dispatch = DispatchGroup()
    var ckError = false
    
    var cloudPCs = [CKRecord]()
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
    let operation = CKQueryOperation(query: query)
    operation.desiredKeys = ["data", "portrait", "name"]
    operation.qualityOfService = .userInitiated
    operation.configuration.timeoutIntervalForRequest = TimeInterval(exactly: 15)!
    operation.configuration.timeoutIntervalForResource = TimeInterval(exactly: 15)!
    
    
    operation.recordFetchedBlock = { record in
        cloudPCs.append(record)
    }
    
    operation.queryCompletionBlock = { (cursor, error) in
        guard error == nil else {
            ckError = true
            completion(true)
            return
        }
    }
    
    operation.completionBlock = {
        for record in cloudPCs {
            guard let dataString = record.value(forKey: "data") as? String else { return }
            var portrait: UIImage? = nil
            if let asset = record.value(forKey: "portrait") as? CKAsset,
                let url = asset.fileURL {
                do {
                    let data = try Data(contentsOf: url)
                    portrait = UIImage(data: data)
                } catch {
                    print("could not open data from url")
                    print(error.localizedDescription)
                }
            }
            createPC(from: dataString, portrait: portrait)
            print(record.value(forKey: "name") ?? "no name")
        }
        
        if !ckError {
            for PC in PCs {
                deletePC(PC)
            }
        }
        dispatch.leave()
    }
    
    privateDatabase.add(operation)
    dispatch.enter()
    
    dispatch.notify(queue: .main) {
        // Save
        if !ckError {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        }
        completion(ckError)
    }
}

func saveiCloudBackup(PCs: [PlayerCharacter], completion: @escaping (Bool) -> Void ) {
    guard PCs.count > 0 else {
        completion(false)
        return
    }
    
    let dispatch = DispatchGroup()
    
    var oldRecords = [CKRecord]()
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
    let operation = CKQueryOperation(query: query)
    operation.configuration.timeoutIntervalForRequest = TimeInterval(exactly: 15)!
    operation.configuration.timeoutIntervalForResource = TimeInterval(exactly: 15)!
    
    operation.recordFetchedBlock = { (record) in
        oldRecords.append(record)
    }
    
    operation.queryCompletionBlock = { (cursor, error) in
        for record in oldRecords {
            print("deleting \(record.value(forKey: "name") ?? "no name")")
            privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (id, error) in
                guard error == nil else {
                    print(error?.localizedDescription)
                    completion(true)
                    return
                }
                print("deleted")
            })
        }
        dispatch.leave()
    }
    
    var urls = [URL]()
    
    // Create new records
    var newRecords = [CKRecord]()
    let saveDispatch = DispatchGroup()
    saveDispatch.enter()
    for PC in PCs {
        // Creates backup text file containing data for character and stores it at url
        guard let url = PC.export() else { completion(false); return }
        urls.append(url)
        var dataString = ""
        do {
            dataString = try String(contentsOf: url)
        } catch {
            print("Caught creating data String")
            completion(true)
            return
        }
        
        let character = CKRecord(recordType: "Character")
        character.setObject((PC.name ?? "name") as NSString, forKey: "name")
        character.setObject(dataString as NSString, forKey: "data")
        
        // Create image asset for character portrait
        if PC.portraitPath != nil {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
            let img = CKAsset(fileURL: path)
            character.setObject(img, forKey: "portrait")
        }
        
        print("saving \(PC.name ?? "no name")")
        privateDatabase.save(character) { (record, error) in
            guard error == nil else {
                completion(true)
                return
            }
            newRecords.append(character)
            if newRecords.count == PCs.count {
                saveDispatch.leave()
            }
            print("saved")
        }
        
        
    }
    
    privateDatabase.add(operation)
    dispatch.enter()
    
    var dispatchCompleted = false
    var saveCompleted = false
    
    dispatch.notify(queue: .main) {
        dispatchCompleted = true
        if saveCompleted {
            completion(false)
            return
        }
    }
    
    saveDispatch.notify(queue: .main) {
        saveCompleted = true
        if dispatchCompleted {
            completion(false)
            return
        }
    }
    
}
