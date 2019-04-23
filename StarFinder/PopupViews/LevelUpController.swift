//
//  levelUpController.swift
//  StarFinder
//
//  Created by Tom on 4/28/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class LevelUpController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var levelsPicker: UIPickerView!
    
    var PC = PlayerCharacter()
    var levels = [Level]()
    var selectedLevel = Level()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        levelsPicker.delegate = self
        levelsPicker.dataSource = self

        levels = PC.classLevels?.array as! [Level]
        selectedLevel = levels[0]
        levelsPicker.selectRow(0, inComponent: 0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    @IBAction func newLevelTapped(_ sender: Any) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "NRTC") as! EditorNewRaceThemeClassController
            newVC.PC = self.PC
            newVC.mode = "class"
            pvc?.present(newVC, animated: true)
            })
    }
    
    @IBAction func selectTapped(_ sender: Any) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            if self.selectedLevel.compendiumClass != nil {
                let ac = UIAlertController(title: "Import features from compendium?", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: (self.importTapped)))
                ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: (self.noTapped)))
                pvc?.present(ac, animated: true)
            } else {
                self.importTapped(nil)
            }
        })
    }
    
    func importTapped(_: UIAlertAction?) {
        levelUp(selectedLevel, forPC: PC)
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        var charLevel = 0
        for level in PC.classLevels?.array as! [Level] {
            charLevel += Int(level.levels)
        }
        if charLevel % 5 == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AbilityIncrease"), object: nil)
        }
        if (charLevel + 1) % 2 == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewFeat"), object: nil)
        }
        let ecvc = storyboard?.instantiateViewController(withIdentifier: "EditorClassNav") as! EditorClassNavController
        ecvc.PC = PC
        ecvc.level = selectedLevel
        present(ecvc, animated: true)
    }
    
    func noTapped(_: UIAlertAction?) {
        weak var pvc = self.presentingViewController
        selectedLevel.levels += 1
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        let ecvc = self.storyboard?.instantiateViewController(withIdentifier: "EditorClassNav") as! EditorClassNavController
        ecvc.PC = PC
        ecvc.level = selectedLevel
        pvc?.present(ecvc, animated: true)
        
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLevel = levels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(levels[row].name ?? "") \(levels[row].levels)"
    }

}
