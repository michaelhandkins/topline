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
    var lyrics: List<LyricLine>?
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
        if let safeLyrics = lyrics {
            return safeLyrics.count + 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.lyricsField.delegate = self
        
        cell.lyricsField.tag = indexPath.row
        
        if let safeLyrics = lyrics {
            if indexPath.row < safeLyrics.count {
                cell.lyricsField.text = safeLyrics[indexPath.row].text
            } else {
                cell.lyricsField.text = ""
            }
        }
        
        

        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidEndEditing(textField)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Text field ended editing")
        // What do when the lyrics in a cell are being edited as opposed to a brand new line being added
        if let safeLyrics = lyrics {
            if safeLyrics.count >= textField.tag + 1 {
                do {
                    let updatedLyricLine = LyricLine()
                    updatedLyricLine.text = textField.text!
                    safeLyrics[textField.tag] = updatedLyricLine
                    try realm.write {
                        self.song.lyrics[textField.tag] = updatedLyricLine
                        print("Successfully updated existing lyric line in Realm")
                    }
                } catch {
                    print("Error updating the lyrics for song in Realm: \(error)")
                }
            } else {
                // When a brand new line of lyrics is being added and there are already other lines that exist
                let newLyricLine = LyricLine()
                newLyricLine.text = textField.text!
                safeLyrics.append(newLyricLine)
                do {
                    try self.realm.write {
                        self.song.lyrics.append(newLyricLine)
                        print("Lyrics successfully added to song as a new line in Realm")
                    }
                } catch {
                    print("Error when updating song lyrics in Realm: \(error)")
                }
            }
        } else {
            // When the very first lyric line is being added to the song
            print("Attempting to add first line of lyrics to song")
            let newLyricLine = LyricLine()
            newLyricLine.text = textField.text!
            lyrics = List()
            lyrics?.append(newLyricLine)
            do {
                try self.realm.write {
                    self.song.lyrics.append(newLyricLine)
                    print("First line of lyrics successfully added to song in Realm")
                }
            } catch {
                print("Error when updating song lyrics in Realm: \(error)")
            }
            
        }
        
        tableView.reloadData()
        
    }

}
