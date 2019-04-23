//
//  RollerCalcController.swift
//  StarFinder
//
//  Created by Tom on 5/31/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class RollerCalcController: UIViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var inputExpression = ""
    var rollExpression: [String] = [String]() {
        didSet {
            updateLabel()
        }
    }
    var diceMode = false
    var inputMode = false
    var attackMode = false
    var attack = Attack()
    var weapon = Weapon()
    
    
    // MARK: - Outlets
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var diceLabel: UILabel!
    @IBOutlet weak var pcBtn: UIButton!
    @IBOutlet weak var dieBtn: UIButton!
    @IBOutlet weak var top1Btn: UIButton!
    @IBOutlet weak var top2Btn: UIButton!
    @IBOutlet weak var top3Btn: UIButton!
    @IBOutlet weak var top4Btn: UIButton!
    @IBOutlet weak var bottom1Btn: UIButton!
    @IBOutlet weak var bottom2Btn: UIButton!
    @IBOutlet weak var bottom3Btn: UIButton!
    @IBOutlet weak var bottom4Btn: UIButton!
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        for seg in inputExpression.components(separatedBy: "+") {
            rollExpression.append(seg)
        }
    }
    
    func updateLabel() {
        var text = ""
        for seg in rollExpression {
            if seg.first == "-" {
                text.append(seg)
            } else {
                text.append("+\(seg)")
            }
        }
        if text.first == "+" {
            text = String(text.dropFirst())
        }
        if text == "" {
            text = "0"
        }
        previewLabel.text = text
        diceLabel.text = ""
        print(rollExpression)
    }

    // MARK: - Buttons
    
    @IBAction func numButton(_ sender: UIButton) {
        if rollExpression.count == 0 {
            rollExpression.append("")
        }
        rollExpression[rollExpression.count - 1].append("\(sender.tag)")
    }
    
    @IBAction func plusMinus(_ sender: UIButton) {
        if rollExpression.last == "" || rollExpression.last == "-" {
            rollExpression.remove(at: rollExpression.count - 1)
        }
        if sender.tag == 1 {
            rollExpression.append("")
        } else {
            rollExpression.append("-")
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        if rollExpression.count > 0 {
            if rollExpression[rollExpression.count - 1] == ""
                || rollExpression[rollExpression.count - 1] == "-"
                || rollExpression[rollExpression.count - 1].lowercased().contains("d")
                || rollExpression[rollExpression.count - 1].lowercased().contains("s")
                || rollExpression[rollExpression.count - 1].lowercased().contains("c")
                || rollExpression[rollExpression.count - 1].lowercased().contains("b")
                || rollExpression[rollExpression.count - 1].lowercased().contains("i")
                || rollExpression[rollExpression.count - 1].lowercased().contains("l")
                {
                rollExpression.remove(at: rollExpression.count - 1)
            } else {
                rollExpression[rollExpression.count - 1] = String(rollExpression[rollExpression.count - 1].dropLast())
            }
        }
    }
    
    @IBAction func equals(_ sender: UIButton) {
        var text = ""
        for seg in rollExpression {
            text.append("+\(seg)")
        }
        text = String(text.dropFirst())
        if text == "" {
            text = "0"
        }
        if !inputMode {
            let rollOutcome = roll(from: text, forPC: PC)
            
            previewLabel.text = "\(rollOutcome.result)"
            diceLabel.text = "Max:\(rollMax(from: text, forPC: PC))          Min:\(rollMin(from: text, forPC: PC))         Half:\(Int(rollOutcome.result / 2))\n\(rollOutcome.dice)".replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
        } else {
            if attackMode {
                if attack.managedObjectContext != nil {
                    attack.roll = text
                }
                if weapon.managedObjectContext != nil {
                    weapon.roll = text
                }
            } else {
                if attack.managedObjectContext != nil {
                    attack.damage = text
                }
                if weapon.managedObjectContext != nil {
                    weapon.damage = text
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RollReturned"), object: nil)
            self.dismiss(animated: true)
        }
        
    }
    
    @IBAction func switchMode(_ sender: UIButton) {
        diceMode = !diceMode
        if diceMode {
            dieBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            pcBtn.backgroundColor = UIColor.darkGray
            top1Btn.setTitle("d20", for: .normal)
            top2Btn.setTitle("d12", for: .normal)
            top3Btn.setTitle("d10", for: .normal)
            top4Btn.setTitle("d8", for: .normal)
            bottom1Btn.setTitle("d6", for: .normal)
            bottom2Btn.setTitle("d4", for: .normal)
            bottom3Btn.setTitle("d100", for: .normal)
            bottom4Btn.setTitle("dx", for: .normal)
        } else {
            pcBtn.backgroundColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
            dieBtn.backgroundColor = UIColor.darkGray
            top1Btn.setTitle("STR", for: .normal)
            top2Btn.setTitle("DEX", for: .normal)
            top3Btn.setTitle("CON", for: .normal)
            top4Btn.setTitle("BAB", for: .normal)
            bottom1Btn.setTitle("INT", for: .normal)
            bottom2Btn.setTitle("WIS", for: .normal)
            bottom3Btn.setTitle("CHA", for: .normal)
            bottom4Btn.setTitle("LVL", for: .normal)
        }
    }
    
    @IBAction func topButton(_ sender: UIButton) {
        
        if diceMode {
            switch sender.tag {
            case 11:
                add("d20")
            case 12:
                add("d12")
            case 13:
                add("d10")
            case 14:
                add("d8")
            case 21:
                add("d6")
            case 22:
                add("d4")
            case 23:
                add("d100")
            case 24:
                add("d")
            default:
                break
            }
        } else {
            switch sender.tag {
            case 11:
                addVar("STR")
            case 12:
                addVar("DEX")
            case 13:
                addVar("CON")
            case 14:
                addVar("BAB")
            case 21:
                addVar("INT")
            case 22:
                addVar("WIS")
            case 23:
                addVar("CHA")
            case 24:
                addVar("LVL")
            default:
                break
            }
        }
    }
    
    
    func add(_ die: String) {
        if rollExpression.count == 0 {
            rollExpression.append("")
        }
        
        let lastSeg = rollExpression[rollExpression.count - 1]
        let notNumbers = rollExpression[rollExpression.count - 1].lowercased().contains("d")
            || rollExpression[rollExpression.count - 1].lowercased().contains("s")
            || rollExpression[rollExpression.count - 1].lowercased().contains("c")
            || rollExpression[rollExpression.count - 1].lowercased().contains("b")
            || rollExpression[rollExpression.count - 1].lowercased().contains("i")
            || rollExpression[rollExpression.count - 1].lowercased().contains("l")
        
        if rollExpression.count > 1 && rollExpression[rollExpression.count - 2].suffix(die.count) == die && (lastSeg == "" || lastSeg == "-") {
            let diceNum = Int(rollExpression[rollExpression.count - 2].replacingOccurrences(of: die, with: "")) ?? 0
            rollExpression[rollExpression.count - 2] = "\(diceNum + 1)\(die)"
        } else if lastSeg == "" || lastSeg == "-" {
            rollExpression[rollExpression.count - 1].append("1\(die)")
            if die != "d" {
                rollExpression.append("")
            }
        } else if !notNumbers {
            rollExpression[rollExpression.count - 1].append(die)
            if die != "d" {
                rollExpression.append("")
            }
        } else {
            rollExpression.append("1\(die)")
            if die != "d" {
                rollExpression.append("")
            }
        }
    }
    
    func addVar(_ variable: String) {
        if rollExpression.count != 0 && (rollExpression.last == "-" || rollExpression.last == "") {
            rollExpression[rollExpression.count - 1].append(variable)
            rollExpression.append("")
        } else {
            rollExpression.append(variable)
            rollExpression.append("")
        }
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
