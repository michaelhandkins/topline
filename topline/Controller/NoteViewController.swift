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
    var lyrics: List<LyricLine> = List()
    var song: Note = Note()

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try realm.write {
                realm.add(song)
                print("Successfully added new song to Realm for the first time")
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
        
        cell.lyricsField.text = lyrics[indexPath.row].text

        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        if let selectedCell = tableView.indexPathForSelectedRow {
            // What do when the lyrics in a cell are being edited as opposed to a brand new line being added
            if lyrics.count >= selectedCell.row + 1 {
                do {
                    let updatedLyricLine = LyricLine()
                    updatedLyricLine.text = textField.text!
                    lyrics[selectedCell.row] = updatedLyricLine
                    try realm.write {
                        self.song.lyrics[selectedCell.row] = updatedLyricLine
                        print("Successfully updated existing lyric line in Realm")
                    }
                } catch {
                    print("Error updating the lyrics for song in Realm: \(error)")
                }
            } else {
                // When a brand new line of lyrics is being added
                let newLyricLine = LyricLine()
                newLyricLine.text = textField.text!
                lyrics.append(newLyricLine)
                do {
                    try self.realm.write {
                        self.song.lyrics.append(newLyricLine)
                        print("Lyrics successfully added to song as a new line in Realm")
                    }
                } catch {
                    print("Error when updating song lyrics in Realm: \(error)")
                }
            }
        }
        
        tableView.reloadData()
    }

}
