//
//  CharacterDetailsController.swift
//  StarFinder
//
//  Created by Tom on 4/4/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class CharacterDetailsController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var portraitImgView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var raceClassLabel: UILabel!
    
    @IBOutlet weak var staminaLabel: UILabel!
    @IBOutlet weak var staminaCurrOverMaxLabel: UILabel!
    @IBOutlet weak var staminaBar: UIProgressView!
    
    @IBOutlet weak var hitPointsLabel: UILabel!
    @IBOutlet weak var hitPointsCurrOverMaxLabel: UILabel!
    @IBOutlet weak var hitPointBar: UIProgressView!
    
    @IBOutlet weak var resolveLabel: UILabel!
    @IBOutlet weak var resolveCurrOverMaxLabel: UILabel!
    @IBOutlet weak var resolveBar: UIProgressView!
    
    @IBOutlet weak var defensesHeader: UILabel!
    @IBOutlet weak var defensesHeaderSpacer: UIView!
    @IBOutlet weak var EACTitleLabel: UILabel!
    @IBOutlet weak var EACLabel: UILabel!
    @IBOutlet weak var KACTitleLabel: UILabel!
    @IBOutlet weak var KACLabel: UILabel!
    @IBOutlet weak var fortTitle: UILabel!
    @IBOutlet weak var fortButton: UIButton!
    @IBOutlet weak var refTitle: UILabel!
    @IBOutlet weak var refButton: UIButton!
    @IBOutlet weak var willTitle: UILabel!
    @IBOutlet weak var willButton: UIButton!
    
    @IBOutlet weak var AbilityScoreHeader: UILabel!
    @IBOutlet weak var abilityScoreHeaderSpacer: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var modLabel: UILabel!
    @IBOutlet weak var strScoreLabel: UILabel!
    @IBOutlet weak var dexScoreLabel: UILabel!
    @IBOutlet weak var conScoreLabel: UILabel!
    @IBOutlet weak var intScoreLabel: UILabel!
    @IBOutlet weak var wisScoreLabel: UILabel!
    @IBOutlet weak var chaScoreLabel: UILabel!
    @IBOutlet weak var strLabel: UILabel!
    @IBOutlet weak var dexLabel: UILabel!
    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var wisLabel: UILabel!
    @IBOutlet weak var chaLabel: UILabel!
    @IBOutlet weak var strModButton: UIButton!
    @IBOutlet weak var dexModButton: UIButton!
    @IBOutlet weak var conModButton: UIButton!
    @IBOutlet weak var intModButton: UIButton!
    @IBOutlet weak var wisModButton: UIButton!
    @IBOutlet weak var chaModButton: UIButton!
    
    @IBOutlet weak var detailsHeader: UILabel!
    @IBOutlet weak var detailsHeaderSpacer: UIView!
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var homeworldTitle: UILabel!
    @IBOutlet weak var homeworldLabel: UILabel!
    @IBOutlet weak var deityTitle: UILabel!
    @IBOutlet weak var deityLabel: UILabel!
    @IBOutlet weak var sizeTitle: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var alignmentTitle: UILabel!
    @IBOutlet weak var alignmentLabel: UILabel!
    @IBOutlet weak var genderTitle: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightTitle: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightTitle: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var hairTitle: UILabel!
    @IBOutlet weak var hairLabel: UILabel!
    @IBOutlet weak var eyesTitle: UILabel!
    @IBOutlet weak var eyeslabel: UILabel!
    
    @IBOutlet weak var background: UIView!
    
    // MARK: - Attributes
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var PC = PlayerCharacter()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        reloadData()
        
        for subview in self.view.subviews where subview.tag >= 1{
            let btn = subview as! UIButton
            btn.addTarget(self, action: #selector(rollTapped), for: .touchUpInside)
        }
        
        staminaBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(staminaBarEdit)))
        hitPointBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hpBarEdit)))
        resolveBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resolveBarEdit)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(CharacterDetailsController.reloadData), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    // MARK: - Functions
    @objc func reloadData() {
        
        let name = NSMutableAttributedString()
        name.shadowTitle(PC.name ?? "New Character")
        characterNameLabel.attributedText = name
        
        if PC.portraitPath != nil {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
            portraitImgView.image = UIImage(contentsOfFile: path.path)
        }

        
        
        let raceClass = NSMutableAttributedString()
        if PC.race?.name != nil {
            raceClass.shadowSub("\(PC.race?.name ?? "") ")
        }
        for object in PC.classLevels?.array as! [Level] {
            raceClass.shadowSub("\(object.name ?? "") ")
        }
        raceClassLabel.attributedText = raceClass
        
// MARK: - Stamina
        if PC.staminaCurrent > maxStamina(forPC: PC){
            PC.staminaCurrent = Int16(maxStamina(forPC: PC))
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        staminaCurrOverMaxLabel.text = "\(PC.staminaCurrent)/\(maxStamina(forPC: PC))"
        staminaBar.progress = Float(PC.staminaCurrent)/Float(maxStamina(forPC: PC))
// MARK: - HP
        if PC.hpCurrent > maxHP(forPC: PC){
            PC.hpCurrent = Int16(maxHP(forPC: PC))
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        hitPointsCurrOverMaxLabel.text = "\(PC.hpCurrent)/\(maxHP(forPC: PC))"
        hitPointBar.progress = Float(PC.hpCurrent)/Float(maxHP(forPC: PC))
// MARK: - Resolve
        if PC.resolveCurrent > maxResolve(forPC: PC){
            PC.resolveCurrent = Int16(maxResolve(forPC: PC))
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        resolveCurrOverMaxLabel.text = "\(PC.resolveCurrent)/\(maxResolve(forPC: PC))"
        resolveBar.progress = Float(PC.resolveCurrent)/Float(maxResolve(forPC: PC))
// MARK: - KAC
        var dexBonus = mod(of: "dexterity", forPC: PC)
        for armor in PC.ownsArmor?.array as! [Armor] {
            if armor.equiped && mod(of: "dexterity", forPC: PC) > armor.maxDexBonus{
                dexBonus = Int(armor.maxDexBonus)
            }
        }
        KACLabel.text = "\(10 + bonus(to: "KAC", forPC: PC) + dexBonus)"
// MARK: - EAC
        EACLabel.text = "\(10 + bonus(to: "EAC", forPC: PC) + dexBonus)"
// MARK: - Fort
        fortButton.setTitle(cleanPossNeg(of: saveBonus(to: "Fortitude", forPC: PC)), for: .normal)
// MARK: - Ref
        refButton.setTitle(cleanPossNeg(of: saveBonus(to: "Reflex", forPC: PC)), for: .normal)
// MARK: - Will
        willButton.setTitle(cleanPossNeg(of: saveBonus(to: "Will", forPC: PC)), for: .normal)
// MARK: - Ability Scores
        strScoreLabel.text = "\(Int(PC.strength) + bonus(to: "strength", forPC: PC))"
        dexScoreLabel.text = "\(Int(PC.dexterity) + bonus(to: "dexterity", forPC: PC))"
        conScoreLabel.text = "\(Int(PC.constitution) + bonus(to: "constitution", forPC: PC))"
        intScoreLabel.text = "\(Int(PC.intelligence) + bonus(to: "intelligence", forPC: PC))"
        wisScoreLabel.text = "\(Int(PC.wisdom) + bonus(to: "wisdom", forPC: PC))"
        chaScoreLabel.text = "\(Int(PC.charisma) + bonus(to: "charisma", forPC: PC))"
// MARK: - Ability Mods
        strModButton.setTitle(cleanPossNeg(of: mod(of: "strength", forPC: PC)), for: .normal)
        dexModButton.setTitle(cleanPossNeg(of: mod(of: "dexterity", forPC: PC)), for: .normal)
        conModButton.setTitle(cleanPossNeg(of: mod(of: "constitution", forPC: PC)), for: .normal)
        intModButton.setTitle(cleanPossNeg(of: mod(of: "intelligence", forPC: PC)), for: .normal)
        wisModButton.setTitle(cleanPossNeg(of: mod(of: "wisdom", forPC: PC)), for: .normal)
        chaModButton.setTitle(cleanPossNeg(of: mod(of: "charisma", forPC: PC)), for: .normal)
// MARK: - Details
        themeLabel.text = PC.theme?.name ?? "-"
        homeworldLabel.text = PC.homeworld ?? "-"
        deityLabel.text = PC.deity ?? "-"
        sizeLabel.text = PC.size ?? "-"
        speedLabel.text = "\(Int(PC.speed) + bonus(to: "speed", forPC: PC))"
        alignmentLabel.text = PC.alignment ?? "-"
        genderLabel.text = PC.gender ?? "-"
        heightLabel.text = PC.height ?? "-"
        weightLabel.text = PC.weight ?? "-"
        hairLabel.text = PC.hair ?? "-"
        eyeslabel.text = PC.eyes ?? "-"
        
        updatePalette()
    }
    
    func updatePalette() {
        
        
        let paletteName = UserDefaults.standard.value(forKey: "palette") as? String ?? "Space"
        let palette = Palette(paletteName)
        
        background.backgroundColor = palette.bg
        let titles: Array<UILabel> = [staminaLabel, hitPointsLabel, resolveLabel, defensesHeader, EACTitleLabel, KACTitleLabel, fortTitle, refTitle, willTitle, AbilityScoreHeader, scoreLabel, modLabel, strLabel, dexLabel, conLabel, intLabel, wisLabel, chaLabel, detailsHeader, themeTitle, homeworldTitle, deityTitle, sizeTitle, speedTitle, alignmentTitle, genderTitle, heightTitle, weightTitle, hairTitle, eyesTitle]
        for title in titles {
            title.textColor = palette.main
        }
        defensesHeaderSpacer.backgroundColor = palette.main
        abilityScoreHeaderSpacer.backgroundColor = palette.main
        detailsHeaderSpacer.backgroundColor = palette.main
        let texts: Array<UILabel> = [staminaCurrOverMaxLabel, hitPointsCurrOverMaxLabel, resolveCurrOverMaxLabel, EACLabel, KACLabel,strScoreLabel, dexScoreLabel, conScoreLabel, intScoreLabel, wisScoreLabel, chaScoreLabel, themeLabel, homeworldLabel, deityLabel, sizeLabel, speedLabel, alignmentLabel, genderLabel, heightLabel, weightLabel, hairLabel, eyeslabel]
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        strScoreLabel.backgroundColor = palette.button
        dexScoreLabel.backgroundColor = palette.button
        conScoreLabel.backgroundColor = palette.button
        intScoreLabel.backgroundColor = palette.button
        wisScoreLabel.backgroundColor = palette.button
        chaScoreLabel.backgroundColor = palette.button
        EACLabel.backgroundColor = palette.button
        KACLabel.backgroundColor = palette.button
        let btns: Array<UIButton> = [fortButton, refButton, willButton, strModButton, dexModButton, conModButton, intModButton, wisModButton, chaModButton]
        for button in btns {
            button.backgroundColor = palette.button
            button.setTitleColor(palette.text, for: .normal)
        }
        
    }
    
// MARK: - Buttons
    @IBAction func rollTapped(sender: UIButton) {
        let rvc = self.storyboard?.instantiateViewController(withIdentifier: "RollerController") as! RollerController
        let btnTitle = sender.title(for: .normal)?.replacingOccurrences(of: "+", with: "")
        rvc.expression = "1d20+" + btnTitle!
        rvc.PC = PC
        switch sender.tag {
        case 1:
            rvc.rollName = "Fortitude"
        case 2:
            rvc.rollName = "Reflex"
        case 3:
            rvc.rollName = "Will"
        case 11:
            rvc.rollName = "Strength"
        case 12:
            rvc.rollName = "Dexterity"
        case 13:
            rvc.rollName = "Constitution"
        case 14:
            rvc.rollName = "Intelligence"
        case 15:
            rvc.rollName = "Wisdom"
        case 16:
            rvc.rollName = "Charisma"
        default:
            rvc.rollName = rvc.expression
        }
        present(rvc, animated: true)
    }
    
    @objc func staminaBarEdit(_ sender: Any) {
        let bvc = self.storyboard?.instantiateViewController(withIdentifier: "ProgressEditorController") as! ProgressEditorController
        bvc.PC = self.PC
        bvc.type = 1
        present(bvc, animated: true)
    }
    
    @objc func hpBarEdit(_ sender: Any) {
        let bvc = self.storyboard?.instantiateViewController(withIdentifier: "ProgressEditorController") as! ProgressEditorController
        bvc.PC = self.PC
        bvc.type = 2
        present(bvc, animated: true)
    }
    
    @objc func resolveBarEdit(_ sender: Any) {
        let bvc = self.storyboard?.instantiateViewController(withIdentifier: "ProgressEditorController") as! ProgressEditorController
        bvc.PC = self.PC
        bvc.type = 3
        present(bvc, animated: true)
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
