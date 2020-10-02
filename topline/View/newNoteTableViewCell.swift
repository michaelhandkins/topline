//
//  newNoteTableViewCell.swift
//  topline
//
//  Created by Michael Handkins on 9/27/20.

import UIKit
import RealmSwift
import AVFoundation

class newNoteTableViewCell: UITableViewCell, UITextViewDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    let realm = try! Realm()

    @IBOutlet weak var lyricsField: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    
    var recorder = AVAudioRecorder()
    var player = AVAudioPlayer()
    var fileName: String?
    var audioFileURL: URL?
    var hasRecording = false
    var newRecording = Recording()
    
//    var callback: ((String) -> ())?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // make sure scroll is disabled
        lyricsField.isScrollEnabled = false
        setupRecorder()
//        lyricsField.delegate = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK: - AVAudioRecorder and Player Delegate Methods
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        
        if recordButton.currentImage == UIImage(systemName: "record.circle") {
            recorder.record()
            recordButton.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
        } else if recordButton.currentImage == UIImage(systemName: "record.circle.fill") {
            recorder.stop()
            recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            self.hasRecording = true
        } else if recordButton.currentImage == UIImage(systemName: "play.circle") {
            setupPlayer()
            player.play()
            recordButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        } else {
            player.stop()
            recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        }
        
    }
    
    func getDocumentDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        
    }
    
    func setupRecorder() {
        
        if let safeFileName = fileName {
            audioFileURL = getDocumentDirectory().appendingPathComponent(safeFileName)
        } else {
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: [.defaultToSpeaker])
        } catch let error as NSError {
            print(error.description)
        }
        
        let recordSettings = [AVFormatIDKey : kAudioFormatAppleLossless,
                              AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                              AVEncoderBitRateKey : 320000,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey : 44100.0] as [String : Any]
        
        do {
            recorder = try AVAudioRecorder(url: self.audioFileURL!, settings: recordSettings)
            recorder.delegate = self
            recorder.prepareToRecord()
        } catch {
            print(error)
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            
    }
    
    func setupPlayer() {
        
        if let safeFileName = fileName {
            audioFileURL = getDocumentDirectory().appendingPathComponent(safeFileName)
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: self.audioFileURL!)
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
