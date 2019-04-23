//
//  EditorSpellsKnownController.swift
//  StarFinder
//
//  Created by Tom on 5/8/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class EditorSpellsKnownController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Attributes
    var PC = PlayerCharacter()
    var level = Level()
    var spellsKnown = [[Spell]]()
    
    
    // Mark: - Outlets
    @IBOutlet weak var spellsKnownTable: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spellsKnown = getSpellsFor(level)
        
        spellsKnownTable.delegate = self
        spellsKnownTable.dataSource = self
        spellsKnownTable.setEditing(true, animated: false)
        
        spellsKnownTable.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        spellsKnown = getSpellsFor(level)
        spellsKnownTable.reloadData()
    }
    
    func getSpellsFor(_ lvl: Level) -> Array<Array<Spell>> {
        var lvl0Spells = [Spell]()
        var lvl1Spells = [Spell]()
        var lvl2Spells = [Spell]()
        var lvl3Spells = [Spell]()
        var lvl4Spells = [Spell]()
        var lvl5Spells = [Spell]()
        var lvl6Spells = [Spell]()
        var lvl7Spells = [Spell]()
        var lvl8Spells = [Spell]()
        var lvl9Spells = [Spell]()
        if let spells = level.classSpells?.allObjects as? [Spell] {
            for spell in spells {
                switch spell.level {
                case 0:
                    lvl0Spells.append(spell)
                case 1:
                    lvl1Spells.append(spell)
                case 2:
                    lvl2Spells.append(spell)
                case 3:
                    lvl3Spells.append(spell)
                case 4:
                    lvl4Spells.append(spell)
                case 5:
                    lvl5Spells.append(spell)
                case 6:
                    lvl6Spells.append(spell)
                case 7:
                    lvl7Spells.append(spell)
                case 8:
                    lvl8Spells.append(spell)
                case 9:
                    lvl9Spells.append(spell)
                default:
                    break
                }
            }
        }
        var lvlsArray = [lvl0Spells, lvl1Spells, lvl2Spells, lvl3Spells, lvl4Spells, lvl5Spells, lvl6Spells, lvl7Spells, lvl8Spells, lvl9Spells]
        
        for i in 0...9 {
            lvlsArray[i] = lvlsArray[i].sorted { $0.name! < $1.name! }
        }
        return lvlsArray
    }
    
    

    // MARK: - Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level \(section)"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellsKnown[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath)

        cell.textLabel?.text = spellsKnown[indexPath.section][indexPath.row].name
        cell.detailTextLabel?.text = "\(spellsKnown[indexPath.section][indexPath.row].school ?? "")"

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let spellToDelete = spellsKnown[indexPath.section][indexPath.row]
            spellsKnown[indexPath.section].remove(at: indexPath.row)
            context.delete(spellToDelete)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let esvc = storyboard?.instantiateViewController(withIdentifier: "SpellEditorNavController") as! SpellEditorNavController
        esvc.spell = spellsKnown[indexPath.section][indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        present(esvc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewSpell" {
            let sd = segue.destination as! NewSpellController
            sd.level = level
        }
    }

}


class NewSpellController: UITableViewController {
    
    // MARK: - Attributes
    var level = Level()
    var compSpells = [[CompendiumSpell]]()
    var filteredSpells = [[CompendiumSpell]]()
    var searchController = UISearchController()
    
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create New", style: .done, target: self, action: #selector(newSpellTapped))
        
