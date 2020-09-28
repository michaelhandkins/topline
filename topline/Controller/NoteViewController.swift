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
    var lyrics: List<String> = List()
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
        return lyrics.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.lyricsField.delegate = self
        
        if let songLyrics = song.lyrics {
            cell.lyricsField.text = songLyrics[indexPath.row]
        }

        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if let selectedCell = tableView.indexPathForSelectedRow {
            if lyrics.count >= selectedCell.row + 1 {
                do {
                    let updatedLyricLine = LyricLine()
                    updatedLyricLine.text = textField.text!
                    try realm.write {
                        self.song.lyrics[selectedCell.row] = updatedLyricLine
                    }
                } catch {
                    print("Error updating the lyrics for song in Realm: \(error)")
                }
            } else {
                let newLyricLine = LyricLine()
                newLyricLine.text = textField.text!
                do {
                    try self.realm.write {
                        self.song.lyrics.append(newLyricLine)
                        print("Lyrics successfully updated to song in Realm")
                    }
                } catch {
                    print("Error when updating song lyrics in Realm: \(error)")
                }
            }
        }
        
        updateLyrics()
        tableView.reloadData()
    }
    
    func updateLyrics() {
        
        
    }

}
