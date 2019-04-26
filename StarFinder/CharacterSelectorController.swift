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
        
        
        
        
    }
    
    deinit {
        // Removes obsever detecting changes in PC objects
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Detects and adjusts view for device
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
                    let buy = UIAlertAction(title: "Unlock", style: .default, handler: purchaseFullVersion )
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
    
    // Prompts the unlock IAP
    func purchaseFullVersion (_: UIAlertAction) {
        IAPService.shared.purchase("Rambart.StarFound.unlock")
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
            cell.image = UIImage(contentsOfFile: path.path)!
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

class CharacterSelectMenu: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PCs = [PlayerCharacter]()
    var cloudPCs = [CKRecord]()
    
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
                purchaseFullVersion(UIAlertAction())
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
                let buy = UIAlertAction(title: "Unlock", style: .default, handler: purchaseFullVersion )
                let noThanks = UIAlertAction(title: "No Thank You", style: .cancel)
                ac.addAction(buy)
                ac.addAction(noThanks)
                present(ac, animated: true)
            }
        }
        
    }
    
    func purchaseFullVersion (_: UIAlertAction) {
        IAPService.shared.purchase("Rambart.StarFound.unlock")
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
        SVProgressHUD.show(withStatus: "Saving to iCloud")
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        saveToCloud { (didSave) in
            SVProgressHUD.dismiss()
            SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
            if didSave {
                SVProgressHUD.showSuccess(withStatus: "Saved to iCloud")
            } else {
                SVProgressHUD.showError(withStatus: "Unable to save")
            }
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    @IBAction func cloudLoad(_ sender: Any) {
        loadFromCloud()
    }
    
    func loadFromCloud() {
        // Timeout
        var timeOut = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(15), execute: {
            if timeOut {
                SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
                SVProgressHUD.showError(withStatus: "Unable to load backup")
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
        })
        
        let dispatch = DispatchGroup()
        
        cloudPCs = [CKRecord]()
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["data", "portrait"]
        
        operation.recordFetchedBlock = { record in
            print("💢")
            self.cloudPCs.append(record)
        }
        
        operation.queryCompletionBlock = { (_, error) in
            guard error == nil else {
                SVProgressHUD.showError(withStatus: "Unable to load backup")
                return
            }
            timeOut = false
            dispatch.leave()
        }
        
        
        
        DispatchQueue.global(qos: .userInitiated).sync {
            SVProgressHUD.show(withStatus: "Loading from iCloud")
            dispatch.enter()
            UIApplication.shared.beginIgnoringInteractionEvents()
            privateDatabase.add(operation)
        }
        
        
        dispatch.notify(queue: .main) {
            
            // Delete old PCs
            if self.cloudPCs.count <= 0 {
                SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
                SVProgressHUD.showError(withStatus: "No characters backed up")
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            } else {
                for PC in self.PCs {
                    deletePC(PC)
                }
            }
            
            // Create new PCs
            for record in self.cloudPCs {
                guard let dataString = record.value(forKey: "data") as? String else { return }
                var portrait: UIImage? = nil
                if let asset = record.value(forKey: "portrait") as? CKAsset,
                    let url = asset.fileURL {
                    do {
                        let data = try Data(contentsOf: url)
                        portrait = UIImage(data: data)
                    } catch {
                        print("could not open data from url")
                        print(error.localizedDescription)
                    }
                    
                }
                
                createPC(from: dataString, portrait: portrait)
            }
            
            // Save
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
            
            SVProgressHUD.dismiss()
            SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
            SVProgressHUD.showSuccess(withStatus: "Restored from backup")
            UIApplication.shared.endIgnoringInteractionEvents()
            return
        }
    }
    
    func saveToCloud(_ completion: @escaping (Bool) -> Void) {
        var urls = [URL]()
        var timeOut = true
        let close = {
            for url in urls {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("item already deleted")
                }
            }
            completion(false)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(20), execute: {
            if timeOut {
                close()
            }
        })

        
        var oldRecords = [CKRecord]()
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { (record) in
            oldRecords.append(record)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            for record in oldRecords {
                privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (id, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        close()
                    }
                })
            }
        }
        
        // Create new records
        var newRecords = [CKRecord]()
        for PC in self.PCs {
            // Creates backup text file containing data for character and stores it at url
            guard let url = PC.export() else { close(); return }
            urls.append(url)
            var dataString = ""
            do {
                dataString = try String(contentsOf: url)
            } catch {
                print("Caught creating data String")
                close()
            }
            
            let character = CKRecord(recordType: "Character")
            character.setObject((PC.name ?? "name") as NSString, forKey: "name")
            character.setObject(dataString as NSString, forKey: "data")
            
            // Create image asset for character portrait
            if PC.portraitPath != nil {
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
                let img = CKAsset(fileURL: path)
                character.setObject(img, forKey: "portrait")
            }
            
            newRecords.append(character)
        }
        
        let dispatch = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async {
            privateDatabase.add(operation)
            timeOut = false
            
            for character in newRecords {
                dispatch.enter()
                // Save newly created CKRecord
                privateDatabase.save(character) { (record, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        close()
                    }
                    print(character.value(forKey: "name"))
                    dispatch.leave()
                }
            }
            
            for url in urls {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    print("Failed to remove character from files")
                    print(error.localizedDescription)
                }
            }
            
            dispatch.wait()
            
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }


