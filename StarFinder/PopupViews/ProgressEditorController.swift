//
//  ProgressEditorController.swift
//  StarFinder
//
//  Created by Tom on 4/6/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class ProgressEditorController: UIViewController {
    
    var PC = PlayerCharacter()
    var type = 0
    var current = 0
    var max = 0
    var operatorString = ""
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var barNameSpacer: UIView!
    
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet weak var btn0: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn6: UIButton!
    @IBOutlet weak var btn7: UIButton!
    @IBOutlet weak var btn8: UIButton!
    @IBOutlet weak var btn9: UIButton!
    
    @IBOutlet weak var backspace: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var equals: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        switch type {
        case 1:
            current = Int(PC.staminaCurrent)
            max = maxStamina(forPC: PC)
            barNameLabel.text = "Stamina"
        case 2:
            current = Int(PC.hpCurrent)
            max = maxHP(forPC: PC)
            barNameLabel.text = "Hit Points"
        case 3:
            current = Int(PC.resolveCurrent)
            max = maxResolve(forPC: PC)
            barNameLabel.text = "Resolve"
        case 4:
            current = Int(PC.credits)
            barNameLabel.text = "Credits"
        default: break
        }
        operatorString = "\(current)-"
        displayLabel.text = operatorString
    }
    
    func updatePalette() {
        
        windowView.backgroundColor = palette.bg
        barNameLabel.textColor = palette.main
        barNameSpacer.backgroundColor = palette.main
        
        displayLabel.textColor = palette.text
        displayLabel.backgroundColor = palette.alt
        
        let numBtns: Array<UIButton> = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
        for numBtn in  numBtns {
            numBtn.setTitleColor(palette.text, for: .normal)
            numBtn.backgroundColor = palette.button
        }
        
        let opBtns: Array<UIButton> = [backspace, plus, minus, equals]
        for opBtn in  opBtns {
            opBtn.setTitleColor(palette.alt, for: .normal)
            opBtn.backgroundColor = palette.main
        }
        
        
        
        
    }
    
    @IBAction func numberTapped(_ sender: UIButton) {
        operatorString.append("\(sender.tag)")
        displayLabel.text = operatorString
    }
    
    @IBAction func back(_ sender: Any) {
        operatorString = String(operatorString.dropLast())
        displayLabel.text = operatorString
    }
    
    @IBAction func plus(_ sender: Any) {
        if operatorString.last == "-" || operatorString.last == "+" {
            operatorString = String(operatorString.dropLast())
            operatorString.append("+")
        } else {
            operatorString.append("+")
        }
        displayLabel.text = operatorString
    }
    
    @IBAction func minus(_ sender: Any) {
        if operatorString.last == "-" || operatorString.last == "+" {
            operatorString = String(operatorString.dropLast())
            operatorString.append("-")
        } else {
            operatorString.append("-")
        }
        displayLabel.text = operatorString
    }
    
    @IBAction func equals(_ sender: Any) {
        let result = calculate(from: operatorString)
        switch type {
        case 1, 2, 3:
            if result > max {
                sendBack(result: max)
            } else {
                sendBack(result: result)
            }
        default:
            sendBack(result: result)
        }
    }
    
    func sendBack(result: Int) {
        switch type {
        case 1:
            PC.staminaCurrent = Int16(result)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        case 2:
            PC.hpCurrent = Int16(result)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        case 3:
            PC.resolveCurrent = Int16(result)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        case 4:
            PC.credits = Int64(result)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        default: break
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction func touchoutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func calculate(from: String) -> Int {
        var result = 0
        let stringFormated = from.replacingOccurrences(of: "-", with: "+-")
        let segments = stringFormated.components(separatedBy: "+")
        for segment in segments {
            if let number = Int(segment) {
                result += number
            }
        }
        return result
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tbc = segue.destination as! CharacterTabController
        tbc.PC = PC
        for vcAny in tbc.viewControllers! {
            let vc = vcAny as UIViewController
            vc.viewDidLoad()
        }
    }
    */
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
