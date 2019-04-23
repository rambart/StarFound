//
//  ViewController.swift
//  StarFinder
//
//  Created by Tom on 4/3/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var PCs = [Character]()
    let PC = Character()

    override func viewDidLoad() {
        super.viewDidLoad()
        let grappled = Bonus(context: context)
        grappled.type = "dexterity"
        grappled.bonus = -4
        PC.addToConditionalBonus(grappled)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

