//
//  CharacterSelectorController.swift
//  StarFound
//
//  Created by Tom on 2/20/19.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit
import CoreImage
import GoogleMobileAds
import CloudKit
import SVProgressHUD

class CharacterSelectorController: UIViewController, GADBannerViewDelegate {

    // MARK: Attributes
    var PCs = [PlayerCharacter]()
    var cellWidth: CGFloat = 0
    var headerFooterWidth: CGFloat = 0
    var startingPage: Int = 0
    var selectedPage: Int = 0  {
        willSet{
            // Hide cell that was selected
            let ip = IndexPath(item: selectedPage, section: 0)
            if let cell = characterSelectCollection.cellForItem(at: ip) as? CharacterCell {
                cell.hide(true)
            }
        }
        didSet{
            // Show cell that is now selected
            let ip = IndexPath(item: selectedPage, section: 0)
            if let cell = characterSelectCollection.cellForItem(at: ip) as? CharacterCell {
                cell.hide(false)
            }
        }
    }
    var bannerView: GADBannerView!

    
    // MARK: Outlets
    @IBOutlet weak var characterSelectCollection: UICollectionView!
    @IBOutlet weak var adSpacerHeight: NSLayoutConstraint!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IAPService.shared.getProducts()
        
        // Fetches and stores all PlayerCharacter objects in the PCs array
        fetchPCs()
        
        characterSelectCollection.delegate = self
        characterSelectCollection.dataSource = self
        
        adjustForiPad()
        
