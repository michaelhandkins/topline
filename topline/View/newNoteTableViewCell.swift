//
//  newNoteTableViewCell.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.
import UIKit
import RealmSwift
import AVFoundation
import SwipeCellKit

class newNoteTableViewCell: UITableViewCell, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    let realm = try! Realm()

    @IBOutlet weak var lyricsField: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var cellCreatedWithReturn: Int?
    var song: Note?
    var callback: ((String) -> ())?
    var returnKeyCallback: (()->())?
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    var fileName: String = "recording.m4a"
    var recordings: Results<Recording>?
    func loadRecordings() {
        recordings = realm.objects(Recording.self)
    }
    var date = Date()
    var recording: Recording?
    
    override func prepareForReuse() {
        recordButton.isHidden = false
        lyricsField.font = UIFont.systemFont(ofSize: 16)
        lyricsField.textColor = UIColor(named: "darkModeBlack")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // make sure scroll is disabled
        lyricsField.isScrollEnabled = false
        loadRecordings()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - AVAudioRecorder and Player Delegate Methods
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if recordButton.currentImage == UIImage(systemName: "record.circle") {
            setupRecorder()
            recorder.record()
            print(fileName)
            recordButton.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        } else if recordButton.currentImage == UIImage(systemName: "record.circle.fill") {
            recorder.stop()
            recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else if recordButton.currentImage == UIImage(systemName: "play.circle") {
            setupPlayer()
            player.play()
            recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        } else {
            player.stop()
            recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        do {
            try realm.write {
                realm.delete(self.recording!)
            }
        } catch {
            print("Error when trying to delete recording from realm with delete button")
        }
        deleteButton.isHidden = true
        recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
        recordButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setupRecorder() {
        let audioFileURL = getDocumentDirectory().appendingPathComponent(fileName)
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, options: [.defaultToSpeaker])
        } catch let error as NSError {
            print(error.description)
        }

//        let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
//                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
//                              AVEncoderBitRateKey : 320000,
//                              AVNumberOfChannelsKey : 2,
//                              AVSampleRateKey : 44100.0] as [String : Any]
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        deleteButton.isHidden = false
        //A new Recording object is created to store the fileName and audioFileURL
        recording = Recording()
        recording!.audioFileName = fileName
        recording!.date = self.date
        //            newRecording.urlString = recorder.url.absoluteString
        //The Recording is then added to realm
        do {
            try realm.write {
                realm.add(recording!)
                print("New recording added to Realm")
            }
        } catch {
            print("Error when adding new Recording to realm: \(error)")
        }
    }
    
    func setupPlayer() {
        
        let audioFileURL = getDocumentDirectory().appendingPathComponent(fileName)
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            try session.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: audioFileURL)
            print("Player set up to use the cell's audio URL")
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
    }
    
}

extension newNoteTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let str = textView.text ?? ""
        // tell the controller
        callback?(str)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        cellCreatedWithReturn = nil
        
        print("Text editing began")
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "darkModeBlack")
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            returnKeyCallback?()
//            textView.endEditing(true)
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
                let songTitle = "Untitled"
                do {
                    try self.realm.write {
                        self.song?.title = songTitle
                    }
                } catch {
                    print("Error when updating song title to 'Untitled' in Realm: \(error)")
                }
            } else {
                let songTitle = textView.text!
                do {
                    try self.realm.write {
                        self.song?.title = songTitle
                    }
                } catch {
                    print("Error when updating song title in Realm to user inputted text: \(error)")
                }
            }
        } else {
            if song!.lyrics.count >= textView.tag {
                let updatedLine = LyricLine()
                updatedLine.text = textView.text
                updatedLine.date = song!.lyrics[textView.tag - 1].date
                do {
                    try self.realm.write {
                        self.song!.lyrics[textView.tag - 1] = updatedLine
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
                        self.song!.lyrics.append(newLine)
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
