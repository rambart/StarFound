//
//  MasterEditorController.swift
//  StarFinder
//
//  Created by Tom on 5/22/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MasterEditorNavController: UINavigationController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var startingPage = Int()
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Master Editor: \(startingPage)")
    }
}

class MasterEditorController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var oldImgUrls = [String]()
    var newImgUrls = [String]()
    var bannerView: GADBannerView!

    // MARK: - Outlets
    @IBOutlet weak var MasterScroll: UIScrollView!
    @IBOutlet weak var detailsBtn: UIButton!
    @IBOutlet weak var combatBtn: UIButton!
    @IBOutlet weak var featsBtn: UIButton!
    @IBOutlet weak var skillsBtn: UIButton!
    @IBOutlet weak var itemsBtn: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var pageWidth: NSLayoutConstraint!
    @IBOutlet weak var adSpacerHeight: NSLayoutConstraint!
    
    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MasterScroll.delegate = self
        
        adjustForiPad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        NotificationCenter.default.addObserver(self, selector: #selector(abilityIncrease), name:NSNotification.Name(rawValue: "AbilityIncrease"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFeat), name:NSNotification.Name(rawValue: "NewFeat"), object: nil)
        
        PC = (self.navigationController as! MasterEditorNavController).PC
        
        detailsBtn.imageView?.contentMode = .scaleAspectFit
        combatBtn.imageView?.contentMode = .scaleAspectFit
        featsBtn.imageView?.contentMode = .scaleAspectFit
        skillsBtn.imageView?.contentMode = .scaleAspectFit
        itemsBtn.imageView?.contentMode = .scaleAspectFit
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UIDevice.current.userInterfaceIdiom != .pad {
            scroll(toPage: (self.navigationController as! MasterEditorNavController).startingPage)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (self.navigationController as! MasterEditorNavController).startingPage = MasterScroll.currentPage
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustForiPad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    
    func scroll(toPage: Int) {
        MasterScroll.setContentOffset(CGPoint(x: (MasterScroll.frame.width * CGFloat(toPage - 1)), y: MasterScroll.contentOffset.y), animated: false)
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
    
    // MARK: - Level Up Triggers
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

    // MARK: - Save and Cancel
    @objc func saveTapped() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        deletePortraits(oldImgUrls)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func cancelTapped() {
        context.rollback()
        deletePortraits(newImgUrls)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    // MARK: - Navigation/Container Setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        PC = (self.navigationController as! MasterEditorNavController).PC
        // Mark: - Child Views PCs
        if segue.identifier == "showChild" {
            if let child = segue.destination as? EditorDetailController {
                child.PC = PC
            }
            if let child = segue.destination as? EditorCombatController {
                child.PC = PC
            }
            if let child = segue.destination as? EditorFeatsController {
                child.PC = PC
            }
            if let child = segue.destination as? EditorSkillsController {
                child.PC = PC
            }
            if let child = segue.destination as? EditorItemsController {
                child.PC = PC
            }
        }
    }
    
    // MARK: - Tab Bar
    @IBAction func tabTapped(_ sender: UIButton) {
        MasterScroll.setContentOffset(CGPoint(x: (MasterScroll.frame.width * CGFloat(sender.tag - 1)), y: MasterScroll.contentOffset.y), animated: true)
        print("👉 \(MasterScroll.frame.width * CGFloat(sender.tag - 1))")
    }
    
    func deletePortraits(_ urls: [String]) {
        for url in urls {
            print("Deleting Unused Portrait")
            do {
                try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(url))
            } catch {
                print("Could not delete file: \(error)")
            }
        }
    }
    
    
}
