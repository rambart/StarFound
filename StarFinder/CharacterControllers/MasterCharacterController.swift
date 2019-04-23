//
//  MasterCharacterController.swift
//  StarFinder
//
//  Created by Tom on 5/12/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIScrollView {
    var currentPage:Int{
        return Int((self.contentOffset.x+(0.5*self.frame.size.width))/self.frame.width)+1
    }
}

class MasterCharacterNav: UINavigationController {
    var PC = PlayerCharacter()
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if palette.button == UIColor.darkGray {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = palette.main
        
        navigationBar.backgroundColor = palette.main
        
        if palette.button == UIColor.darkGray {
            navigationBar.barTintColor = UIColor(white: 0, alpha: 0.75)
            navigationBar.barStyle = .black
        } else {
            navigationBar.barTintColor = UIColor(white: 1, alpha: 0.75)
            navigationBar.barStyle = .default
        }
        
    }
}



class MasterCharacterController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate {
    
    var PC = PlayerCharacter()
    var palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    var bannerView: GADBannerView!
    
    @IBOutlet weak var MasterScroll: UIScrollView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var skillsView: UIView!
    @IBOutlet weak var combatView: UIView!
    @IBOutlet weak var spellsView: UIView!
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var featuresView: UIView!
    @IBOutlet weak var detailBtn: UIButton!
    @IBOutlet weak var combatBtn: UIButton!
    @IBOutlet weak var spellsBtn: UIButton!
    @IBOutlet weak var featsBtn: UIButton!
    @IBOutlet weak var skillsBtn: UIButton!
    @IBOutlet weak var itemsBtn: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var pageWidth: NSLayoutConstraint!
    @IBOutlet weak var adSpacerHeight: NSLayoutConstraint!
    
    
    

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustForiPad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PC = (self.navigationController as! MasterCharacterNav).PC
        
