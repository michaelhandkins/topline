//
//  NoteViewController.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
//
import UIKit
import RealmSwift
import AVFoundation
import SwipeCellKit

class NoteViewController: UITableViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var buttonsSwitch: UISwitch!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addLineButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var switchFlipped: Bool = false
    var cellCreatedWithReturn: Int?
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
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let newLyricLine = LyricLine()
        newLyricLine.text = ""
        do {
            try realm.write {
                song.lyrics.append(newLyricLine)
            }
        } catch {
            print("Error adding new lyric line to song in Realm when add button was pressed")
        }
        tableView.reloadData()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        cellCreatedWithReturn = nil
        hideNavigationButton()
        tableView.reloadData()
    }
    
    @IBAction func buttonsSwitchFlipped(_ sender: UISwitch) {
        switchFlipped = !switchFlipped
        tableView.reloadData()
    }
    
    
    func hideNavigationButton() {
        doneButton.isEnabled = false
        doneButton.tintColor = UIColor.clear
    }
    
    func showNavigationButton() {
        doneButton.isEnabled = true
        doneButton.tintColor = UIColor.systemIndigo
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationButton()
        
        navigationController?.navigationBar.tintColor = UIColor.systemIndigo
        
        loadRecordings()
        
        print(songWasSet)
        
        title = ""
        
        if songWasSet == false {
            let firstLyricLine = LyricLine()
            firstLyricLine.text = ""
            firstLyricLine.date = Date()
            do {
                try realm.write {
                    realm.add(song)
                    print("Successfully added new song to Realm for the first time")
                    self.song.lyrics.append(firstLyricLine)
                    print("First lyric line added to song in Realm when the cells loaded.")
                }
            } catch {
                print("Error when adding new song to Realm: \(error)")
            }
        }
        
        tableView.register(UINib(nibName: "newNoteTableViewCell", bundle: nil), forCellReuseIdentifier: "lyricsCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - 30, right: 0)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        do {
            try realm.write {
                self.song.lastEdited = Date()
            }
        } catch {
            print("Error updating when the song was last edited.")
        }
       
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        if let safeLyrics = lyrics {
//            return safeLyrics.count + 2
//        } else {
//            return 2
//        }
        return song.lyrics.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.deleteButton.isHidden = true
        
        cell.lyricsField.delegate = self
        //Creating the audio file name for the recording of each cell except the first, which is for the title of the song
        
        DispatchQueue.main.async {
            if let newCellIndexPath = self.cellCreatedWithReturn {
                if indexPath.row == newCellIndexPath {
                    cell.lyricsField.becomeFirstResponder()
                    self.showNavigationButton()
                }
            }
        }
        
        
        if indexPath.row > 0 {
            cell.date = song.lyrics[indexPath.row - 1].date
            cell.fileName = "song\(song.id)recording\(song.lyrics[indexPath.row - 1].date).caf"
            cell.lyricsField.font = UIFont.systemFont(ofSize: 16)
        }
            
        if let safeRecordings = recordings {
            
            if safeRecordings.contains(where: {$0.audioFileName == cell.fileName}) {
                print("A corresponding recording is present")
                cell.recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
                cell.deleteButton.isHidden = false
                let safeRecording = safeRecordings.filter({ $0.audioFileName == cell.fileName }).first
                cell.recording = safeRecording
            } else {
                cell.recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
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
        
        if switchFlipped == true {
            cell.recordButton.isHidden = true
            cell.deleteButton.isHidden = true
        } else {
            cell.recordButton.isHidden = false
            cell.recordButton.isHidden = false
        }
        
        if indexPath.row == 0 && song.title == "Untitled" {
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 36.0)
            cell.lyricsField.textColor = UIColor.lightGray
            cell.lyricsField.text = "Song Title:"
            cell.recordButton.isHidden = true
        }
        
        //Populates the cell with the lyrics that belong to it
        if indexPath.row <= song.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = song.lyrics[indexPath.row - 1].text
            cell.date = song.lyrics[indexPath.row - 1].date
        //Makes the cell have an empty string if no lyrics have been added to it yet
        } else if indexPath.row > song.lyrics.count && indexPath.row != 0 {
            cell.lyricsField.text = ""
        //Fills in the title of the song if one is present
        } else if indexPath.row == 0 && song.title != "Untitled" {
            cell.lyricsField.text = song.title
            cell.lyricsField.font = UIFont.boldSystemFont(ofSize: 36.0)
            cell.recordButton.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row != 0 {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            do {
                try realm.write {
                    realm.delete(song.lyrics[indexPath.row - 1])
                }
            } catch {
                print("Error when trying to delete song's lyrics from Realm with swipe")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        tableView.reloadData()
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
        showNavigationButton()
        cellCreatedWithReturn = nil
        let indexPath = IndexPath(row: textView.tag, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        print("Text editing began")
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "darkModeBlack")
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.endEditing(true)
            cellCreatedWithReturn = textView.tag + 1
            if song.lyrics.count == textView.tag || song.lyrics[textView.tag].text != "" {
                let newLyricLine = LyricLine()
                newLyricLine.text = ""
                do {
                    try realm.write {
                        self.song.lyrics.insert(newLyricLine, at: textView.tag)
                        print("Successfully inserted new lyric line in Realm")
                    }
                } catch {
                    print("Error when inserting new lyric line after pressing return")
                }
            }
            tableView.reloadData()
            return false
        } else {
            return true
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
                updatedLine.date = song.lyrics[textView.tag - 1].date
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
        
//        tableView.reloadData()

    }
    
}
