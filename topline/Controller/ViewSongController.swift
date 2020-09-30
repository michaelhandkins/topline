//
//  ViewSongController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift

class ViewSongController: UITableViewController, UITextViewDelegate {
    
    let realm = try! Realm()
    var song: Note? {
        didSet {
            print("Song assigned to controller")
        }
    }
    var songTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
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
        
        if indexPath.row == 0 && song!.title == "Untitled" {
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.lyricsField.textColor = UIColor.lightGray
            cell.lyricsField.text = "Song Title:"
            cell.recordButton.isHidden = true
        }
        
        if indexPath.row < song!.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = song!.lyrics[indexPath.row].text
        } else if indexPath.row >= song!.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = ""
        } else if indexPath.row == 0 && song!.title != "Untitled" {
            cell.lyricsField.text = song!.title
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.recordButton.isHidden = true
        }

        return cell
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Text field ended editing")
        
        if textView.tag == 0 {
            if textView.text.isEmpty {
                textView.text = "Song Title:"
                textView.textColor = UIColor.lightGray
                songTitle = "Untitled"
                do {
                    try realm.write {
                        self.song!.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title to 'Untitled' in Realm: \(error)")
                }
            } else {
                songTitle = textView.text
                do {
                    try realm.write {
                        self.song!.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title in Realm to user inputted text: \(error)")
                }
            }
        }
        // What do when the lyrics in a cell are being edited as opposed to a brand new line being added
        if song!.lyrics.count >= textView.tag + 1 {
                let updatedLyricLine = LyricLine()
                updatedLyricLine.text = textView.text!
                do {
                    try realm.write {
                        self.song!.lyrics[textView.tag] = updatedLyricLine
                        print("Successfully updated existing lyric line in Realm")
                    }
                } catch {
                    print("Error updating the lyrics for song in Realm: \(error)")
                }
            } else {
                // When a brand new line of lyrics is being added and there are already other lines that exist
                let newLyricLine = LyricLine()
                newLyricLine.text = textView.text!
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
