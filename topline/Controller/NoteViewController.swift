//
//  NoteViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class NoteViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    var lyrics: [String] = []
    var noteTitle: String = ""
    var notes: [Note]? = []
    var song: Note = Note()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try realm.write {
                realm.add(song)
            }
        } catch {
            print("Error when adding new song to Realm: \(error)")
        }

        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if notes != nil {
            return notes!.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        if let songLyrics = song.lyrics {
            cell.lyricsField.text = songLyrics[indexPath.row]
        }
        
        cell.lyricsField.delegate = self

        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != "" {
            
            lyrics.append(textField.text!)
            song.lyrics = lyrics
            
            do {
                try realm.write {
                    song.lyrics = lyrics
                    print("Lyrics successfully updated to song in Realm")
                }
            } catch {
                print("Error when updating song lyrics in Realm: \(error)")
            }
            
            tableView.reloadData()
            
        }
        
        
        
    }

}
