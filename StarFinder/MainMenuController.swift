//
//  MainMenuController.swift
//  StarFound
//
//  Created by Tom on 4/26/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import SVProgressHUD

class CharacterSelectMenu: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PCs = [PlayerCharacter]()
    
    // MARK: - Outlets
    @IBOutlet weak var pcsTable: UITableView!
    @IBOutlet weak var pcsTableHeight: NSLayoutConstraint!
    @IBOutlet weak var fullVersionBtn: UIButton!
    
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pcsTable.delegate = self
        pcsTable.dataSource = self
        
        pcsTable.isEditing = true
        
        if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            fullVersionBtn.setTitle("Full Version ✔︎", for: .normal)
        } else {
            fullVersionBtn.setTitle("Full Version 🔒", for: .normal)
        }
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        fetchPCs()
        PCs = PCs.sorted(by: { $0.order < $1.order })
        pcsTable.reloadData()
        pcsTableHeight.constant = pcsTable.contentSize.height
    }
    
    func fetchPCs() {
        do {
            try PCs = context.fetch(PlayerCharacter.fetchRequest())
        } catch {
            print("Did not fetch")
        }
        PCs = PCs.sorted(by: { $0.order < $1.order })
    }
    
    // MARK: - Buttons
    
    @IBAction func fullVersion(_ sender: Any) {
        
        if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            let ac = UIAlertController(title: "Unlocked", message: "Thank you for your purchase", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Done", style: .cancel))
            present(ac, animated: true)
        } else {
            // Automatically attempt to restore IAP if not unlocked
            IAPService.shared.paymentQueue.restoreCompletedTransactions()
            if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
                let ac = UIAlertController(title: "Unlocked", message: "Thank you for your purchase", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Done", style: .cancel))
                present(ac, animated: true)
            } else {
                IAPService.shared.purchase("Rambart.StarFound.unlock")
            }
        }
    }
    
    @IBAction func restorePurchases(_ sender: Any) {
        IAPService.shared.paymentQueue.restoreCompletedTransactions()
        let ac = UIAlertController(title: "Restored", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func OGL(_ sender: Any) {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let ogl = self.storyboard?.instantiateViewController(withIdentifier: "OGLNav") as! OGLNav
            pvc?.present(ogl, animated: true)
        })
    }
    
    
    @IBAction func changeTheme(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            openThemeChanger()
        } else {
            IAPService.shared.paymentQueue.restoreCompletedTransactions()
            if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
                openThemeChanger()
            } else {
                let ac = UIAlertController(title: "Unlock Full Version", message: "Please buy the full version to change your theme", preferredStyle: .alert)
                let buy = UIAlertAction(title: "Unlock", style: .default) { (_) in
                    IAPService.shared.purchase("Rambart.StarFound.unlock")
                }
                let noThanks = UIAlertAction(title: "No Thank You", style: .cancel)
                ac.addAction(buy)
                ac.addAction(noThanks)
                present(ac, animated: true)
            }
        }
        
    }
    
    func openThemeChanger() {
        weak var pvc = self.presentingViewController
        self.dismiss(animated: true, completion: {
            let tc = self.storyboard?.instantiateViewController(withIdentifier: "ThemeChanger") as! ThemeChanger
            pvc?.present(tc, animated: true)
        })
    }
    
    
    @IBAction func tappedOutside(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Cloud Sync
    
    @IBAction func cloudSave(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            let ac = UIAlertController(title: "Save to iCloud?", message: "This will overwrite your previous backup. Backups may take a few minutes before they become available.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: saveBtnTapped)
            ac.addAction(cancel)
            ac.addAction(okay)
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Unlock Full Version", message: "Please buy the full version to sync with iCloud", preferredStyle: .alert)
            let buy = UIAlertAction(title: "Unlock", style: .default) { (_) in
                IAPService.shared.purchase("Rambart.StarFound.unlock")
            }
            let noThanks = UIAlertAction(title: "No Thank You", style: .cancel)
            ac.addAction(buy)
            ac.addAction(noThanks)
            present(ac, animated: true)
        }
    }
    
    @IBAction func cloudLoad(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            let ac = UIAlertController(title: "Load Backup?", message: "This will overwrite your currently saved characters.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            let okay = UIAlertAction(title: "Okay", style: .default, handler: loadBtnTapped)
            ac.addAction(cancel)
            ac.addAction(okay)
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Unlock Full Version", message: "Please buy the full version to sync with iCloud", preferredStyle: .alert)
            let buy = UIAlertAction(title: "Unlock", style: .default) { (_) in
                IAPService.shared.purchase("Rambart.StarFound.unlock")
            }
            let noThanks = UIAlertAction(title: "No Thank You", style: .cancel)
            ac.addAction(buy)
            ac.addAction(noThanks)
            present(ac, animated: true)
        }
    }
    
    func saveBtnTapped(_ : UIAlertAction) {
        SVProgressHUD.show(withStatus: "Saving to iCloud")
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        saveiCloudBackup(PCs: PCs) { (ckError) in
            SVProgressHUD.dismiss()
            SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
            if ckError {
                SVProgressHUD.showError(withStatus: "Unable to save to iCloud")
            } else {
                SVProgressHUD.showSuccess(withStatus: "Backup Saved")
            }
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func loadBtnTapped(_ : UIAlertAction) {
        SVProgressHUD.show(withStatus: "Loading from iCloud")
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        loadiCloudBackup(PCs: PCs) { (ckError) in
            SVProgressHUD.dismiss()
            SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
            if ckError {
                SVProgressHUD.showError(withStatus: "Unable to load from iCloud")
            } else {
                SVProgressHUD.showSuccess(withStatus: "Backup Loaded")
            }
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    

    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case pcsTable:
            return PCs.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case pcsTable:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterDeleterCell", for: indexPath)
            let attString = NSMutableAttributedString()
            attString.shadowSub(PCs[indexPath.row].name ?? "Unnamed Character")
            cell.textLabel?.attributedText = attString
            let imageBG = UIImageView()
            if PCs[indexPath.row].portraitPath != nil {
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PCs[indexPath.row].portraitPath!)
                imageBG.image = UIImage(contentsOfFile: path.path)
            } else {
                imageBG.image = UIImage(named: "DefaultPortrait")!
            }
            imageBG.contentMode = .scaleAspectFill
            cell.backgroundView = imageBG
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let PC = PCs[indexPath.row]
            PCs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deletePC(PC)
            if PCs.count > 0 {
                for i in 0...(PCs.count - 1) {
                    PCs[i].order = Int16(i)
                }
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.PCs[sourceIndexPath.row]
        PCs.remove(at: sourceIndexPath.row)
        PCs.insert(movedObject, at: destinationIndexPath.row)
        for i in 0...(PCs.count - 1) {
            PCs[i].order = Int16(i)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
}





class OGLNav: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
}

class OGLController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        if devMode {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(unlock))
        }
        
    }
    
    @objc func done() {
        self.dismiss(animated: true)
    }
    
    @objc func unlock() {
        let unlock = UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock")
        UserDefaults.standard.set(!unlock, forKey: "Rambart.StarFound.unlock")
    }
    
    
}


class ThemeChanger: UIViewController {
    
    // MARK: - Attributes
    let themes = ["Space", "Ecto", "Fire", "Hazard", "Hull", "Light", "Plasma", "Void"]
    var previewTheme: String = "Space" {
        didSet {
            loadPreview()
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var windowView: UIView!
    @IBOutlet weak var themesTitle: UILabel!
    @IBOutlet weak var themesSpacer: UIView!
    @IBOutlet weak var themesTableView: UITableView!
    @IBOutlet weak var setButton: UIButton!
    
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themesTableView.delegate = self
        themesTableView.dataSource = self
        
        previewTheme = UserDefaults.standard.value(forKey: "palette") as? String ?? "Space"
        
    }
    
    // MARK: - Buttons
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func set(_ sender: Any) {
        
        UserDefaults.standard.set(previewTheme, forKey: "palette")
        
        self.dismiss(animated: true)
        
    }
    
    func loadPreview() {
        let palette = Palette(previewTheme)
        
        windowView.backgroundColor = palette.bg
        themesTitle.textColor = palette.main
        themesSpacer.backgroundColor = palette.main
        setButton.backgroundColor = palette.button
        setButton.setTitleColor(palette.alt, for: .normal)
    }
    
    
    
    
    
}

extension ThemeChanger: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisualsCell", for: indexPath)
        var text = ""
        if previewTheme == themes[indexPath.row] {
            text = "●   " + themes[indexPath.row]
        } else {
            text = "○   " + themes[indexPath.row]
        }
        let mainColor = UIColor(named: "\(themes[indexPath.row])Main")
        cell.textLabel?.text = text
        cell.textLabel?.textColor = mainColor
        let BGcolor = UIColor(named: "\(themes[indexPath.row])BG")
        cell.backgroundColor = BGcolor
        //cell.backgroundView?.backgroundColor = BGcolor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        previewTheme = themes[indexPath.row]
        tableView.reloadData()
    }
    
    
    
    
}
