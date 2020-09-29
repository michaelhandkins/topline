//
//  HomeViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class HomeViewController: UITableViewController {
    
    var addButtonPressed: Bool = false
    let realm = try! Realm()
    var selectedSong: Note?
    
    var songs: Results<Note>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 55
        loadSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSongs()
        selectedSong = nil
        addButtonPressed = false
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        addButtonPressed = true
        performSegue(withIdentifier: "toNoteSegue", sender: self)
        
    }
    
    func loadSongs() {
        songs = realm.objects(Note.self)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong = songs![indexPath.row]
        performSegue(withIdentifier: "toSongSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toNoteSegue" {
            let vc = segue.destination as! NoteViewController
        } else {
            let vc = segue.destination as! ViewSongController
            vc.song = selectedSong
        }
    }
    

}
