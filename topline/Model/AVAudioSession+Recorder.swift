//
//  AVAudioSession+Recorder.swift
//
//  Created by milanv7.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    
    func startRecording(for file: URL, with delegate:AVAudioRecorderDelegate?) -> AVAudioRecorder? {
        
        if AVAudioSession.sharedInstance().recordPermission == .granted {
            
            let session = AVAudioSession.sharedInstance()
            do {
                
                try session.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.default)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                let audioRecorder = try AVAudioRecorder(url: file, settings: settings)
                audioRecorder.delegate = delegate
                audioRecorder.isMeteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                return audioRecorder
            } catch let error {
                debugPrint("Recording Error \(error)")
            }
        } else {
            debugPrint("Recording Permission Not Granted")
        }
        return nil
    }
}
