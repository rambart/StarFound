//
//  RollerController.swift
//  StarFinder
//
//  Created by Tom on 4/5/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

class RollerController: UIViewController {
    
    @IBOutlet weak var window: UIView!
    
    @IBOutlet var outside: UIView!
    @IBOutlet weak var rollNameLabel: UILabel!
    @IBOutlet weak var rollNameSpacer: UIView!
    
    @IBOutlet weak var rollExpressionLabel: UILabel!
    @IBOutlet weak var rollResultsLabel: UILabel!
    
    @IBOutlet weak var resultsBG: UIView!
    @IBOutlet weak var resultsButton: UIButton!
    @IBOutlet weak var minTitle: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxTitle: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var halfTitle: UILabel!
    @IBOutlet weak var halfLabel: UILabel!
    
    var expression = ""
    var rollName = ""
    var PC = PlayerCharacter()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        rollNameLabel.text = rollName
        rollExpressionLabel.text = expression.replacingOccurrences(of: "+-", with: "-")
        minLabel.text = "\(rollMin(from: expression, forPC: PC))"
        maxLabel.text = "\(rollMax(from: expression, forPC: PC))"
        
        updatePalette()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadRoll()
    }
    
    @IBAction func touchOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func updatePalette() {
        window.backgroundColor = palette.bg
        
        rollNameSpacer.backgroundColor = palette.main
        let labels: Array<UILabel> = [rollNameLabel, minTitle, maxTitle, halfTitle]
        for label in labels {
            label.textColor = palette.main
        }
        let texts: Array<UILabel> = [rollExpressionLabel, rollResultsLabel, minLabel, maxLabel, halfLabel]
        for txt in texts {
            txt.textColor = palette.text
        }
        resultsBG.backgroundColor = palette.alt
        resultsButton.setTitleColor(palette.text, for: .normal)
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadRoll() {
        let result = roll(from: expression, forPC: PC)
        resultsButton.setTitle("\(result.0)", for: .normal)
        halfLabel.text = "\((result.0)/2)"
        rollResultsLabel.text = "\(result.1)".replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
        if result.0 == rollMax(from: expression, forPC: PC) {
            AudioServicesPlaySystemSound(SystemSoundID(1107))
            resultsBG.blink(stopAfter: 0.5, color: UIColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 1.0))
        } else if result.0 == rollMin(from: expression, forPC: PC) {
            AudioServicesPlaySystemSound(SystemSoundID(1107))
            resultsBG.blink(stopAfter: 0.5, color: UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0))
        } else {
            AudioServicesPlaySystemSound(SystemSoundID(1519))
        }
        
    }
    
    @IBAction func reroll(_ sender: Any) {
        reloadRoll()
    }
    

}



 
 
 
 
extension UIView {

    
    func blink(enabled: Bool = true, duration: CFTimeInterval = 0.1, stopAfter: CFTimeInterval = 0.0, color: UIColor) {
        
        let standard = self.backgroundColor
        
        enabled ? (UIView.animate(withDuration: duration,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.backgroundColor = color },
            completion: { [weak self] _ in self?.backgroundColor = standard })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
}