        // Notification posted when a change occurs to the PCs
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewWillAppear(_:)), name:NSNotification.Name(rawValue: "purchased"), object: nil)
    }
    
    deinit {
        // Removes obsever detecting changes in PC objects
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "purchased"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Detects and adjusts view for device
        adjustForiPad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
            bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            
            bannerView.adUnitID = GoogleAdsID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            bannerView.delegate = self
            
            addBannerViewToView(bannerView)
            
            adSpacerHeight.constant = bannerView.intrinsicContentSize.height
        } else {
            if bannerView != nil {
                bannerView.removeFromSuperview()
            }
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

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil, completion: { _ in
           
            self.adjustForiPad()
            if self.PCs.count > 0 {
                // Scroll to collection item that was previously selected
                let ip = IndexPath(item: self.selectedPage, section: 0)
                self.characterSelectCollection.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
                
                // Deselect all cells but the selected cell
                let cells = self.characterSelectCollection.visibleCells as! [CharacterCell]
                for cell in cells {
                    if cell == cells[self.selectedPage] {
                        cell.hide(false)
                    } else {
                        cell.hide(true)
                    }
                }
            }
            
            
            
        })
        
    }
    
    
    // MARK: - Functions
    
    // Used to adjust the view depending on device and orientation
    func adjustForiPad() {
       let window = self.view.bounds
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch UIDevice.current.orientation {
            case .landscapeRight, .landscapeLeft:
                // iPad in Landscape
                cellWidth = 400
            default:
                // iPad in Portrait
                cellWidth = 500
            }
        } else {
            // iPhone (must be in Portrait)
            cellWidth = window.width * 0.6
        }
        // Header and footer width are set so the selected item can be centered on screen
        headerFooterWidth = (window.width - cellWidth) / 2
        characterSelectCollection.reloadData()
    }
    
    // Called when PC objects change
    @objc func PCChanged() {
        fetchPCs()
        characterSelectCollection.reloadData()
    }
    
    func fetchPCs() {
        do {
            try PCs = context.fetch(PlayerCharacter.fetchRequest())
        } catch {
            print("Did not fetch")
        }
        PCs = PCs.sorted(by: { $0.order < $1.order })
    }
    
    
    // MARK: Buttons
    
    // Tapped to create a new PlayerCharacter
    @IBAction func add(_ sender: Any) {
        // Users are allowed 1 character without unlock
        if PCs.count >= 1 {
            if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
                createNewPC()
            } else {
                // If user has not purchased the unlock, automatically attempt to restore
                IAPService.shared.paymentQueue.restoreCompletedTransactions()
                if UserDefaults.standard.bool(forKey: "Rambart.StarFound.unlock") {
                    createNewPC()
                } else {
                    // User has not purchased unlock or is unable to restore
                    // Create and present prompt to buy unlock
                    let ac = UIAlertController(title: "Unlock Full Version", message: "Please buy the full version to create and manage more characters.", preferredStyle: .alert)
                    let buy = UIAlertAction(title: "Unlock", style: .default) { (_) in
                        IAPService.shared.purchase("Rambart.StarFound.unlock")
                    }
                    let noThanks = UIAlertAction(title: "No Thank You", style: .cancel)
                    ac.addAction(buy)
                    ac.addAction(noThanks)
                    present(ac, animated: true)
                }
            }
        } else {
            createNewPC()
        }
    }
    

    func createNewPC() {
        let newPC = PlayerCharacter(context: context)
        newPC.order = Int16(PCs.count)
        newPC.strength = 10
        newPC.dexterity = 10
        newPC.constitution = 10
        newPC.intelligence = 10
        newPC.charisma = 10
        newPC.wisdom = 10
        newPC.resolveAbility = "Strength"
        newPC.gravityModifier = 1.0
        newPC.credits = 0
        
        // This app does not include a list of the skills, what ability they use, and if ACP applies
        // This is the only place where the default list of skills is specified
        let skill0 = Skill(context: context)
        skill0.name = "Acrobatics"
        skill0.ranks = 0
        skill0.ability = "Dex"
        skill0.armorCheck = true
        
        let skill1 = Skill(context: context)
        skill1.name = "Athletics"
        skill1.ranks = 0
        skill1.ability = "Str"
        skill1.armorCheck = true
        
        let skill2 = Skill(context: context)
        skill2.name = "Bluff"
        skill2.ranks = 0
        skill2.ability = "Cha"
        skill2.armorCheck = false
        
        let skill3 = Skill(context: context)
        skill3.name = "Computers"
        skill3.ranks = 0
        skill3.ability = "Int"
        skill3.armorCheck = false
        
        let skill4 = Skill(context: context)
        skill4.name = "Culture"
        skill4.ranks = 0
        skill4.ability = "Int"
        skill4.armorCheck = false
        
        let skill5 = Skill(context: context)
        skill5.name = "Diplomacy"
        skill5.ranks = 0
        skill5.ability = "Cha"
        skill5.armorCheck = false
        
        let skill6 = Skill(context: context)
        skill6.name = "Disguise"
        skill6.ranks = 0
        skill6.ability = "Cha"
        skill6.armorCheck = false
        
        let skill7 = Skill(context: context)
        skill7.name = "Engineering"
        skill7.ranks = 0
        skill7.ability = "Int"
        skill7.armorCheck = false
        
        let skill8 = Skill(context: context)
        skill8.name = "Intimidate"
        skill8.ranks = 0
        skill8.ability = "Cha"
        skill8.armorCheck = false
        
        let skill9 = Skill(context: context)
        skill9.name = "Life Science"
        skill9.ranks = 0
        skill9.ability = "Int"
        skill9.armorCheck = false
        
        let skill10 = Skill(context: context)
        skill10.name = "Medicine"
        skill10.ranks = 0
        skill10.ability = "Int"
        skill10.armorCheck = false
        
        let skill11 = Skill(context: context)
        skill11.name = "Mysticism"
        skill11.ranks = 0
        skill11.ability = "Wis"
        skill11.armorCheck = false
        
        let skill12 = Skill(context: context)
        skill12.name = "Perception"
        skill12.ranks = 0
        skill12.ability = "Wis"
        skill12.armorCheck = false
        
        let skill13 = Skill(context: context)
        skill13.name = "Physical Science"
        skill13.ranks = 0
        skill13.ability = "Int"
        skill13.armorCheck = false
        
        let skill14 = Skill(context: context)
        skill14.name = "Piloting"
        skill14.ranks = 0
        skill14.ability = "Dex"
        skill14.armorCheck = false
        
        let skill15 = Skill(context: context)
        skill15.name = "Profession"
        skill15.ranks = 0
        skill15.ability = "Cha"
        skill15.armorCheck = false
        
        let skill16 = Skill(context: context)
        skill16.name = "Sense Motive"
        skill16.ranks = 0
        skill16.ability = "Wis"
        skill16.armorCheck = false
        
        let skill17 = Skill(context: context)
        skill17.name = "Sleight of Hand"
        skill17.ranks = 0
        skill17.ability = "Dex"
        skill17.armorCheck = true
        
        let skill18 = Skill(context: context)
        skill18.name = "Stealth"
        skill18.ranks = 0
        skill18.ability = "Dex"
        skill18.armorCheck = true
        
        let skill19 = Skill(context: context)
        skill19.name = "Survival"
        skill19.ranks = 0
        skill19.ability = "Wis"
        skill19.armorCheck = false
        
        
        newPC.addToSkills(skill0)
        newPC.addToSkills(skill1)
        newPC.addToSkills(skill2)
        newPC.addToSkills(skill3)
        newPC.addToSkills(skill4)
        newPC.addToSkills(skill5)
        newPC.addToSkills(skill6)
        newPC.addToSkills(skill7)
        newPC.addToSkills(skill8)
        newPC.addToSkills(skill9)
        newPC.addToSkills(skill10)
        newPC.addToSkills(skill11)
        newPC.addToSkills(skill12)
        newPC.addToSkills(skill13)
        newPC.addToSkills(skill14)
        newPC.addToSkills(skill15)
        newPC.addToSkills(skill16)
        newPC.addToSkills(skill17)
        newPC.addToSkills(skill18)
        newPC.addToSkills(skill19)
        
        newPC.hpCurrent = Int16(maxHP(forPC: newPC))
        newPC.staminaCurrent = Int16(maxStamina(forPC: newPC))
        newPC.resolveCurrent = Int16(maxResolve(forPC: newPC))
        let newRace = Race(context: context)
        newRace.name = ""
        let newTheme = Theme(context: context)
        newTheme.name = ""
        newPC.race = newRace
        newPC.theme = newTheme
        
        PCs.append(newPC)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        // Show new PC in selector and select it to show user the character was created
        characterSelectCollection.reloadData()
        let ip = IndexPath(item: (PCs.count - 1), section: 0)
        characterSelectCollection.scrollToItem(at: ip, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func select(_sender: Any) {
        // If user has not created a PC, prompt user to create one
        if PCs.count == 0 {
            let ac = UIAlertController(title: "No Characters", message: "You must create a character first", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: .cancel)
            ac.addAction(okay)
            present(ac, animated: true)
        } else {
            let mcvc = storyboard?.instantiateViewController(withIdentifier: "MasterCharacterNav") as! MasterCharacterNav
            mcvc.PC = PCs[selectedPage]
            present(mcvc, animated: true)
        }
    }
    
    // Opens the settings menu
    @IBAction func settings(_sender: Any) {
        let menu = storyboard?.instantiateViewController(withIdentifier: "CharacterSelectMenu") as! CharacterSelectMenu
        menu.PCs = PCs
        present(menu, animated: true)
    }
    
    // Scroll View
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startingPage = Int((scrollView.contentOffset.x / cellWidth))
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        // Velocity Threshold is the scroll velocity needed to select the next item users were scrolling towards
        let velocityThreshold: CGFloat = 0.5
        
        let releasedOnPage: Int = Int((scrollView.contentOffset.x / cellWidth) + 0.5)
        
        // Velocity Modifier is the adjustment to the selected page based on release velocity
        var velocityModifier = 0
        if velocity.x > velocityThreshold && releasedOnPage >= startingPage {
            velocityModifier = 1
        }
        if velocity.x < -velocityThreshold && releasedOnPage <= startingPage {
            velocityModifier = -1
        }
        
        var page = releasedOnPage + velocityModifier
        if page < 0 {
            page = 0
        } else if page > (characterSelectCollection.numberOfItems(inSection: 0) - 1) {
            page = (characterSelectCollection.numberOfItems(inSection: 0) - 1)
        }
        let indexPath = IndexPath(row: page, section: 0)
        characterSelectCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        selectedPage = Int((scrollView.contentOffset.x / cellWidth) + 0.5)
    }
    
    private func fetchUserRecordID() {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch User Record
        defaultContainer.fetchUserRecordID { (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecordID = recordID {
                DispatchQueue.main.sync {
                    self.fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    private func fetchUserRecord(recordID: CKRecord.ID) {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch Private Database
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        // Fetch User Record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }
    
    
    
    
}


extension CharacterSelectorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PCs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if PCs.count == 0 {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as! CharacterCell
        let PC = PCs[indexPath.item]
        // Portrait
        if PC.portraitPath != nil {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
            cell.portrait.image = UIImage(contentsOfFile: path.path)
            cell.image = UIImage(contentsOfFile: path.path) ?? UIImage(named: "DefaultPortrait")!
        } else {
            cell.image = UIImage(named: "DefaultPortrait")!
        }
        cell.Noir()
        // Name
        let name = NSMutableAttributedString()
        name.shadowTitle(PC.name ?? "New Character")
        cell.nameLabel.attributedText = name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: headerFooterWidth, height: collectionView.contentSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: headerFooterWidth, height: collectionView.contentSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.contentSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPage = indexPath.item
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let cell = collectionView.cellForItem(at: indexPath) as! CharacterCell
        cell.hide(false)
    }
}


class CharacterCell: UICollectionViewCell {
    
    let imageContext = CIContext(options: nil)
    var PCSelected = false
    var image = UIImage()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var cellStack: UIStackView!
    @IBOutlet weak var detailStack: UIStackView!
    @IBOutlet weak var raceClassLabel: UILabel!
    @IBOutlet weak var staminaLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var resolveLabel: UILabel!
    @IBOutlet weak var staminaProgress: UIProgressView!
    @IBOutlet weak var hpProgress: UIProgressView!
    @IBOutlet weak var resolveProgress: UIProgressView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var spacerlower: UIView!
    
    override func didTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        hide(true)
    }
    
    // Desaturates the portrait image
    func Noir() {
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        currentFilter!.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let cgimg = imageContext.createCGImage(output!,from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        portrait.image = processedImage
    }
    
    func unnoir() {
        portrait.image = image
    }
    
    // hide: true will desaturate the image and unhide the spacers, shrinking the image view
    // hide: false will show the original image and hide the spacers, expanding the image view
    func hide(_ hide: Bool) {
        if hide && spacer.isHidden {
            Noir()
            UIView.animate(withDuration: 0.8,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            self.spacer.isHidden = false
                            self.spacerlower.isHidden = false
                            self.cellStack.layoutIfNeeded()
            },
                           completion: nil)
        }
        
        if !hide && !spacer.isHidden {
            unnoir()
            UIView.animate(withDuration: 0.8,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1,
                           options: [],
                           animations: {
                            //self.detailStack.isHidden = false
                            self.spacer.isHidden = true
                            self.spacerlower.isHidden = true
                            self.cellStack.layoutIfNeeded()
            },
                           completion: nil)
        }
        
    }
    
}

