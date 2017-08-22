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

let voiceManagerDidFinishPlaybackNotification =  NSNotification.Name(rawValue: "vioceManagerDidFinishPlayback")


protocol VoiceManagerDelegate : NSObjectProtocol {
    func didRecognizeSpeech(_ text : String)
    func didFinishRecording(_ fileName : String, creationDate : Date, fileDescription : String?)
}


class VoiceManager : NSObject {
    
    // voice recognition, https://developer.apple.com/library/content/samplecode/SpeakToMe/Introduction/Intro.html#//apple_ref/doc/uid/TP40017110-Intro-DontLinkElementID_2
    
    static let shared = VoiceManager()
    
    weak var delegate : VoiceManagerDelegate?
    
    /**default to American english regardless of the region*/
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var currentContent : String?
    
    var isSpeechRecognizerAvailable = false
    
    // voice recording
    lazy var audioSession = AVAudioSession.sharedInstance()
    var audioRecorder   : AVAudioRecorder?
    var settings : [String : Any] =
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            //AVEncoderBitRateKey : 192000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    
    // audio play back
    var audioPlayer : AVAudioPlayer?
    
    func initAudioSessionIfNeeded() {
        
        switch audioSession.recordPermission() {
            
        case AVAudioSessionRecordPermission.undetermined:                 audioSession.requestRecordPermission() { allowed in
            print("Allow Recording ? \(allowed)")
            }
            
        case AVAudioSessionRecordPermission.denied: print("prompt user to go to settings");
            
        case AVAudioSessionRecordPermission.granted: initAudioRecordingSession()
            
        default: break
            
        }
        
        switch SFSpeechRecognizer.authorizationStatus() {
            
        case .notDetermined: requestSpeechRecoginzerPermission()
            
        case .denied: print("prompt user to authorize"); break
            
        case .restricted: break // old device
            
        case .authorized: break // do nothing
            
        }
        
        
    }
    
    
    func initAudioRecordingSession() {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with : [.defaultToSpeaker])
            try audioSession.overrideOutputAudioPort(.speaker)
            //try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("failed to record!")
        }
    }
    
    func requestSpeechRecoginzerPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    break
                    
                case .denied:
                    break
                    
                case .restricted:
                    break
                    
                case .notDetermined:
                    break
                }
            }
        }
    }
    
    func fileURL() -> URL {
        let soundURL = DataManager.documentDirectoryURL().appendingPathComponent("\(UUID().uuidString).m4a")
        return soundURL
    }
    
    
    func startRecording() {
        
        initAudioSessionIfNeeded()
        
        currentContent = nil
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: self.fileURL(),
                                                settings: settings)
            audioRecorder?.delegate = self
            
            audioRecorder?.prepareToRecord()
            
        } catch {
            finishRecording(success: false)
        }
        
        do {
            try audioSession.setActive(true)
            
            audioRecorder?.record()
        }   catch {
            
        }
        
        
        // speech dictation here
        
        do {
            
            if let recognitionTask = recognitionTask {
                recognitionTask.cancel()
                self.recognitionTask = nil
            }
            speechRecognizer.delegate = self
            
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let inputNode = audioEngine.inputNode else {
                print("Audio engine has no input node"); return }
            
            guard let recognitionRequest = recognitionRequest else {
                print("Unable to created a SFSpeechAudioBufferRecognitionRequest object"); return }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task represents a speech recognition session.
            // We keep a reference to the task so that it can be cancelled.
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    let content = result.bestTranscription.formattedString
                    self.currentContent = content
                    self.delegate?.didRecognizeSpeech(content)
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            
            try audioEngine.start()
        }
            
        catch{}
        
        
    }
    
    
    func finishRecording(success: Bool = true) {
        audioRecorder?.stop()
        if success {
            
            print("success")
            
            recognitionRequest?.endAudio()
            
            // only for testing
            if let fileName = audioRecorder?.url.lastPathComponent {
                delegate?.didFinishRecording(fileName, creationDate: Date(), fileDescription: currentContent)
            }
            currentContent = nil
            
        } else {
            audioRecorder = nil
            print("Somthing Wrong.")
        }
    }
    
    func doPlay() {
        if !(audioRecorder?.isRecording ?? true){
            if let audioPlayer = try? AVAudioPlayer(contentsOf: audioRecorder!.url) {
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                audioPlayer.play()
                self.audioPlayer = audioPlayer
            }
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
    
    func stopPlayback() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
    }
    
    
    
    
}


extension VoiceManager : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("finished recording ? \(flag)")
    }
}

extension VoiceManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing ? \(flag)")
        NotificationCenter.default.post(name: voiceManagerDidFinishPlaybackNotification, object: flag)
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
}

extension VoiceManager : SFSpeechRecognizerDelegate {
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isSpeechRecognizerAvailable = available
    }
}
