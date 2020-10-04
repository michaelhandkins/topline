//
//  NoteViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//

import UIKit
import RealmSwift
import AVFoundation

class NoteViewController: UITableViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let realm = try! Realm()
    var songWasSet: Bool = false
    var song: Note = Note() {
        didSet {
            songWasSet = true
        }
    }
    var songTitle: String?
    var myData: [String] = []
    var callback: ((String) -> ())?
    var recordings: Results<Recording>? {
        didSet {
            print("Recordings loaded")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecordings()
        
        print(songWasSet)
        
        title = ""
        
        if songWasSet == false {
            song.id = realm.objects(Note.self).count
            do {
                try realm.write {
                    realm.add(song)
                    print("Successfully added new song to Realm for the first time")
                }
            } catch {
                print("Error when adding new song to Realm: \(error)")
            }
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
        return song.lyrics.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.lyricsField.delegate = self
        //Creating the audio file name for the recording of each cell except the first, which is for the title of the song
        if indexPath.row != 0 {
            cell.fileName = "song\(song.id)recording\(indexPath.row).caf"
        }
            
            if let safeRecordings = recordings {
                
                if safeRecordings.contains(where: {$0.audioFileName == cell.fileName}) {
                    print("A corresponding recording is present")
                    cell.recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
//                    if let recordingForCell = safeRecordings.filter("urlString CONTAINS[cd] %@", cell.fileName!).first {
////                        print(recordingForCell.urlString)
////                        cell.audioFileURL = URL(string: recordingForCell.urlString)
//                    }
                }
            }
        
        //Enables the dynamic cell height which fits the text of the text view
        self.callback = { str in
            if self.myData.count > 0 && indexPath.row > 0 && self.myData.count >= indexPath.row {
                self.myData[indexPath.row - 1] = str
            } else if indexPath.row == 0 {
                self.songTitle = str
            } else {
                self.myData.append(str)
            }
            tableView.performBatchUpdates(nil)
        }
        
        cell.lyricsField.tag = indexPath.row
        
        //If the song does not have a title, create a placeholder
        if indexPath.row == 0 && song.title == "Untitled" {
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.lyricsField.textColor = UIColor.lightGray
            cell.lyricsField.text = "Song Title:"
            cell.recordButton.isHidden = true
        }
        
        //Populates the cell with the lyrics that belong to it
        if indexPath.row <= song.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = song.lyrics[indexPath.row - 1].text
        //Makes the cell have an empty string if no lyrics have been added to it yet
        } else if indexPath.row > song.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = ""
        //Fills in the title of the song if one is present
        } else if indexPath.row == 0 && song.title != "Untitled" {
            cell.lyricsField.text = song.title
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 30.0)
            cell.recordButton.isHidden = true
        }
        
        return cell
    }
    
    func loadRecordings() {
        recordings = realm.objects(Recording.self)
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
        print("Text editing began")
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
                    try self.realm.write {
                        self.song.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title to 'Untitled' in Realm: \(error)")
                }
            } else {
                songTitle = textView.text
                do {
                    try self.realm.write {
                        self.song.title = songTitle!
                    }
                } catch {
                    print("Error when updating song title in Realm to user inputted text: \(error)")
                }
            }
        } else {
            if song.lyrics.count >= textView.tag {
                let updatedLine = LyricLine()
                updatedLine.text = textView.text
                do {
                    try self.realm.write {
                        self.song.lyrics[textView.tag - 1] = updatedLine
                        print("Song lyrics updated in Realm")
                    }
                } catch {
                    print("Error when updating lyric line to song in Realm: \(error)")
                }
            } else {
                let newLine = LyricLine()
                newLine.text = textView.text
                do {
                    try self.realm.write {
                        self.song.lyrics.append(newLine)
                        print("New song lyrics added in Realm")
                    }
                } catch {
                    print("Error when adding new lyric line to song in Realm: \(error)")
                }
            }
        }
        
        tableView.reloadData()

    }
    
}