        if !UserDefaults.standard.bool(forKey: "*Rambart.StarFound.unlock") {
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            
            bannerView.adUnitID = GoogleAdsID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            bannerView.delegate = self
            
            addBannerViewToView(bannerView)
            
            adSpacerHeight.constant = bannerView.intrinsicContentSize.height
        } else {
            adSpacerHeight.constant = 0
        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if palette.button == UIColor.darkGray {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustForiPad()
        
        view.backgroundColor = palette.bg
        
        
        // Menu Btn
        let menuBtn = UIButton(type: UIButton.ButtonType.system)
        menuBtn.setTitle("⚙︎", for: UIControl.State.normal)
        menuBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        menuBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        menuBtn.addTarget(self, action: #selector(menuTapped), for: UIControl.Event.touchUpInside)
        let right = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.rightBarButtonItem = right
        // Back Btn
        let backBtn = UIButton(type: UIButton.ButtonType.system)
        backBtn.setTitle("←", for: UIControl.State.normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        backBtn.titleEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        backBtn.addTarget(self, action: #selector(backTapped), for: UIControl.Event.touchUpInside)
        let left = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = left
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        PC = (self.navigationController as! MasterCharacterNav).PC
        
        MasterScroll.delegate = self
        
        
        if palette.button == UIColor.darkGray {
            bottomBar.backgroundColor = UIColor(white: 0, alpha: 0.75)
        } else {
            bottomBar.backgroundColor = UIColor(white: 1, alpha: 0.75)
        }
        detailBtn.imageView?.contentMode = .scaleAspectFit
        detailBtn.tintColor = palette.main
        combatBtn.imageView?.contentMode = .scaleAspectFit
        combatBtn.tintColor = palette.main
        spellsBtn.imageView?.contentMode = .scaleAspectFit
        spellsBtn.tintColor = palette.main
        featsBtn.imageView?.contentMode = .scaleAspectFit
        featsBtn.tintColor = palette.main
        skillsBtn.imageView?.contentMode = .scaleAspectFit
        skillsBtn.tintColor = palette.main
        itemsBtn.imageView?.contentMode = .scaleAspectFit
        itemsBtn.tintColor = palette.main
        PCChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        if PC.isCaster() {
            spellsBtn.isHidden = false
            spellsView.isHidden = false
        } else {
            spellsBtn.isHidden = true
            spellsView.isHidden = true
        }
    }
    
    func adjustForiPad() {
        MasterScroll.isPagingEnabled = false
        bottomBar.isHidden = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .landscapeRight, .landscapeLeft:
                guard let w = UIApplication.shared.delegate?.window, let window = w else { return }
                pageWidth.constant = (window.screen.bounds.width) / CGFloat (3)
            case .portrait, .portraitUpsideDown:
                guard let w = UIApplication.shared.delegate?.window, let window = w else { return }
                pageWidth.constant = (window.screen.bounds.width) / CGFloat(2.5)
            default:
                break
            }
        } else {
            guard let w = UIApplication.shared.delegate?.window, let window = w else { return }
            pageWidth.constant = window.screen.bounds.width
            MasterScroll.isPagingEnabled = true
            bottomBar.isHidden = false
        }
    }
    
    // MARK: - Menu Setup
    @objc func backTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func menuTapped() {
        
        let menu = storyboard?.instantiateViewController(withIdentifier: "CharacterMenuController") as! CharacterMenuController
        menu.PC = PC
        var editorPage = self.MasterScroll.currentPage
        if self.PC.isCaster() {
            switch self.MasterScroll.currentPage {
            case 3:
                editorPage = 1
            case 4:
                editorPage = 3
            case 5:
                editorPage = 4
            case 6:
                editorPage = 5
            default:
                break
            }
        }
        menu.currentPage = editorPage
        present(menu, animated: true)
        
        /*
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Edit", style: .default, handler: edit))
        ac.addAction(UIAlertAction(title: "Rest", style: .default, handler: rest))
        ac.addAction(UIAlertAction(title: "Charge All Batteries", style: .default, handler: charge))
        ac.addAction(UIAlertAction(title: "Roller", style: .default, handler: roller))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        */
    }
    
    func edit(_: UIAlertAction) {
        performSegue(withIdentifier: "editTapped", sender: self)
    }
    
    func rest(_: UIAlertAction) {
        PC.staminaCurrent = Int16(maxStamina(forPC: PC))
        PC.hpCurrent = Int16(maxHP(forPC: PC))
        PC.resolveCurrent = Int16(maxResolve(forPC: PC))
        if let PCCounters = PC.trackers {
            for counterAny in PCCounters {
                let counter = counterAny as! Tracker
                if counter.doesReset {
                    counter.value = counter.reset
                }
            }
        }
        for level in PC.classLevels?.array as! [Level] {
            for slot in level.classSlots?.array as! [SpellSlot] {
                slot.used = 0
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func charge(_: UIAlertAction) {
        for ammo in PC.ownsBattery?.array as! [Ammo] {
            if ammo.isBattery {
                ammo.current = ammo.capacity
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func roller(_: UIAlertAction) {
        let rcvc = storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
        rcvc.PC = PC
        present(rcvc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Mark: - Child Views PCs
        PC = (self.navigationController as! MasterCharacterNav).PC
        if segue.identifier == "showChild" {
            if let child = segue.destination as? CharacterDetailsController {
                child.PC = PC
            }
            if let child = segue.destination as?             CharacterCombatController {
                child.PC = PC
            }
            if let child = segue.destination as? CharacterSkillController {
                child.PC = PC
            }
            if let child = segue.destination as? CharacterSpellsController {
                child.PC = PC
            }
            if let child = segue.destination as? CharacterFeaturesController {
                child.PC = PC
            }
            if let child = segue.destination as? CharacterItemsController {
                child.PC = PC
            }
            
        }
        
        // Mark: - Edit Character
        if segue.identifier == "editTapped" {
            let nc = segue.destination as! MasterEditorNavController
            nc.PC = PC
            var editorPage = MasterScroll.currentPage
            if PC.isCaster() {
                switch MasterScroll.currentPage {
                case 3:
                    editorPage = 1
                case 4:
                    editorPage = 3
                case 5:
                    editorPage = 4
                case 6:
                    editorPage = 5
                default:
                    break
                }
            }
            nc.startingPage = editorPage
        }
        
        // MARK: - openMenu
        if segue.identifier == "openMenu" {
            let menu = segue.destination as! CharacterMenuController
            menu.PC = PC
            var editorPage = self.MasterScroll.currentPage
            if self.PC.isCaster() {
                switch self.MasterScroll.currentPage {
                case 3:
                    editorPage = 1
                case 4:
                    editorPage = 3
                case 5:
                    editorPage = 4
                case 6:
                    editorPage = 5
                default:
                    break
                }
            }
            menu.currentPage = editorPage
        }
    }
    
    // MARK: - Scroll
    
    
    
    // MARL: - Tab Bar
    
    @IBAction func tabTapped(_ sender: UIButton) {
        var pg = sender.tag - 1
        
        if !PC.isCaster() && pg >= 3{
            pg -= 1
        }
        var pageWidth = MasterScroll.frame.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageWidth = MasterScroll.frame.width / 3
        }
        
        MasterScroll.setContentOffset(CGPoint(x: (pageWidth * CGFloat(pg)), y: MasterScroll.contentOffset.y), animated: true)
    }
    
    
    
}

class CharacterMenuController: UIViewController, UITableViewDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var currentPage = 0
    
    // MARK: - Outlets
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func outsideTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTable" {
            let table = segue.destination as! MenuTable
            table.currentPage = currentPage
            table.PC = PC
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}



class MenuTable: UITableViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var currentPage = 0
    let palette = Palette(UserDefaults.standard.value(forKey: "palette") as! String)
    
    // MARK: - Outlets
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = palette.bg
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! menuCell
        cell.contentView.backgroundColor = palette.bg
        cell.symbol.textColor = palette.main
        cell.title.textColor = palette.main
        switch indexPath.row {
        case 0:
            cell.symbol.text = "✎"
            cell.title.text = "Edit"
        case 1:
            cell.symbol.text = "⚂"
            cell.title.text = "Roller"
        case 2:
            cell.symbol.text = "☾"
            cell.title.text = "Rest"
        case 3:
            cell.symbol.text = "⚡︎"
            cell.title.text = "Recharge"
        case 4:
            cell.symbol.text = "⇪"
            cell.title.text = "Share"
        default:
            break
        }
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let mevc = self.storyboard?.instantiateViewController(withIdentifier: "MasterEditorNavController") as! MasterEditorNavController
                mevc.PC = self.PC
                mevc.startingPage = self.currentPage
                pvc?.present(mevc, animated: true)
            })
        case 2:
            PC.staminaCurrent = Int16(maxStamina(forPC: PC))
            PC.hpCurrent = Int16(maxHP(forPC: PC))
            PC.resolveCurrent = Int16(maxResolve(forPC: PC))
            if let PCCounters = PC.trackers {
                for counterAny in PCCounters {
                    let counter = counterAny as! Tracker
                    if counter.doesReset {
                        counter.value = counter.reset
                    }
                }
            }
            for level in PC.classLevels?.array as! [Level] {
                for slot in level.classSlots?.array as! [SpellSlot] {
                    slot.used = 0
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.dismiss(animated: true)
        case 1:
            weak var pvc = self.presentingViewController
            self.dismiss(animated: true, completion: {
                let rcvc = self.storyboard?.instantiateViewController(withIdentifier: "RollerCalcController") as! RollerCalcController
                rcvc.PC = self.PC
                pvc?.present(rcvc, animated: true)
            })
        case 3:
            for ammo in PC.ownsBattery?.array as! [Ammo] {
                if ammo.isBattery {
                    ammo.current = ammo.capacity
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.dismiss(animated: true)
            
        case 4:
            guard let url = PC.export()
                else { return }
            
            let message = """
            Open the attachment and select "Copy to StarFound". You may need to scroll to see this option. You can also save this in your Files App and import it into StarFound at any time by selecting it and tapping the action button (box with an arrow pointing upwards) and selecting "Copy to Starfound".
            """
            
            let activityController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                let rectOfCell = tableView.rectForRow(at: indexPath)
                let rectOfCellInSuperview = tableView.convert(rectOfCell, to: tableView.superview)
                
                
                activityController.popoverPresentationController?.sourceView = self.view
                activityController.popoverPresentationController?.sourceRect = rectOfCellInSuperview
            }
            present(activityController, animated: true, completion: nil)
            
        default:
            self.dismiss(animated: true)
        }
        
        
    }
    
    
}

class menuCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var symbol: UILabel!
}





