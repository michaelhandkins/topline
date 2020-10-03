//
//  NoteViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift
import AVFoundation

class NoteViewController: UITableViewController, UITextFieldDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let realm = try! Realm()
    var lyrics: List<LyricLine> = List()
    var song: Note = Note()
    var songTitle: String?
    var myData: [String] = []
    var callback: ((String) -> ())?
    var recordings: Results<Recording>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        song.id = realm.objects(Note.self).count
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        if let safeLyrics = lyrics {
//            return safeLyrics.count + 2
//        } else {
//            return 2
//        }
        return lyrics.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        if indexPath.row != 0 {
            cell.fileName = "song\(song.id)recording\(indexPath.row).m4a"
        }
        
        self.callback = { str in
            // update our data with the edited string
            if self.myData.count > 0 && indexPath.row > 0 && self.myData.count >= indexPath.row {
                self.myData[indexPath.row - 1] = str
            } else if indexPath.row == 0 {
                self.song.title = str
            } else {
                self.myData.append(str)
            }
            // we don't need to do anything else here
            // this will force the table to recalculate row heights
            tableView.performBatchUpdates(nil)
        }
        
        cell.lyricsField.tag = indexPath.row
        
        if indexPath.row == 0 && song.title == "Untitled" {
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.lyricsField.textColor = UIColor.lightGray
            cell.lyricsField.text = "Song Title:"
            cell.recordButton.isHidden = true
        }
        
            if indexPath.row <= lyrics.count && indexPath.row != 0 {
                cell.lyricsField.text = lyrics[indexPath.row - 1].text
            } else if indexPath.row > lyrics.count && indexPath.row != 0 {
                cell.lyricsField.text = ""
            } else if indexPath.row == 0 && song.title != "Untitled" {
                cell.lyricsField.text = song.title
            }
        
        return cell
    }
       
}

//MARK: - TextView Delegate Methods

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text ?? ""
        // tell the controller
        callback?(str)
        
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
                        self.song.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title to 'Untitled' in Realm: \(error)")
                }
            } else {
                songTitle = textView.text
                do {
                    try realm.write {
                        self.song.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title in Realm to user inputted text: \(error)")
                }
            }
        } else {
            if lyrics.count >= textView.tag {
                let updatedLine = LyricLine()
                updatedLine.text = textView.text
                lyrics[textView.tag - 1] = updatedLine
                do {
                    try realm.write {
                        self.song.lyrics[textView.tag - 1] = updatedLine
                    }
                } catch {
                    print("Error when updating lyric line to song in Realm: \(error)")
                }
            } else {
                let newLine = LyricLine()
                newLine.text = textView.text
                lyrics.append(newLine)
                do {
                    try realm.write {
                        self.song.lyrics.append(newLine)
                    }
                } catch {
                    print("Error when adding new lyric line to song in Realm: \(error)")
                }
            }
        }
        
        tableView.reloadData()

    }
    
}


