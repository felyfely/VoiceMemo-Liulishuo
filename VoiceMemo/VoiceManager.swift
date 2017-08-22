//
//  VoiceManager.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/22/17.
//  Copyright © 2017 付 旦. All rights reserved.
//
import UIKit
import Foundation
import AVFoundation
import Speech




class VoiceManager : NSObject {
    // voice recognition
    static let shared = VoiceManager()
    
    
    let audioEngine = AVAudioEngine()
    /**default to American english regardless of the region*/
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    let request = SFSpeechAudioBufferRecognitionRequest()
    
    // voice recording
    lazy var recordingSession = AVAudioSession.sharedInstance()
    var audioRecorder   : AVAudioRecorder!
    var settings : [String : Any] =
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVEncoderBitRateKey : 192000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    
    // audio play back
    var audioPlayer : AVAudioPlayer!
    
    func initAudioRecordingSessionIfNeeded() {
        
        switch recordingSession.recordPermission() {
            
        case AVAudioSessionRecordPermission.undetermined: initAudioRecordingSession()
            
        case AVAudioSessionRecordPermission.denied: print("prompt user to go to settings")
            
        case AVAudioSessionRecordPermission.granted: break
            
        default: break
            
        }
        
    }
    
    
    func initAudioRecordingSession() {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Allow")
                    } else {
                        print("Dont Allow")
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
    }
    
    func fileURL() -> URL? {
        let soundURL = DataManager.documentDirectoryURL()?.appendingPathComponent("\(UUID().uuidString).m4a")
        return soundURL
    }
    
    
    func startRecording() {
        
        initAudioRecordingSessionIfNeeded()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            audioRecorder = try AVAudioRecorder(url: self.fileURL()!,
                                                settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
    }
    
    
    func finishRecording(success: Bool = true) {
        audioRecorder.stop()
        if success {
            print("success")
            // only for testing
            (UIApplication.shared.delegate as! AppDelegate).dataManager.save(audioRecorder.url.lastPathComponent, creationDate: Date())
            
        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }
    
    func doPlay() {
        if !audioRecorder.isRecording {
            self.audioPlayer = try! AVAudioPlayer(contentsOf: audioRecorder.url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
        }
    }
    
    
    
    
}


extension VoiceManager : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
}

extension VoiceManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
}

