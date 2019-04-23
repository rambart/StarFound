//
//  CharacterFeatController.swift
//  StarFinder
//
//  Created by Tom on 4/19/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterFeatController: UIViewController {
    
    @IBOutlet weak var windowView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameSpacer: UIView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    var name = String()
    var content = String()
    var options = [Option]()
    var modifiers = [Bonus]()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePalette()
        
        nameLabel.text = name
        contentLabel.text = content
        
        
        
        let attText = NSMutableAttributedString()
        attText
            .normal(content)
        if options.count > 0 {
            for opt in options {
                if opt.selected {
                    attText
                        .normal("\n\n")
                        .h1("\(opt.name ?? "")")
                        .normal("\n\n\(opt.content ?? "")")
                }
            }
        }
        if modifiers.count > 0 {
            attText.h1("\n\nModifiers")
            for mod in modifiers {
                attText
                    .bold("\n\(mod.type ?? "")")
                    .normal(" \(cleanPossNeg(of: Int(mod.bonus)) )")
            }
        }
        contentLabel.attributedText = attText
        
    }
    
    func updatePalette() {
        windowView.backgroundColor = palette.bg
        nameLabel.textColor = palette.main
        nameSpacer.backgroundColor = palette.main
        contentLabel.textColor = palette.text
    }
    
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
