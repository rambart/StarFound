//
//  EditorFeatsController.swift
//  StarFinder
//
//  Created by Tom on 5/2/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import CoreData

class EditorFeatsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var featsTableView: UITableView!
    @IBOutlet weak var featsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var notesTableViewHeight: NSLayoutConstraint!
    
    var PC = PlayerCharacter()
    var feats = [Feature]()
    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        featsTableView.delegate = self
        featsTableView.dataSource = self
        featsTableView.setEditing(true, animated: false)
        notesTableView.delegate = self
        notesTableView.dataSource = self
        notesTableView.setEditing(true, animated: false)
        
        PCChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        feats = PC.feats?.array as! [Feature]
        featsTableView.reloadData()
        featsTableViewHeight.constant = featsTableView.contentSize.height
        
        notes = PC.notes?.array as! [Note]
        notesTableView.reloadData()
        notesTableViewHeight.constant = notesTableView.contentSize.height
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case featsTableView:
            return feats.count + 1
        case notesTableView:
            return notes.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case featsTableView:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Feat"
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = feats[indexPath.row - 1].name
                return cell
            }
        case notesTableView:
            if indexPath.row == 0 {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Note"
                return cell
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.text = notes[indexPath.row - 1].name
                return cell
            }
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView {
        case featsTableView:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "NewFeat", sender: self)
            } else {
                let efvc = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
                efvc.feature = feats[indexPath.row - 1]
                efvc.forObj = PC
                efvc.PC = PC
                present(efvc, animated: true)
            }
        case notesTableView:
            let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
            nvc.PC = PC
            if indexPath.row == 0 {
                nvc.note = Note(context: context)
            } else {
                nvc.note = notes[indexPath.row - 1]
            }
            present(nvc, animated: true)
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .insert
        } else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch tableView {
        case featsTableView:
            if editingStyle == .delete {
                let featToDelete = feats[indexPath.row - 1]
                context.delete(featToDelete)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                
            }
            if editingStyle == .insert {
                performSegue(withIdentifier: "NewFeat", sender: self)
            }
        case notesTableView:
            if editingStyle == .delete {
                let noteToDelete = notes[indexPath.row - 1]
                context.delete(noteToDelete)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
                
            }
            if editingStyle == .insert {
                let nvc = storyboard?.instantiateViewController(withIdentifier: "EditorNoteNavController") as! EditorNoteNavController
                nvc.PC = PC
                nvc.note = Note(context: context)
                present(nvc, animated: true)
            }
        default:
            break
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewFeat" {
            let nfvc = segue.destination as! EditorNewFeatController
            nfvc.PC = self.PC
        }
    }

}



class EditorNewFeatController: UITableViewController {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var compFeats = [CompendiumFeat]()
    var filteredFeats = [CompendiumFeat]()
    var contentFeats = [CompendiumFeat]()
    var searchController = UISearchController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create New", style: .done, target: self, action: #selector(newFeatTapped))

        fetchCompendiumFeats()
        tableView.reloadData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Feats"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Combat"]
        searchController.searchBar.delegate = self
        
        
    }
    
    func fetchCompendiumFeats() {
        do {
            try compFeats = context.fetch(CompendiumFeat.fetchRequest())
            compFeats = compFeats.sorted { $0.name! < $1.name! }
        } catch {
            print("Did not fetch")
        }
    }
    
    @objc func newFeatTapped(_ sender: Any) {
        let newFeat = Feature(context: context)
        newFeat.name = "New Feat"
        newFeat.content = ""
        
        let efvc = storyboard?.instantiateViewController(withIdentifier: "EditorFeatNavController") as! EditorFeatNavController
        efvc.forObj = PC
        efvc.PC = PC
        efvc.feature = newFeat
        present(efvc, animated: true)
    }
    
    // MARK: - Search Bar
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredFeats = compFeats.filter({ (compFeat: CompendiumFeat) -> Bool in
            let doesCategoryMatch = (scope == "All") || (compFeat.type == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && compFeat.name!.lowercased().contains(searchController.searchBar.text!.lowercased())

            }
        })
        
        contentFeats = compFeats.filter({ (compFeat: CompendiumFeat) -> Bool in
            let doesCategoryMatch = (scope == "All") || (compFeat.type == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && compFeat.content!.lowercased().contains(searchController.searchBar.text!.lowercased())
                
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            if section == 0 {
                return filteredFeats.count
            } else {
                return contentFeats.count
            }
        } else {
            return compFeats.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            if section == 0 {
                return "Name Match"
            } else {
                return "Content Match"
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatCell", for: indexPath) as! NewFeatCell
        var feat = CompendiumFeat()
        if isFiltering() {
            if indexPath.section == 0 {
                feat = filteredFeats[indexPath.row]
            } else {
                feat = contentFeats[indexPath.row]
            }
        } else {
            feat = compFeats[indexPath.row]
        }
        cell.nameLabel.text = feat.name
        cell.typeLabel.text = feat.type ?? "General"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var feat = CompendiumFeat()
        if isFiltering() {
            if indexPath.section == 0 {
                feat = filteredFeats[indexPath.row]

            } else {
                feat = contentFeats[indexPath.row]
            }
        } else {
            feat = compFeats[indexPath.row]
        }
        let fpvc = storyboard?.instantiateViewController(withIdentifier: "FeatPreviewController") as! FeatPreviewController
        fpvc.PC = self.PC
        fpvc.feat = feat
        present(fpvc, animated: true)
    }
    
    
}



extension EditorNewFeatController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
}

extension EditorNewFeatController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


class NewFeatCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
}



class FeatPreviewController: UIViewController {
    
    @IBOutlet weak var featNameLabel: UILabel!
    @IBOutlet weak var featContentLabel: UILabel!
    
    
    var PC = PlayerCharacter()
    var feat = CompendiumFeat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featNameLabel.text = feat.name ?? "Feat"
        
        var contentToDisplay = feat.content ?? ""
        for opt in feat.featOption?.array as! [Option] {
            contentToDisplay.append("\n\n▶︎\(opt.name ?? "")◀︎")
            contentToDisplay.append("\n\n\(opt.content ?? "")")
        }
        
        featContentLabel.text = contentToDisplay
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let newFeat = Feature(context: context)
        newFeat.name = feat.name
        newFeat.content = feat.content
        for opt in feat.featOption?.array as! [Option] {
            let newOpt = Option(context: context)
            newOpt.name = opt.name
            newOpt.content = opt.content
            newOpt.selected = false
            newFeat.addToFeatureOptions(newOpt)
        }
        for mod in feat.featBonus?.array as! [Bonus] {
            let newMod = Bonus(context: context)
            newMod.bonus = mod.bonus
            newMod.type = mod.type
            newMod.enabled = true
            newFeat.addToFeatureBonus(newMod)
        }
        PC.addToFeats(newFeat)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    
    
}







