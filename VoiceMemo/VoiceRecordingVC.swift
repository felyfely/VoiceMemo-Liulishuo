//
//  VoiceRecordingVC.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/21/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import UIKit
typealias VM = VoiceManager
typealias DM = DataManager


class VoiceRecordingVC : UIViewController {
    
    @IBOutlet weak var recordButton: RecordButton!
    
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var speechContentLabel: UILabel!
    
    
    @IBAction func play(_ sender: Any) {
        VM.shared.doPlay()
    }
    
    
    override func viewDidLoad() {
        recordButton.delegate = self
        VM.shared.delegate  = self
        VM.shared.initAudioSessionIfNeeded()
        playButton.isEnabled = !(VM.shared.audioRecorder == nil)
    }
    
}

extension VoiceRecordingVC : RecordingStateDelegate {
    func didStartRecording() {
        speechContentLabel.text = "Listening"
        VM.shared.startRecording()
        playButton.isEnabled = false
        UIView.animate(withDuration: 0.25) { self.view.backgroundColor = UIColor.darkGray }
    }
    func didCancellRecording() {
        // delete recording here
        VM.shared.finishRecording()
        playButton.isEnabled = !(VM.shared.audioRecorder == nil)
        UIView.animate(withDuration: 0.25) { self.view.backgroundColor = UIColor.white }
        
    }
    func didEndRecording() {
        VM.shared.finishRecording()
        playButton.isEnabled = !(VM.shared.audioRecorder == nil)
        UIView.animate(withDuration: 0.25) { self.view.backgroundColor = UIColor.white }
    }
    
}

extension VoiceRecordingVC : VoiceManagerDelegate {
    func didRecognizeSpeech(_ text: String) {
        speechContentLabel.text = text
    }
    func didFinishRecording(_ fileName: String, creationDate: Date, fileDescription: String?) {
        if appD.isDataReady {
            appD.dataManager.save(fileName, creationDate: creationDate, fileDescription: fileDescription)
        }
    }
}
