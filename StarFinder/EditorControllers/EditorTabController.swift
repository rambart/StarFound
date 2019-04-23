//
//  EditorTabController.swift
//  StarFinder
//
//  Created by Tom on 4/6/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorTabController: UITabBarController {
    
    var PC = PlayerCharacter()
    var editedPC = PlayerCharacter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        editedPC = PC

             
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(abilityIncrease), name:NSNotification.Name(rawValue: "AbilityIncrease"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFeat), name:NSNotification.Name(rawValue: "NewFeat"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func abilityIncrease() {
        let ac = UIAlertController(title: "Ability Increase", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func newFeat() {
        let ac = UIAlertController(title: "New Feat", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(ac, animated: true)
    }

    @objc func saveTapped() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        context.rollback()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
