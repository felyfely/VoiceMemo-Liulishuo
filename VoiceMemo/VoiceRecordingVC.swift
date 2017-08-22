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
    
    @IBOutlet var permissionButton: UIButton!
    
    @IBOutlet weak var speechContentLabel: UILabel!
    
    
    @IBAction func play(_ sender: Any) {
        if VM.shared.audioPlayer?.isPlaying ?? false {
            VM.shared.stopPlayback()
            playButton.setTitle("", for: .normal)
        }
        else {
            VM.shared.doPlay()
            playButton.setTitle("", for: .normal)
        }
    }
    
    @IBAction func getPermission(_ sender: Any) {
        
        VM.shared.requestPermissionAction {
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        }
        
    }
    
    override func viewDidLoad() {
        
        recordButton.delegate = self
        VM.shared.delegate  = self
        
        playButton.isEnabled = !(VM.shared.audioRecorder == nil)
        
        view.addSubview(permissionButton)
        permissionButton.frame = view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPermissionButtonStates), name: voiceManagerDidChangePermissionStateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishPlayback(noti:)), name: voiceManagerDidFinishPlaybackNotification, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPermissionButtonStates()
    }
    
    
    
    func finishPlayback(noti : Notification) {
        //let flag = noti.object as? Bool // not using right now
        playButton.setTitle("", for: .normal)
        
    }
    
    func refreshPermissionButtonStates() {
        permissionButton.isHidden = VM.shared.getPermissionStateString() == nil
        permissionButton.setTitle(VM.shared.getPermissionStateString(), for: .normal)
    }
    
}

extension VoiceRecordingVC : RecordingStateDelegate {
    func didStartRecording() {
        speechContentLabel.text = "Listening ..."
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
