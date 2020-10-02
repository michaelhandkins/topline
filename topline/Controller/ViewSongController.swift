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
    var lyrics: List<LyricLine> = List()
    var song: Note? {
        didSet {
            print("Song assigned to controller")
            lyrics = song!.lyrics
            lyrics.forEach { (lyricLine) in
                myData.append(lyricLine.text)
            }
        }
    }
    var songTitle: String?
    var myData: [String] = []
    var callback: ((String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return song!.lyrics.count + 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.lyricsField.delegate = self
        
        let fileName = "song\(song!.id)recording\(indexPath.row).m4a"
        cell.fileName = fileName
        
        //This should cause the player to find the URL path for the cell's fileName, but instead an error is received
//        if song!.recordings.contains(fileName) {
//            cell.recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
//        }
        
        self.callback = { str in
            // update our data with the edited string
            if self.myData.count > 0 && indexPath.row > 0 && self.myData.count >= indexPath.row {
                self.myData[indexPath.row - 1] = str
            } else if indexPath.row == 0 {
                self.song!.title = str
            } else {
                self.myData.append(str)
            }
            // we don't need to do anything else here
            // this will force the table to recalculate row heights
            tableView.performBatchUpdates(nil)
        }
        
        cell.lyricsField.tag = indexPath.row
        
        if indexPath.row == 0 && song!.title == "Untitled" {
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.lyricsField.textColor = UIColor.lightGray
            cell.lyricsField.text = "Song Title:"
            cell.recordButton.isHidden = true
        }
        
        if indexPath.row <= song!.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = song!.lyrics[indexPath.row - 1].text
        } else if indexPath.row > song!.lyrics.count && indexPath.row != 0 {
                cell.lyricsField.text = ""
            } else if indexPath.row == 0 && song!.title != "Untitled" {
                cell.lyricsField.text = song!.title
                cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
                cell.recordButton.isHidden = true
                
            }
        
        return cell
    }
    
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
        } else {
            if lyrics.count >= textView.tag {
                let updatedLine = LyricLine()
                updatedLine.text = textView.text
                do {
                    try realm.write {
                        self.lyrics[textView.tag - 1] = updatedLine
                        self.song!.lyrics[textView.tag - 1] = updatedLine
                    }
                } catch {
                    print("Error when updating lyric line to song in Realm: \(error)")
                }
            } else {
                let newLine = LyricLine()
                newLine.text = textView.text
                do {
                    try realm.write {
                        self.song!.lyrics.append(newLine)
                    }
                } catch {
                    print("Error when adding new lyric line to song in Realm: \(error)")
                }
            }
        }
        
        tableView.reloadData()

    }

}
