//
//  CharacterFeaturesController.swift
//  StarFinder
//
//  Created by Tom on 5/1/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class CharacterFeaturesController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var notesTitle: UILabel!
    @IBOutlet weak var notesMinimize: UIButton!
    @IBOutlet weak var notesSpacer: UIView!
    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var notesTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var raceTitle: UILabel!
    @IBOutlet weak var raceMinimize: UIButton!
    @IBOutlet weak var raceSpacer: UIView!
    @IBOutlet weak var raceFeatsTable: UITableView!
    @IBOutlet weak var raceTableHieght: NSLayoutConstraint!
    
    @IBOutlet weak var themeTitle: UILabel!
    @IBOutlet weak var themeMinimize: UIButton!
    @IBOutlet weak var themeSpacer: UIView!
    @IBOutlet weak var themeFeatsTable: UITableView!
    @IBOutlet weak var themeTableHieght: NSLayoutConstraint!
    
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classMinimize: UIButton!
    @IBOutlet weak var classSpacer: UIView!
    @IBOutlet weak var classFeatsTable: UITableView!
    @IBOutlet weak var classTableHieght: NSLayoutConstraint!
    
    @IBOutlet weak var featsTitle: UILabel!
    @IBOutlet weak var featsMinimize: UIButton!
    @IBOutlet weak var featsSpacer: UIView!
    @IBOutlet weak var FeatsTable: UITableView!
    @IBOutlet weak var FeatsTableHieght: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var PC = PlayerCharacter()
    var notes = [Note]()
    var raceFeats = [Feature]()
    var themeFeats = [Feature]()
    var classFeats = [Feature]()
    var levels = [Level]()
    var feats = [Feature]()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTable.dataSource = self
        notesTable.delegate = self
        raceFeatsTable.dataSource = self
        raceFeatsTable.delegate = self
        themeFeatsTable.dataSource = self
        themeFeatsTable.delegate = self
        classFeatsTable.dataSource = self
        classFeatsTable.delegate = self
        FeatsTable.dataSource = self
        FeatsTable.delegate = self
        scrollView.delegate = self
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        updatePalette()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        notes = PC.notes?.array as! [Note]
        if PC.race?.racialFeature?.array as? [Feature] != nil {
            raceFeats = PC.race?.racialFeature?.array as! [Feature]
        }
        if PC.theme?.themeFeature?.array as? [Feature] != nil {
            themeFeats = PC.theme?.themeFeature?.array as! [Feature]
        }
        classFeats = [Feature]()
        for level in PC.classLevels?.array as! [Level] {
            for feat in level.classFeature?.array as! [Feature] {
                classFeats.append(feat)
            }
        }
        levels = PC.classLevels?.array as! [Level]
        if PC.feats?.array as? [Feature] != nil {
            feats = PC.feats?.array as! [Feature]
        }
        
        notesTable.reloadData()
        notesTableHeight.constant = notesTable.contentSize.height
        raceFeatsTable.reloadData()
        raceTableHieght.constant = raceFeatsTable.contentSize.height
        themeFeatsTable.reloadData()
        themeTableHieght.constant = themeFeatsTable.contentSize.height
        classFeatsTable.reloadData()
        classTableHieght.constant = classFeatsTable.contentSize.height
        FeatsTable.reloadData()
        FeatsTableHieght.constant = FeatsTable.contentSize.height
        
    }
    
    func updatePalette() {
        
        view.backgroundColor = palette.bg
        let titles: Array<UILabel> = [notesTitle, raceTitle, themeTitle, classTitle, featsTitle]
        for title in titles {
            title.textColor = palette.main
        }
        let spacers: Array<UIView> = [notesSpacer, raceSpacer, themeSpacer, classSpacer, featsSpacer]
        for spacer in spacers {
            spacer.backgroundColor = palette.main
        }
        let texts: Array<UILabel> = []
        for textLabel in texts {
            textLabel.textColor = palette.text
        }
        let btns: Array<UIButton> = [notesMinimize, raceMinimize, themeMinimize, classMinimize, featsMinimize]
        for button in btns {
            //button.backgroundColor = palette.button
            button.setTitleColor(palette.main, for: .normal)
        }
        let tables: Array<UITableView> = [notesTable, raceFeatsTable, themeFeatsTable, classFeatsTable, FeatsTable]
        for table in tables {
            table.separatorColor = palette.main
            table.backgroundColor = palette.bg
        }
        
    }
    
    // MARK: - Buttons
    
    @IBAction func minimize(_ sender: UIButton) {
        var table: UITableView = UITableView()
        switch sender {
        case notesMinimize:
            table = notesTable
        case raceMinimize:
            table = raceFeatsTable
        case themeMinimize:
            table = themeFeatsTable
        case classMinimize:
            table = classFeatsTable
        case featsMinimize:
            table = FeatsTable
        default:
            break
        }
        
        //table.isHidden = !table.isHidden
        if table.isHidden {
            sender.setTitle("↑", for: .normal)
            table.isHidden = false
            
        } else {
            sender.setTitle("↓", for: .normal)
            table.isHidden = true
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == classFeatsTable {
            return levels.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == classFeatsTable {
            return levels[section].name
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = palette.text
        header.contentView.backgroundColor = palette.button
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case notesTable:
            return notes.count
        case raceFeatsTable:
            return raceFeats.count
        case themeFeatsTable:
            if characterLevel(forPC: PC) >= 18 && themeFeats.count >= 4 {
                return 4
            } else if characterLevel(forPC: PC) >= 12 && themeFeats.count >= 3 {
                return 3
            } else if characterLevel(forPC: PC) >= 6 && themeFeats.count >= 2 {
                return 2
            } else if themeFeats.count >= 1 {
                return 1
            } else {
                return 0
            }
        case classFeatsTable:
            let feats = levels[section].classFeature?.array as! [Feature]
            return feats.count
        case FeatsTable:
            return feats.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatCell", for: indexPath) as! FeatCell
        if tableView == notesTable {
            cell.nameLabel.text = notes[indexPath.row].name ?? ""
            cell.subtitleLabel.text = ""
        } else {
            var feat = Feature()
            switch tableView {
            case raceFeatsTable:
                feat = raceFeats[indexPath.row]
            case themeFeatsTable:
                feat = themeFeats[indexPath.row]
            case classFeatsTable:
                feat = levels[indexPath.section].classFeature?.array[indexPath.row] as! Feature
            case FeatsTable:
                feat = feats[indexPath.row]
            default:
                break
            }
            var opts = ""
            for opt in feat.featureOptions?.array as! [Option] {
                if opt.selected {
                    opts.append(opt.name ?? "")
                    opts.append(" ")
                }
            }
            cell.subtitleLabel.text = opts
            cell.nameLabel.text = feat.name
        }
        cell.contentView.backgroundColor = palette.bg
        cell.nameLabel.textColor = palette.text
        cell.subtitleLabel.textColor = palette.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fvc = storyboard?.instantiateViewController(withIdentifier: "CharacterFeatController") as! CharacterFeatController
        if tableView == notesTable {
            fvc.name = notes[indexPath.row].name ?? ""
            fvc.content = notes[indexPath.row].content ?? ""
        } else {
            var feat = Feature()
            switch tableView {
            case raceFeatsTable:
                feat = raceFeats[indexPath.row]
            case themeFeatsTable:
                feat = themeFeats[indexPath.row]
            case classFeatsTable:
                feat = levels[indexPath.section].classFeature?.array[indexPath.row] as! Feature
            case FeatsTable:
                feat = feats[indexPath.row]
            default:
                break
            }
            fvc.name = feat.name ?? ""
            fvc.content = feat.content ?? ""
            fvc.options = feat.featureOptions?.array as! [Option]
            fvc.modifiers = feat.featureBonus?.array as! [Bonus]
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        present(fvc, animated: true)
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



class FeatCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}





