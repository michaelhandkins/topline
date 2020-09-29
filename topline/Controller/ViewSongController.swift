//
//  ViewSongController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class ViewSongController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    var song: Note? {
        didSet {
            print("Song assigned to controller")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
        title = song?.title
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return song!.lyrics.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.lyricsField.delegate = self
        
        cell.lyricsField.tag = indexPath.row
        
        if indexPath.row < song!.lyrics.count {
            cell.lyricsField.text = song?.lyrics[indexPath.row].text
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
        if song!.lyrics.count >= textField.tag + 1 {
                let updatedLyricLine = LyricLine()
                updatedLyricLine.text = textField.text!
                do {
                    try realm.write {
                        self.song!.lyrics[textField.tag] = updatedLyricLine
                        print("Successfully updated existing lyric line in Realm")
                    }
                } catch {
                    print("Error updating the lyrics for song in Realm: \(error)")
                }
            } else {
                // When a brand new line of lyrics is being added and there are already other lines that exist
                let newLyricLine = LyricLine()
                newLyricLine.text = textField.text!
                do {
                    try self.realm.write {
                        self.song!.lyrics.append(newLyricLine)
                        print("Lyrics successfully added to song as a new line in Realm")
                    }
                } catch {
                    print("Error when updating song lyrics in Realm: \(error)")
                }
            }
        
        tableView.reloadData()
        
    }
    

}
