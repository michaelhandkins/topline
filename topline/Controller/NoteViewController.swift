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
    var donePressed: Bool = false
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
    var recordings: Results<Recording>?
    var returnKeyCallback: (()->())?
    var callback: ((String) -> ())?
    var changedCallback: ((String)->())?
    
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
        donePressed = true
        hideNavigationButton()
        tableView.reloadData()
        let indexPath = IndexPath(row: cellCreatedWithReturn! - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
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
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
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
        return song.lyrics.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lyricsCell", for: indexPath) as! newNoteTableViewCell
        
        cell.deleteButton.isHidden = true
        
        cell.lyricsField.tag = indexPath.row
        
        cell.lyricsField.delegate = self
        
        self.returnKeyCallback = { [weak self] in
            if let self = self {
                
                let newLyricLineIndex = self.cellCreatedWithReturn! - 1
                // this is -1 because cell 0 is not included in the same data source
                do {
                    try self.realm.write {
                        self.song.lyrics.insert(LyricLine(), at: newLyricLineIndex)
                    }
                } catch {
                    print("Error when inserting new lyric line to song in Realm when return pressed")
                }
                let newIndexPath = IndexPath(row: self.cellCreatedWithReturn!, section: 0)
                print(newIndexPath.row)
                self.tableView.performBatchUpdates({
                    self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                }, completion: { b in
                    self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: newIndexPath)
                })
            }
        }
        
        if indexPath.row > 0 {
            cell.date = song.lyrics[indexPath.row - 1].date
            cell.fileName = "song\(song.id)recording\(song.lyrics[indexPath.row - 1].date).caf"
            cell.lyricsField.font = UIFont.systemFont(ofSize: 16)
        }
            
        if let safeRecordings = recordings {
            
            if safeRecordings.contains(where: {$0.audioFileName == cell.fileName}) && indexPath.row > 0 {
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
            cell.lyricsField.textColor = UIColor(named: "darkModeIndigo")
            cell.recordButton.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at row \(indexPath.row)")
        donePressed = false
        let cell = tableView.cellForRow(at: indexPath)! as! newNoteTableViewCell
        cellCreatedWithReturn = indexPath.row + 1
        cell.lyricsField.isUserInteractionEnabled = true
        cell.lyricsField.becomeFirstResponder()
        return
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row != 0 && donePressed == true {
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
        if cellCreatedWithReturn! - 1 > 0 {
            let indexPath = IndexPath(row: textView.tag - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "darkModeIndigo")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
//            cellCreatedWithReturn = textView.tag + 1
//            print(cellCreatedWithReturn!)
            if cellCreatedWithReturn! <= song.lyrics.count && song.lyrics[cellCreatedWithReturn! - 1].text == "" {
                let indexPath = IndexPath(row: cellCreatedWithReturn!, section: 0)
                print(indexPath)
                //the following line is not working
                self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: indexPath)
                print("Tried to select row")
            } else {
                returnKeyCallback?()
            }
            return false
        } else {
            return true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        hideNavigationButton()
        textView.isUserInteractionEnabled = false
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
            if song.lyrics.count >=  self.cellCreatedWithReturn! - 1 {
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
    }
}
