//
//  HomeViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class HomeViewController: UITableViewController {
    
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var newSongButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var addButtonPressed: Bool = false
    let realm = try! Realm()
    var selectedSong: Note?
    let defaults = UserDefaults.standard
    
    var songs: Results<Note>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 55
        searchBar.delegate = self
        loadSongs()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.isHidden = true
        loadSongs()
        selectedSong = nil
        addButtonPressed = false
        
        if let theme = defaults.string(forKey: "theme") {
            settingsButton.tintColor = UIColor.init(named: theme)
            newSongButton.tintColor = UIColor.init(named: theme)
        } else {
            settingsButton.tintColor = UIColor.systemIndigo
            newSongButton.tintColor = UIColor.systemIndigo
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var darkMode: Bool = false
        
        if traitCollection.userInterfaceStyle == .dark {
            darkMode = true
        }
        
        if let defaultsDark = defaults.string(forKey: "darkMode") {
            darkMode = Bool(defaultsDark)!
        }
        
        if darkMode == true {
            print(true)
            self.view.window?.overrideUserInterfaceStyle = .dark
        } else {
            print(false)
            self.view.window?.overrideUserInterfaceStyle = .light
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeNoteCell", for: indexPath)

        cell.textLabel?.text = songs?[indexPath.row].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            do {
                try realm.write {
                    realm.delete(songs![indexPath.row])
                }
            } catch {
                print("Error when trying to delete song from Realm with swipe")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addButtonPressed = true
        performSegue(withIdentifier: "toNoteSegue", sender: self)
        
    }
    
    func loadSongs() {
        songs = realm.objects(Note.self).sorted(byKeyPath: "lastEdited", ascending: false)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong = songs![indexPath.row]
        performSegue(withIdentifier: "toNoteSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SettingsSegue" {
            let vc = segue.destination as! SettingsViewController
            return
        }
        
        let vc = segue.destination as! NoteViewController
        vc.hidesBottomBarWhenPushed = false
        if let songForVC = selectedSong {
            vc.song = songForVC
        }
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        songs = songs?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadSongs()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            loadSongs()
            songs = songs?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
            tableView.reloadData()
        }
        
        
        
    }
    
}