//    func fetchAndDeleteOld(_ completion: @escaping () -> Void) {
//        var oldRecords = [CKRecord]()
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//        let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
//        let operation = CKQueryOperation(query: query)
//
//        operation.recordFetchedBlock = { (record) in
//            oldRecords.append(record)
//        }
//
//        operation.queryCompletionBlock = { (cursor, error) in
//            for record in oldRecords {
//                privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (id, error) in
//                    guard error == nil else {
//                        print(error?.localizedDescription)
//                        return
//                    }
//                })
//            }
//        }
//
//        privateDatabase.add(operation)
//    }
//
//    func createAndSaveRecords(_ completion: @escaping () -> Void) {
//        // Create new records
//        for PC in self.PCs {
//            // Creates backup text file containing data for character and stores it at url
//            guard let url = PC.export() else { return }
//            var dataString = ""
//            do {
//                dataString = try String(contentsOf: url)
//            } catch {
//                print("Caught creating data String")
//                return
//            }
//
//
//            let character = CKRecord(recordType: "Character")
//            character.setObject((PC.name ?? "name") as NSString, forKey: "name")
//            character.setObject(dataString as NSString, forKey: "data")
//
//            // Create image asset for character portrait
//            if PC.portraitPath != nil {
//                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
//                let img = CKAsset(fileURL: path)
//                character.setObject(img, forKey: "portrait")
//            }
//
//            // Save newly created CKRecord
//            privateDatabase.save(character) { (record, error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//                print(character.value(forKey: "name"))
//            }
//        }
//
//    }
    
    
    
    
//    func saveToCloud() {
//        // Timeout exits after 15 seconds in case server is too slow or cannot be reached
//
//
//        let fetchDispatch = DispatchGroup()
//        let saveDispatch = DispatchGroup()
//
//        cloudPCs = [CKRecord]()
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//        let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
//        let operation = CKQueryOperation(query: query)
//        operation.desiredKeys = ["data", "portrait"]
//
//        operation.recordFetchedBlock = { record in
//            print("💢")
//            self.cloudPCs.append(record)
//        }
//
//        operation.queryCompletionBlock = { (_, error) in
//            guard error == nil else {
//                SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
//                SVProgressHUD.showError(withStatus: "Unable to load backup")
//                UIApplication.shared.endIgnoringInteractionEvents()
//                return
//            }
//
//            timeOut = false
//
//            // Deletes old records
//            for record in self.cloudPCs {
//                privateDatabase.delete(withRecordID: record.recordID, completionHandler: { (id, error) in
//                    if error != nil {
//                        print(error?.localizedDescription)
//                    }
//                })
//            }
//
//
//        }
//
//        fetchDispatch.enter()
//
//        DispatchQueue.global(qos: .userInitiated).sync {
//            SVProgressHUD.show(withStatus: "Saving to iCloud")
//            UIApplication.shared.beginIgnoringInteractionEvents()
//
//            // Create new records
//            for PC in self.PCs {
//                // Creates backup text file containing data for character and stores it at url
//                guard let url = PC.export() else { return }
//                urls.append(url)
//                var dataString = ""
//                do {
//                    dataString = try String(contentsOf: url)
//                } catch {
//                    print("Caught creating data String")
//                    return
//                }
//
//
//                let character = CKRecord(recordType: "Character")
//                character.setObject((PC.name ?? "name") as NSString, forKey: "name")
//                character.setObject(dataString as NSString, forKey: "data")
//
//                // Create image asset for character portrait
//                if PC.portraitPath != nil {
//                    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
//                    let img = CKAsset(fileURL: path)
//                    character.setObject(img, forKey: "portrait")
//                }
//
//                // Save newly created CKRecord
//                privateDatabase.save(character) { (record, error) in
//                    if error != nil {
//                        print(error?.localizedDescription)
//                    }
//                    print(character.value(forKey: "name"))
//                }
//            }
//
//            // Fetches old records and deletes them from the database
//            privateDatabase.add(operation)
//
//            fetchDispatch.leave()
//        }
//
//        fetchDispatch.notify(queue: .main) {
//            // Remove backup text files created at url
//            for url in urls {
//                do {
//                    try FileManager.default.removeItem(at: url)
//                } catch {
//                    print("♨️Failed to remove item from files")
//                }
//            }
//
//            SVProgressHUD.dismiss()
//            SVProgressHUD.setMaximumDismissTimeInterval(TimeInterval(exactly: 2)!)
//            SVProgressHUD.showSuccess(withStatus: "Saved to iCloud")
//            UIApplication.shared.endIgnoringInteractionEvents()
//            return
//        }
//    }
    
    
//    func fetchBackup(for save: Bool) {
////        SVProgressHUD.show(withStatus: "Connecting to iCloud")
//
//        var returnArray = [CKRecord]()
//
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//
//        let query = CKQuery(recordType: "Character", predicate: NSPredicate(value: true))
//        let operation = CKQueryOperation(query: query)
//        operation.desiredKeys = ["data", "portrait"]
//        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
//            print("⚠️ \(self.cloudPCs.count) ⚠️")
//            DispatchQueue.main.async {
//                if save {
//                    self.overwriteSaves()
//                } else {
//                    self.overwriteBackup()
//                }
//
//            }
//        }
//
//        operation.recordFetchedBlock = { record in
//            print("💢")
//            returnArray.append(record)
//            self.cloudPCs = returnArray
//        }
//
//        privateDatabase.add(operation)
//
////        DispatchQueue.main.sync {
////            SVProgressHUD.dismiss()
////        }
//        cloudPCs = returnArray
//    }
//
//    func overwriteSaves() {
//
//        for PC in PCs {
//            deletePC(PC)
//        }
//
//        for record in cloudPCs {
//            guard let dataString = record.value(forKey: "data") as? String else { return }
//            var portrait: UIImage? = nil
//            if let asset = record.value(forKey: "portrait") as? CKAsset,
//                let url = asset.fileURL {
//                do {
//                    let data = try Data(contentsOf: url)
//                    portrait = UIImage(data: data)
//                } catch {
//                    print("could not open data from url")
//                    print(error.localizedDescription)
//                }
//
//            }
//
//            createPC(from: dataString, portrait: portrait)
//        }
//
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
//
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
//    }
//
//    func overwriteBackup() {
//
//        let privateDatabase = CKContainer.default().privateCloudDatabase
//
//        SVProgressHUD.show(withStatus: "Saving to iCloud")
//
//        print("❌ \(cloudPCs.count) ❌")
//        for record in cloudPCs {
//            privateDatabase.delete(withRecordID: record.recordID) { (recordID, error) -> Void in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//            }
//        }
//
//        for PC in PCs {
//            guard let url = PC.export() else { return }
//            var dataString = ""
//            do {
//                dataString = try String(contentsOf: url)
//            } catch { return }
//
//
//
//
//            let character = CKRecord(recordType: "Character")
//            character.setObject((PC.name ?? "name") as NSString, forKey: "name")
//            character.setObject(dataString as NSString, forKey: "data")
//
//
//            if PC.portraitPath != nil {
//                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(PC.portraitPath!)
//                let img = CKAsset(fileURL: path)
//                character.setObject(img, forKey: "portrait")
//            }
//
//            privateDatabase.save(character) { (record, error) in
//
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//
//                DispatchQueue.main.sync {
//                    SVProgressHUD.dismiss()
//                }
//            }
//
//            do {
//                try FileManager.default.removeItem(at: url)
//            } catch {
//                print("Failed to remove item from Inbox")
//            }
//
//        }
//
//
//    }
    

    
    
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
            attString.shadowSub(" Order: \(PCs[indexPath.row].order)")
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(unlock))
    }
    
    @objc func done() {
        self.dismiss(animated: true)
    }
    
    @objc func unlock() {
        UserDefaults.standard.set(true, forKey: "Rambart.StarFound.unlock")
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
        windowView.backgroundColor = UIColor(named: "\(previewTheme)BG")
        themesTitle.textColor = UIColor(named: "\(previewTheme)Main")
        themesSpacer.backgroundColor = UIColor(named: "\(previewTheme)Main")
        switch previewTheme {
        case "Space", "Fire", "Hazard", "Void":
            setButton.backgroundColor = UIColor.darkGray
            setButton.setTitleColor(UIColor.white, for: .normal)
        default:
            setButton.backgroundColor = UIColor.lightGray
            setButton.setTitleColor(UIColor.black, for: .normal)
        }
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
