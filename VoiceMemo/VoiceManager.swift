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
    
    //    let audioEngine = AVAudioEngine()
    //    /**default to American english regardless of the region*/
    //    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    //
    //    let request = SFSpeechAudioBufferRecognitionRequest()
    
    // voice recording
    lazy var recordingSession = AVAudioSession.sharedInstance()
    var audioRecorder   : AVAudioRecorder!
    var settings : [String : Any] =
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            //AVEncoderBitRateKey : 192000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    
    // audio play back
    var audioPlayer : AVAudioPlayer!
    
    func initAudioRecordingSessionIfNeeded() {
        
        switch recordingSession.recordPermission() {
            
        case AVAudioSessionRecordPermission.undetermined: initAudioRecordingSession()
            
        case AVAudioSessionRecordPermission.denied: print("prompt user to go to settings");
            
        case AVAudioSessionRecordPermission.granted: initAudioRecordingSession()
            
        default: break
            
        }
        
    }
    
    
    func initAudioRecordingSession(_ hasPermission : Bool = false) {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with : [.defaultToSpeaker])
            try recordingSession.overrideOutputAudioPort(.speaker)
            try recordingSession.setActive(true)
            if !hasPermission {
                recordingSession.requestRecordPermission() { allowed in
                    print("Allow Recording ? \(allowed)")
                }
            }
        } catch {
            print("failed to record!")
        }
    }
    
    func fileURL() -> URL? {
        let soundURL = DataManager.documentDirectoryURL().appendingPathComponent("\(UUID().uuidString).m4a")
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
    
    func playFile(_ fileName : String) {
        var dirPathURL = DataManager.documentDirectoryURL()
        dirPathURL.appendPathComponent(fileName)
        //        guard let audioPlayer = audioPlayer ?? (try? AVAudioPlayer(contentsOf: dirPathURL)) else {
        //            print("failed to init audio player"); return
        //        }
        //        if audioPlayer.url == dirPathURL {
        //            if audioPlayer.isPlaying { audioPlayer.pause() }
        //            else { audioPlayer.play() }
        //        }
        //        else {
        //audioPlayer!.stop()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: dirPathURL)
            audioPlayer!.prepareToPlay()
            audioPlayer!.delegate = self
            audioPlayer!.play()
        }
            
        catch {
            print("failed to init audio player \(error)")
        }
        //        }
        
    }
    
    
    
    
}


extension VoiceManager : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording ? \(flag)")
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

