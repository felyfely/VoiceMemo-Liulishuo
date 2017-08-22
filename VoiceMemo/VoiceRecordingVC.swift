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

extension UIViewController {
    var appD : AppDelegate  {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
}
class VoiceRecordingVC : UIViewController {
    
    @IBAction func record(_ sender: Any) {
        VM.shared.startRecording()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        VM.shared.finishRecording()
    }
    
    @IBAction func play(_ sender: Any) {
        VM.shared.doPlay()
    }
    
    @IBAction func stopPlaying(_ sender: Any) {
        
    }
    
    @IBAction func fetch(_ sender: Any) {
        appD.dataManager.fetch()
    }
    
    
    override func viewDidLoad() {
        
    }
    
}