        fetchCompSpells()
        filteredSpells = compSpells
        tableView.reloadData()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Spells"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Mystic", "Technomancer"]
        searchController.searchBar.delegate = self
        
        
    }
    
    func fetchCompSpells() {
        do {
            let allSpells = try context.fetch(CompendiumSpell.fetchRequest())
            compSpells = sortSpells(allSpells as! [CompendiumSpell])
        } catch {
            print("Did not fetch")
        }
    }
    
    func sortSpells(_ allSpells: [CompendiumSpell]) -> Array<Array<CompendiumSpell>> {
        var lvl0Spells = [CompendiumSpell]()
        var lvl1Spells = [CompendiumSpell]()
        var lvl2Spells = [CompendiumSpell]()
        var lvl3Spells = [CompendiumSpell]()
        var lvl4Spells = [CompendiumSpell]()
        var lvl5Spells = [CompendiumSpell]()
        var lvl6Spells = [CompendiumSpell]()
        var lvl7Spells = [CompendiumSpell]()
        var lvl8Spells = [CompendiumSpell]()
        var lvl9Spells = [CompendiumSpell]()
        for spell in allSpells {
            switch spell.level {
            case 0:
                lvl0Spells.append(spell)
            case 1:
                lvl1Spells.append(spell)
            case 2:
                lvl2Spells.append(spell)
            case 3:
                lvl3Spells.append(spell)
            case 4:
                lvl4Spells.append(spell)
            case 5:
                lvl5Spells.append(spell)
            case 6:
                lvl6Spells.append(spell)
            case 7:
                lvl7Spells.append(spell)
            case 8:
                lvl8Spells.append(spell)
            case 9:
                lvl9Spells.append(spell)
            default:
                break
            }
        }
        
        var lvlsArray = [lvl0Spells, lvl1Spells, lvl2Spells, lvl3Spells, lvl4Spells, lvl5Spells, lvl6Spells, lvl7Spells, lvl8Spells, lvl9Spells]
        
        for i in 0...9 {
            lvlsArray[i] = lvlsArray[i].sorted { $0.name! < $1.name! }
        }
        
        return lvlsArray
    }
    
    @objc func newSpellTapped() {
        let newSpell = Spell(context: context)
        newSpell.name = "New Spell"
        newSpell.level = 0
        level.addToClassSpells(newSpell)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        
        let esvc = storyboard?.instantiateViewController(withIdentifier: "SpellEditorNavController") as! SpellEditorNavController
        esvc.spell = newSpell
        present(esvc, animated: true)
    }
    
    
    // MARK: - Search Bar
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        for i in 0...9 {
            filteredSpells[i] = compSpells[i].filter({ (compSpell: CompendiumSpell) -> Bool in
                let doesCategoryMatch = (scope == "All") || (compSpell.type?.contains(scope.first!))!
                
                let matchFound = (compSpell.name!.lowercased().contains(searchController.searchBar.text!.lowercased())) /*|| (compSpell.content!.lowercased().contains(searchController.searchBar.text!.lowercased()))*/
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && matchFound
                    
                }
            })
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level \(section)"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredSpells[section].count
        } else {
            return compSpells[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellCell", for: indexPath)
        if isFiltering() {
            cell.textLabel?.text = filteredSpells[indexPath.section][indexPath.row].name
        } else {
            cell.textLabel?.text = compSpells[indexPath.section][indexPath.row].name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spvc = storyboard?.instantiateViewController(withIdentifier: "SpellPreviewController") as! SpellPreviewController
        var spellToSend = CompendiumSpell()
        if isFiltering() {
            spellToSend = filteredSpells[indexPath.section][indexPath.row]
        } else {
            spellToSend = compSpells[indexPath.section][indexPath.row]
        }
        // Create spell from comp spell
        let newSpell = Spell(context: context)
        newSpell.name = spellToSend.name ?? nil
        newSpell.level = spellToSend.level
        newSpell.school = spellToSend.school ?? nil
        newSpell.castingTime = spellToSend.castingTime ?? nil
        newSpell.range = spellToSend.range ?? nil
        newSpell.area = spellToSend.area ?? nil
        newSpell.effect = spellToSend.effect ?? nil
        newSpell.duration = spellToSend.duration ?? nil
        newSpell.savingThrow = spellToSend.savingThrow ?? nil
        newSpell.spellResistance = spellToSend.spellResistance ?? nil
        newSpell.content = spellToSend.content ?? nil
        
        spvc.spell = newSpell
        spvc.level = level
        present(spvc, animated: true)
    }
}

extension NewSpellController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
}

extension NewSpellController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


class SpellEditorNavController: UINavigationController {
    
    var spell = Spell()
    
}


class SpellEditorController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Attributes
    var spell = Spell()
    let levelPicker = UIPickerView()
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var castingTimeTextField: UITextField!
    @IBOutlet weak var rangeTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var effectTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var savingThrowTextField: UITextField!
    @IBOutlet weak var srTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super .viewDidLoad()
        spell = (self.navigationController as! SpellEditorNavController).spell
        
        // MARK: - Navigation Buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        // MARK: - Set textfields/picker delegates
        nameTextField.delegate = self
        levelTextField.delegate = self
        schoolTextField.delegate = self
        castingTimeTextField.delegate = self
        rangeTextField.delegate = self
        areaTextField.delegate = self
        effectTextField.delegate = self
        durationTextField.delegate = self
        savingThrowTextField.delegate = self
        srTextField.delegate = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        
        // MARK: - Set all textfields text
        nameTextField.text = spell.name ?? ""
        levelTextField.text = "\(spell.level)"
        schoolTextField.text = spell.school ?? ""
        castingTimeTextField.text = spell.castingTime ?? ""
        rangeTextField.text = spell.range ?? ""
        areaTextField.text = spell.area ?? ""
        effectTextField.text = spell.effect ?? ""
        durationTextField.text = spell.duration ?? ""
        savingThrowTextField.text = spell.savingThrow ?? ""
        srTextField.text = spell.spellResistance ?? ""
        contentLabel.text = spell.content ?? ""
        
        // MARK: - Assign Picker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(displayP3Red: 0.16, green:0.51, blue:0.91, alpha:1.0)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        levelTextField.inputAccessoryView = toolBar
        levelTextField.inputView = levelPicker
        
        NotificationCenter.default.addObserver(self, selector: #selector(PCChanged), name:NSNotification.Name(rawValue: "PCChanged"), object: nil)
    }
    
    @objc func PCChanged() {
        nameTextField.text = spell.name ?? ""
        levelTextField.text = "\(spell.level)"
        schoolTextField.text = spell.school ?? ""
        castingTimeTextField.text = spell.castingTime ?? ""
        rangeTextField.text = spell.range ?? ""
        areaTextField.text = spell.area ?? ""
        effectTextField.text = spell.effect ?? ""
        durationTextField.text = spell.duration ?? ""
        savingThrowTextField.text = spell.savingThrow ?? ""
        srTextField.text = spell.spellResistance ?? ""
        contentLabel.text = spell.content ?? ""
    }
    
    @objc func donePicker() {
        levelTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func editContent(_ sender: Any) {
        let textEditVC = storyboard?.instantiateViewController(withIdentifier: "TextEditorNavController") as! TextEditorNavController
        textEditVC.spell = self.spell
        present(textEditVC, animated: true)
    }
    
    @objc func save() {
        if nameTextField.text != "" {
            spell.name = nameTextField.text
        }
        if levelTextField.text != "" {
            spell.level = Int16(levelTextField.text!)!
        }
        if schoolTextField.text != "" {
            spell.school = schoolTextField.text
        }
        if castingTimeTextField.text != "" {
            spell.castingTime = castingTimeTextField.text
        }
        if rangeTextField.text != "" {
            spell.range = rangeTextField.text
        }
        if areaTextField.text != "" {
            spell.area = areaTextField.text
        }
        if effectTextField.text != "" {
            spell.effect = effectTextField.text
        }
        if durationTextField.text != "" {
            spell.duration = durationTextField.text
        }
        if savingThrowTextField.text != "" {
            spell.savingThrow = savingThrowTextField.text
        }
        if srTextField.text != "" {
            spell.spellResistance = srTextField.text
        }
        if contentLabel.text != "" {
            spell.content = contentLabel.text
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Picker View Functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        levelTextField.text = "\(row)"
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == levelTextField {
            let rowToSelect = Int(textField.text!)
            levelPicker.selectRow(rowToSelect!, inComponent: 0, animated: false)
        }
    }
    
}


class SpellPreviewController: UIViewController {
    
    // MARK: - Attributes
    var level = Level()
    var spell = Spell()
    
    // MARK: - Outlets
    @IBOutlet weak var spellNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spellNameLabel.text = spell.name
        
        let content = NSMutableAttributedString()
        content
            .bold("Level ", editor: true)
            .normal("\(spell.level)", editor: true)
        if spell.school != nil {
            content
            .bold("\nSchool ", editor: true)
            .normal(spell.school!, editor: true)
        }
        if spell.castingTime != nil {
            content
                .bold("\nCasting Time ", editor: true)
                .normal(spell.castingTime!, editor: true)
        }
        if spell.range != nil {
            content
                .bold("\nRange ", editor: true)
                .normal(spell.range!, editor: true)
        }
        if spell.area != nil {
            content
                .bold("\nArea ", editor: true)
                .normal(spell.area!, editor: true)
        }
        if spell.effect != nil {
            content
                .bold("\nEffect ", editor: true)
                .normal(spell.effect!, editor: true)
        }
        if spell.duration != nil {
            content
                .bold("\nDuration ", editor: true)
                .normal(spell.duration!, editor: true)
        }
        if spell.savingThrow != nil {
            content
                .bold("\nSaving Throw ", editor: true)
                .normal(spell.savingThrow!, editor: true)
        }
        if spell.spellResistance != nil {
            content
                .bold("\nSpell Resistance ", editor: true)
                .normal(spell.spellResistance!, editor: true)
        }
        content.normal("\n\n\(spell.content ?? "")", editor: true)
        
        contentLabel.attributedText = content
    }
    
   
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func add(_ sender: Any) {
        level.addToClassSpells(spell)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PCChanged"), object: nil)
        self.dismiss(animated: true)
    }
    
    
}









